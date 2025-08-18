#!/bin/bash

# Simplified script to update Artifacts.toml for GitHub workflow
# Usage: ./update_artifacts_workflow.sh [VERSION]

set -e

# Get version from argument or default
VERSION=${1:-0.1.1}
ARTIFACTS_FILE="../Artifacts.toml"
BACKUP_FILE="../Artifacts.toml.backup.$(date +%Y%m%d_%H%M%S)"

echo "Updating Artifacts.toml to version $VERSION"

# Create backup
cp "$ARTIFACTS_FILE" "$BACKUP_FILE"
echo "Created backup: $BACKUP_FILE"

# URLs for the new version
X86_64_URL="https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v${VERSION}%2B0/iceberg_rust_ffi.v${VERSION}.x86_64-linux-gnu.tar.gz"
AARCH64_URL="https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v${VERSION}%2B0/iceberg_rust_ffi.v${VERSION}.aarch64-apple-darwin.tar.gz"

echo "Fetching SHA256 hashes for version $VERSION..."

# Get SHA256 hashes
X86_64_SHA256=$(curl -L -s "$X86_64_URL" | sha256sum | cut -d' ' -f1)
AARCH64_SHA256=$(curl -L -s "$AARCH64_URL" | sha256sum | cut -d' ' -f1)

echo "SHA256 for x86_64-linux-gnu: $X86_64_SHA256"
echo "SHA256 for aarch64-apple-darwin: $AARCH64_SHA256"

# Create temporary directories for git-tree-sha1 calculation
TEMP_DIR=$(mktemp -d)
X86_64_TEMP="$TEMP_DIR/x86_64-linux-gnu"
AARCH64_TEMP="$TEMP_DIR/aarch64-apple-darwin"

echo "Calculating git-tree-sha1 hashes..."

# Download and extract artifacts for git-tree-sha1 calculation
mkdir -p "$X86_64_TEMP" "$AARCH64_TEMP"
curl -L -s "$X86_64_URL" | tar -xz -C "$X86_64_TEMP"
curl -L -s "$AARCH64_URL" | tar -xz -C "$AARCH64_TEMP"

# Calculate git-tree-sha1 using Julia
X86_64_GIT_TREE_SHA1=$(julia --project=. -e "
using Pkg.Artifacts
tree_hash = artifact_tree_hash(\"$X86_64_TEMP\")
println(tree_hash)
")

AARCH64_GIT_TREE_SHA1=$(julia --project=. -e "
using Pkg.Artifacts
tree_hash = artifact_tree_hash(\"$AARCH64_TEMP\")
println(tree_hash)
")

echo "Git-tree-sha1 for x86_64-linux-gnu: $X86_64_GIT_TREE_SHA1"
echo "Git-tree-sha1 for aarch64-apple-darwin: $AARCH64_GIT_TREE_SHA1"

# Update the file using sed
echo "Updating Artifacts.toml..."

# For x86_64-linux-gnu
sed -i.tmp \
    -e "s|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.x86_64-linux-gnu.tar.gz|$X86_64_URL|g" \
    -e "s/sha256 = \"680215aae0ce2d06fa8ce184e48ca0d7f6de660063a40151a300a7cc6198aa3a\"/sha256 = \"$X86_64_SHA256\"/g" \
    -e "s/git-tree-sha1 = \"5970fd65d3ea8d73c0491b35fcdb3d94aa8205c4\"/git-tree-sha1 = \"$X86_64_GIT_TREE_SHA1\"/g" \
    "$ARTIFACTS_FILE"

# For aarch64-apple-darwin
sed -i.tmp \
    -e "s|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.aarch64-apple-darwin.tar.gz|$AARCH64_URL|g" \
    -e "s/sha256 = \"b62207f943deabcbc34995e35c2d17cae1c0f1376896a190c8c1b0d67719055f\"/sha256 = \"$AARCH64_SHA256\"/g" \
    -e "s/git-tree-sha1 = \"f5202bdb3704e2c4c461c51ce4e5a1a90000c650\"/git-tree-sha1 = \"$AARCH64_GIT_TREE_SHA1\"/g" \
    "$ARTIFACTS_FILE"

# Remove temporary files
rm -f "$ARTIFACTS_FILE.tmp"
rm -rf "$TEMP_DIR"

echo "Successfully updated Artifacts.toml with version $VERSION"
echo "Changes made:"
echo "  - Updated x86_64-linux-gnu URL, SHA256, and git-tree-sha1"
echo "  - Updated aarch64-apple-darwin URL, SHA256, and git-tree-sha1" 