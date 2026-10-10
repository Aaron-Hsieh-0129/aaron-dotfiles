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
            headers = json.loads(
                (build / "aaron-clangd/compile_commands.json").read_text()
            )
            self.assertEqual(headers[1]["file"], str(root / "src/sample.hpp"))
            self.assertIn(str(root / "src/sample.hpp"), headers[1]["arguments"])
            self.assertEqual(
                json.loads((build / "compile_commands.json").read_text()), [entry]
            )


if __name__ == "__main__":
    unittest.main()
