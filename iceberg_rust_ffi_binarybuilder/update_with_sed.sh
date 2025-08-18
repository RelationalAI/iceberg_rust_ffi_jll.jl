#!/bin/bash

# Simple sed-based script to update Artifacts.toml
# Usage: ./update_with_sed.sh [VERSION]
# Example: ./update_with_sed.sh 0.1.1

VERSION=${1:-0.1.1}
ARTIFACTS_FILE="Artifacts.toml"

# Create backup
cp "$ARTIFACTS_FILE" "${ARTIFACTS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

echo "Updating Artifacts.toml to version $VERSION..."

# Update URLs, SHA256 hashes, and git-tree-sha1 using sed
# Note: You'll need to replace the SHA256 and git-tree-sha1 values with actual hashes

# For x86_64-linux-gnu
sed -i.tmp \
    -e "s|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.x86_64-linux-gnu.tar.gz|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v${VERSION}%2B0/iceberg_rust_ffi.v${VERSION}.x86_64-linux-gnu.tar.gz|g" \
    -e 's/sha256 = "680215aae0ce2d06fa8ce184e48ca0d7f6de660063a40151a300a7cc6198aa3a"/sha256 = "NEW_X86_64_SHA256_HERE"/g' \
    -e 's/git-tree-sha1 = "5970fd65d3ea8d73c0491b35fcdb3d94aa8205c4"/git-tree-sha1 = "NEW_X86_64_GIT_TREE_SHA1_HERE"/g' \
    "$ARTIFACTS_FILE"

# For aarch64-apple-darwin
sed -i.tmp \
    -e "s|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.aarch64-apple-darwin.tar.gz|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v${VERSION}%2B0/iceberg_rust_ffi.v${VERSION}.aarch64-apple-darwin.tar.gz|g" \
    -e 's/sha256 = "b62207f943deabcbc34995e35c2d17cae1c0f1376896a190c8c1b0d67719055f"/sha256 = "NEW_AARCH64_SHA256_HERE"/g' \
    -e 's/git-tree-sha1 = "f5202bdb3704e2c4c461c51ce4e5a1a90000c650"/git-tree-sha1 = "NEW_AARCH64_GIT_TREE_SHA1_HERE"/g' \
    "$ARTIFACTS_FILE"

# Remove temporary file
rm -f "$ARTIFACTS_FILE.tmp"

echo "Updated URLs in $ARTIFACTS_FILE"
echo ""
echo "IMPORTANT: You need to manually replace the SHA256 and git-tree-sha1 values:"
echo "  - Replace 'NEW_X86_64_SHA256_HERE' with actual SHA256 for x86_64-linux-gnu"
echo "  - Replace 'NEW_AARCH64_SHA256_HERE' with actual SHA256 for aarch64-apple-darwin"
echo "  - Replace 'NEW_X86_64_GIT_TREE_SHA1_HERE' with actual git-tree-sha1 for x86_64-linux-gnu"
echo "  - Replace 'NEW_AARCH64_GIT_TREE_SHA1_HERE' with actual git-tree-sha1 for aarch64-apple-darwin"
echo ""
echo "To get the actual SHA256 hashes, run:"
echo "  curl -L 'https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v${VERSION}%2B0/iceberg_rust_ffi.v${VERSION}.x86_64-linux-gnu.tar.gz' | sha256sum"
echo "  curl -L 'https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v${VERSION}%2B0/iceberg_rust_ffi.v${VERSION}.aarch64-apple-darwin.tar.gz' | sha256sum"
echo ""
echo "To calculate git-tree-sha1, you can use Julia's Pkg.Artifacts module:"
echo "  using Pkg.Artifacts"
echo "  tree_hash = artifact_tree_hash(\"path/to/extracted/artifact\")" 