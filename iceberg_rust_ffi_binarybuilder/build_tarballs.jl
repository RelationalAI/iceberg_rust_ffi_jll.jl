using BinaryBuilder

name = "iceberg_rust_ffi"
version = v"0.3.0"

sources = [
    GitSource("https://github.com/RelationalAI/RustyIceberg.jl.git", "a23022e750770ddb983dbaa7f3f103753f2813aa"),
]

# Bash recipe for building across all platforms
script = raw"""
set -x

echo "=== Disk space ==="
df -h / /workspace /tmp 2>/dev/null || true

echo "=== Installing Rust 1.92.0 to /workspace (host-mounted, more disk space) ==="
export RUSTUP_HOME=/workspace/rustup
export CARGO_HOME=/workspace/cargo
mkdir -p ${RUSTUP_HOME} ${CARGO_HOME}/bin

# Use the existing rustup binary to bootstrap into the new RUSTUP_HOME
/opt/x86_64-linux-musl/bin/rustup-init -y --default-toolchain 1.92.0 --no-modify-path 2>&1

# Put the new cargo/rustc on PATH ahead of wrappers
export PATH="${CARGO_HOME}/bin:${PATH}"
unset RUSTUP_TOOLCHAIN

echo "=== Verify ==="
which rustc
rustc --version
which cargo
cargo --version

cd ${WORKSPACE}/srcdir/RustyIceberg.jl/iceberg_rust_ffi/

cargo rustc --release --lib --crate-type=cdylib --target=${rust_target}

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
