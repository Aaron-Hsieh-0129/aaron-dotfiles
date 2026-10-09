# Optional project environment. Set paths in local.zsh, then run vvm-env.
if [[ ! -d ${NVHPC_ROOT:-} ]]; then
    print -u2 'Set NVHPC_ROOT to your installed NVHPC version directory in local.zsh.'
    return 1
fi
export NVHPC_ROOT
export NVHPC_DEFAULT_CUDA=${NVHPC_DEFAULT_CUDA:-13.0}
export CUDA_HOME=${CUDA_HOME:-$NVHPC_ROOT/cuda/$NVHPC_DEFAULT_CUDA}
export HPCX_HOME=${HPCX_HOME:-$NVHPC_ROOT/comm_libs/$NVHPC_DEFAULT_CUDA/hpcx/hpcx-2.24}
local _aaron_root _aaron_directory
for _aaron_root in "$CUDA_HOME" "$NVHPC_ROOT/compilers" "$NVHPC_ROOT/math_libs" "$HPCX_HOME/ompi" "$HPCX_HOME/ucx" "$HPCX_HOME/sharp" "$HPCX_HOME/nccl_rdma_sharp_plugin" "${INSTALL_DIR:-}" "${INSTALL_DIR2:-}"; do
    [[ -n "$_aaron_root" ]] || continue
    aaron_prepend_dir PATH "$_aaron_root/bin"
    aaron_prepend_dir C_INCLUDE_PATH "$_aaron_root/include"
    aaron_prepend_dir CPLUS_INCLUDE_PATH "$_aaron_root/include"
    for _aaron_directory in "$_aaron_root/lib" "$_aaron_root/lib64"; do
        aaron_prepend_dir LIBRARY_PATH "$_aaron_directory"
        aaron_prepend_dir LD_LIBRARY_PATH "$_aaron_directory"
    done
done
if [[ -n ${INSTALL_DIR:-} ]]; then
    aaron_prepend_dir PATH "$INSTALL_DIR/cmake/bin"
    aaron_prepend_dir PATH "$INSTALL_DIR/gcc11/bin"
    aaron_prepend_dir LD_LIBRARY_PATH "$INSTALL_DIR/gcc11/lib"
    aaron_prepend_dir LD_LIBRARY_PATH "$INSTALL_DIR/gcc11/lib64"
    aaron_prepend_dir LIBRARY_PATH "$INSTALL_DIR/gcc11/lib"
    aaron_prepend_dir LIBRARY_PATH "$INSTALL_DIR/gcc11/lib64"
    export INSTALL_DIR
fi
[[ ! -d "$HPCX_HOME/ompi" ]] || export OPAL_PREFIX="$HPCX_HOME/ompi"
[[ -z ${INSTALL_DIR2:-} ]] || export INSTALL_DIR2
[[ -z ${VVM_ROOT:-} ]] || export VVM_ROOT
if [[ -n ${AARON_MPI_TMP_ROOT:-} ]]; then
    export OMPI_TMPDIR_BASE="$AARON_MPI_TMP_ROOT/${SLURM_JOB_ID:-manual}"
    mkdir -p "$OMPI_TMPDIR_BASE" && export TMPDIR="$OMPI_TMPDIR_BASE"
fi
unset _aaron_root _aaron_directory
