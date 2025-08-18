#!/bin/bash

# Script to update Artifacts.toml with new release version URLs and SHA256 hashes
# Usage: ./update_artifacts.sh

ARTIFACTS_FILE="Artifacts.toml"
BACKUP_FILE="Artifacts.toml.backup"

# Create backup
cp "$ARTIFACTS_FILE" "$BACKUP_FILE"
echo "Created backup: $BACKUP_FILE"

# Update x86_64-linux-gnu URL, SHA256, and git-tree-sha1
# New URL: https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v0.1.1%2B0/iceberg_rust_ffi.v0.1.1.x86_64-linux-gnu.tar.gz
# Note: You'll need to replace the SHA256 and git-tree-sha1 below with the actual values for the new file
NEW_X86_64_SHA256="YOUR_NEW_SHA256_HERE"  # Replace with actual SHA256
NEW_X86_64_GIT_TREE_SHA1="YOUR_NEW_GIT_TREE_SHA1_HERE"  # Replace with actual git-tree-sha1

sed -i.tmp \
    -e 's|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.x86_64-linux-gnu.tar.gz|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v0.1.1%2B0/iceberg_rust_ffi.v0.1.1.x86_64-linux-gnu.tar.gz|g' \
    -e "s/sha256 = \"680215aae0ce2d06fa8ce184e48ca0d7f6de660063a40151a300a7cc6198aa3a\"/sha256 = \"$NEW_X86_64_SHA256\"/g" \
    -e "s/git-tree-sha1 = \"5970fd65d3ea8d73c0491b35fcdb3d94aa8205c4\"/git-tree-sha1 = \"$NEW_X86_64_GIT_TREE_SHA1\"/g" \
    "$ARTIFACTS_FILE"

# Update aarch64-apple-darwin URL, SHA256, and git-tree-sha1
# New URL: https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v0.1.1%2B0/iceberg_rust_ffi.v0.1.1.aarch64-apple-darwin.tar.gz
# Note: You'll need to replace the SHA256 and git-tree-sha1 below with the actual values for the new file
NEW_AARCH64_SHA256="YOUR_NEW_SHA256_HERE"  # Replace with actual SHA256
NEW_AARCH64_GIT_TREE_SHA1="YOUR_NEW_GIT_TREE_SHA1_HERE"  # Replace with actual git-tree-sha1

sed -i.tmp \
    -e 's|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.aarch64-apple-darwin.tar.gz|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v0.1.1%2B0/iceberg_rust_ffi.v0.1.1.aarch64-apple-darwin.tar.gz|g' \
    -e "s/sha256 = \"b62207f943deabcbc34995e35c2d17cae1c0f1376896a190c8c1b0d67719055f\"/sha256 = \"$NEW_AARCH64_SHA256\"/g" \
    -e "s/git-tree-sha1 = \"f5202bdb3704e2c4c461c51ce4e5a1a90000c650\"/git-tree-sha1 = \"$NEW_AARCH64_GIT_TREE_SHA1\"/g" \
    "$ARTIFACTS_FILE"

# Remove temporary files
rm -f "$ARTIFACTS_FILE.tmp"

echo "Updated $ARTIFACTS_FILE with new URLs for version 0.1.1"
echo "IMPORTANT: Please replace the placeholder SHA256 and git-tree-sha1 values with actual hashes:"
echo "  - For x86_64-linux-gnu: $NEW_X86_64_SHA256 and $NEW_X86_64_GIT_TREE_SHA1"
echo "  - For aarch64-apple-darwin: $NEW_AARCH64_SHA256 and $NEW_AARCH64_GIT_TREE_SHA1"
echo ""
echo "To get the actual SHA256 hashes, you can run:"
echo "  curl -L <URL> | sha256sum"
echo ""
echo "To calculate git-tree-sha1, you can use Julia's Pkg.Artifacts module:"
echo "  using Pkg.Artifacts"
echo "  tree_hash = artifact_tree_hash(\"path/to/extracted/artifact\")" 