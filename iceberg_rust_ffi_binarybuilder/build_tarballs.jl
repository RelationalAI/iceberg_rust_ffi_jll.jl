using BinaryBuilder

name = "iceberg_rust_ffi"
version = v"0.3.0"

sources = [
    GitSource("https://github.com/RelationalAI/RustyIceberg.jl.git", "a23022e750770ddb983dbaa7f3f103753f2813aa"),
]

# Bash recipe for building across all platforms
script = raw"""
set -x

echo "=== Environment ==="
echo "RUSTUP_HOME=${RUSTUP_HOME:-unset}"
echo "RUSTUP_TOOLCHAIN=${RUSTUP_TOOLCHAIN:-unset}"
echo "CARGO_HOME=${CARGO_HOME:-unset}"
echo "PATH=${PATH}"
which rustc || echo "rustc not found in PATH"
which rustup || echo "rustup not found in PATH"
which cargo || echo "cargo not found in PATH"
rustc --version || echo "rustc --version failed"
rustup show || echo "rustup show failed"

echo "=== Removing old toolchain to free disk space ==="
rustup toolchain uninstall ${RUSTUP_TOOLCHAIN} 2>&1 || echo "uninstall failed with exit code $?"
df -h / /tmp 2>/dev/null || true

echo "=== Attempting rustup install 1.92.0 ==="
rustup install 1.92.0 2>&1 || echo "rustup install failed with exit code $?"

echo "=== Overriding RUSTUP_TOOLCHAIN ==="
export RUSTUP_TOOLCHAIN=1.92.0
rustc --version || echo "rustc --version failed after override"

cd ${WORKSPACE}/srcdir/RustyIceberg.jl/iceberg_rust_ffi/

cargo rustc --release --lib --crate-type=cdylib

# Install the library
install -Dvm 755 "target/${rust_target}/release/libiceberg_rust_ffi.${dlext}" "${libdir}/libiceberg_rust_ffi.${dlext}"
"""

# We could potentially support more platforms, if required.
# Except perhaps i686 Windows and Musl systems.
platforms = [
    Platform("aarch64", "macos"),
    Platform("x86_64",  "linux"),
    Platform("x86_64",  "macos"),
    Platform("aarch64", "linux"),
]

# The products that we will ensure are always built
products = [
    LibraryProduct("libiceberg_rust_ffi", :libiceberg_rust_ffi),
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
    Dependency("OpenSSL_jll"; compat="3.0.14")
]

# Build the tarballs
build_tarballs(
    ARGS, name, version, sources, script, platforms, products, dependencies;
    compilers=[:c, :rust], julia_compat="1.10", preferred_gcc_version=v"5", dont_dlopen=true,
)
