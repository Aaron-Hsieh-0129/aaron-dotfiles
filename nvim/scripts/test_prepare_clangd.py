"""Regression checks: python3 scripts/test_prepare_clangd.py."""

import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "prepare_clangd", Path(__file__).with_name("prepare-clangd.py")
)
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)


class PrepareClangdTests(unittest.TestCase):
    def test_mixed_cpp_standards_are_preserved(self):
        entries = [
            {
                "directory": "/build",
                "file": "Model.cpp",
                "command": "mpic++ --c++17 -c Model.cpp",
            },
            {
                "directory": "/build",
                "file": "VVM_cleo_process_interface.cpp",
                "arguments": [
                    "mpic++", "-std=c++20", "-c", "VVM_cleo_process_interface.cpp"
                ],
            },
            {
                "directory": "/build",
                "file": "legacy.cpp",
                "arguments": ["mpic++", "-c", "legacy.cpp"],
            },
        ]
        translated = helper.clangd_entries(entries)
        self.assertIn("-std=c++17", translated[0]["arguments"])
        self.assertNotIn("--c++17", translated[0]["arguments"])
        self.assertIn("-std=c++20", translated[1]["arguments"])
        self.assertNotIn("-std=c++17", translated[1]["arguments"])
        self.assertIn("-std=c++17", translated[2]["arguments"])
        self.assertIn("--c++17", entries[0]["command"])
        self.assertNotIn("-std=c++17", entries[2]["arguments"])

    def test_moved_and_external_cleo_headers_use_local_target(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "vvm"
            build = root / "build"
            cleo = root / "external-cleo"
            build.mkdir()
            headers = [
                source / "src/core/geometry/Field.hpp",
                source / "src/physics/cleo/VVM_cleo_process_interface.hpp",
                cleo / "libs/superdrops/state.hpp",
            ]
            for header in headers:
                header.parent.mkdir(parents=True, exist_ok=True)
                header.touch()
            paths = [
                source / "src/core/Grid.cpp",
                source / "src/physics/p3/Field.cpp",
                source / "src/physics/cleo/VVM_cleo_process_interface.cpp",
                cleo / "libs/superdrops/superdrop.cpp",
            ]
            entries = []
            for index, path in enumerate(paths):
                # CMake databases may spell source paths relative to directory.
                filename = os.path.relpath(path, build)
                entries.append(
                    {
                        "directory": str(build),
                        "file": filename,
                        "arguments": [
                            "mpic++", "--c++17" if index < 2 else "-std=c++20",
                            f"-DTARGET_{index}", "-c", filename,
                        ],
                    }
                )
            destination, count = helper.header_database(
                source, build, helper.clangd_entries(entries),
                {"CLEO_SOURCE_DIR": str(cleo)},
            )
            commands = {
                entry["file"]: entry["arguments"]
                for entry in json.loads((destination / "compile_commands.json").read_text())
            }
            self.assertEqual(count, 3)
            for header, target in zip(headers, (0, 2, 3)):
                self.assertIn(f"-DTARGET_{target}", commands[str(header)])
                self.assertIn(str(header), commands[str(header)])
                self.assertNotIn(entries[target]["file"], commands[str(header)])
            self.assertIn("-std=c++20", commands[str(headers[2])])

    def test_cached_environment_restores_wrapper_compilers(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in (
                "sdk/compilers/bin",
                "sdk/compilers/lib",
                "mpi/bin",
                "mpi/lib",
                "cuda/bin",
            ):
                (root / name).mkdir(parents=True)
            values = {
                "NVHPC_DIR": str(root / "sdk"),
                "VVM_MPI_ROOT": str(root / "mpi"),
                "CUDAToolkit_BIN_DIR": str(root / "cuda/bin"),
            }
            with patch.dict(
                os.environ, {"PATH": "/usr/bin", "VVM_ROOT": "/other"}, clear=True
            ):
                env = helper.build_environment(values, root)
                self.assertEqual(
                    env["PATH"].split(os.pathsep)[0], str(root / "sdk/compilers/bin")
                )
                self.assertIn(str(root / "mpi/bin"), env["PATH"].split(os.pathsep))
                self.assertIn(
                    str(root / "sdk/compilers/lib"),
                    env["LD_LIBRARY_PATH"].split(os.pathsep),
                )
                self.assertEqual(env["VVM_ROOT"], str(root))
                self.assertEqual(os.environ["PATH"], "/usr/bin")
                self.assertEqual(os.environ["VVM_ROOT"], "/other")

    def test_gpu_flags_math_headers_and_explicit_header_command(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build = root / "build"
            for name in ("build", "src", "cuda/include", "math/include", "gcc/bin"):
                (root / name).mkdir(parents=True)
            for name in (
                "cuda/include/cuda_runtime.h",
                "math/include/curand_mtgp32_kernel.h",
                "gcc/bin/g++",
                "src/sample.hpp",
            ):
                (root / name).touch()
            values = {
                "CMAKE_HOME_DIRECTORY": str(root),
                "NVHPC_DIR": str(root / "sdk"),
                "VVM_ENABLE_GPU": "ON",
                "VVM_GCC_TOOLCHAIN": str(root / "gcc"),
                "CUDAToolkit_BIN_DIR": str(root / "cuda/bin"),
                "CUDA_curand_LIBRARY": str(root / "math/lib64/libcurand.so"),
            }
            (build / "CMakeCache.txt").write_text(
                "\n".join(f"{k}:STRING={v}" for k, v in values.items())
            )
            entry = {
                "directory": str(build),
                "file": str(root / "src/sample.cpp"),
                "arguments": [
                    "nvc++",
                    "-mp",
                    "-arch=sm_120",
                    "--relocatable-device-code=true",
                    "-expt-relaxed-constexpr",
                    "-std=c++20",
                    "-c",
                    str(root / "src/sample.cpp"),
                ],
            }
            (build / "compile_commands.json").write_text(json.dumps([entry]))
            with patch(
                "sys.argv", ["prepare-clangd.py", str(build), "--skip-configure"]
            ), patch.object(
                helper.subprocess, "check_output", return_value="/missing\n"
            ):
                helper.main()
            config = (root / ".clangd").read_text()
            self.assertIn('"-fgpu-rdc"', config)
            self.assertIn('"--cuda-gpu-arch=sm_120"', config)
            self.assertIn('"--relocatable-device-code=*"', config)
            self.assertIn(str(root / "math/include"), config)
            self.assertNotIn('"-std=c++17"', config)
            headers = json.loads(
                (build / "aaron-clangd/compile_commands.json").read_text()
            )
            self.assertEqual(headers[1]["file"], str(root / "src/sample.hpp"))
            self.assertIn(str(root / "src/sample.hpp"), headers[1]["arguments"])
            self.assertIn("-std=c++20", headers[1]["arguments"])
            self.assertEqual(
                json.loads((build / "compile_commands.json").read_text()), [entry]
            )


if __name__ == "__main__":
    unittest.main()
