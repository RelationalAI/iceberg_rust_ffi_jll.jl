using BinaryBuilder

name = "iceberg_rust_ffi"
version = v"0.1.0"

sources = [
    GitSource("https://github.com/RelationalAI/RustyIceberg.jl.git", "a03ff377ce7cc250e6e64429e5cdeefcec19612c"),
]

# Bash recipe for building across all platforms
script = raw"""
cd ${WORKSPACE}/srcdir/iceberg_rust_ffi/

# Install and use a custom Rust version not bundled with BinaryBuilderBase
rustup install 1.92.0
rustup default 1.92.0

cargo rustc --release --lib --crate-type=cdylib

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
