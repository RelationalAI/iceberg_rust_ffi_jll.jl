#!/bin/bash

# Automated script to update Artifacts.toml with new release version URLs and SHA256 hashes
# Usage: ./update_artifacts_auto.sh [VERSION]
# If VERSION is not provided, it will use the default or environment variable

set -e

# Get version from argument, environment variable, or default
VERSION=${1:-${VERSION:-0.1.1}}
ARTIFACTS_FILE="../Artifacts.toml"  # Path relative to iceberg_rust_ffi_binarybuilder directory
BACKUP_FILE="../Artifacts.toml.backup"
TEMP_DIR=$(mktemp -d)

echo "Using version: $VERSION"
echo "Artifacts file: $ARTIFACTS_FILE"

# Create backup
cp "$ARTIFACTS_FILE" "$BACKUP_FILE"
echo "Created backup: $BACKUP_FILE"

# Function to get SHA256 hash from URL
get_sha256() {
    local url="$1"
    echo "Fetching SHA256 for: $url" >&2
    curl -L -s "$url" | sha256sum | cut -d' ' -f1
}

# Function to download and extract artifact, then calculate git-tree-sha1
get_git_tree_sha1() {
    local url="$1"
    local arch="$2"
    local temp_dir="$TEMP_DIR/$arch"
    
    echo "Downloading and extracting artifact for $arch..." >&2
    mkdir -p "$temp_dir"
    
    # Download and extract
    curl -L -s "$url" | tar -xz -C "$temp_dir"
    
    # Calculate git-tree-sha1 using Julia
    echo "Calculating git-tree-sha1 for $arch..." >&2
    julia --project=. -e "
using Pkg.Artifacts
tree_hash = artifact_tree_hash(\"$temp_dir\")
println(tree_hash)
"
}

# URLs for the new version
X86_64_URL="https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v${VERSION}%2B0/iceberg_rust_ffi.v${VERSION}.x86_64-linux-gnu.tar.gz"
AARCH64_URL="https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v${VERSION}%2B0/iceberg_rust_ffi.v${VERSION}.aarch64-apple-darwin.tar.gz"

echo "Fetching SHA256 hashes for version $VERSION..."

# Get SHA256 hashes
X86_64_SHA256=$(get_sha256 "$X86_64_URL")
AARCH64_SHA256=$(get_sha256 "$AARCH64_URL")

echo "SHA256 for x86_64-linux-gnu: $X86_64_SHA256"
echo "SHA256 for aarch64-apple-darwin: $AARCH64_SHA256"

echo "Calculating git-tree-sha1 hashes..."

# Get git-tree-sha1 hashes
X86_64_GIT_TREE_SHA1=$(get_git_tree_sha1 "$X86_64_URL" "x86_64-linux-gnu")
AARCH64_GIT_TREE_SHA1=$(get_git_tree_sha1 "$AARCH64_URL" "aarch64-apple-darwin")

echo "Git-tree-sha1 for x86_64-linux-gnu: $X86_64_GIT_TREE_SHA1"
echo "Git-tree-sha1 for aarch64-apple-darwin: $AARCH64_GIT_TREE_SHA1"

# Update the file using awk for more precise control
awk -v x86_url="$X86_64_URL" \
    -v aarch64_url="$AARCH64_URL" \
    -v x86_sha256="$X86_64_SHA256" \
    -v aarch64_sha256="$AARCH64_SHA256" \
    -v x86_git_tree_sha1="$X86_64_GIT_TREE_SHA1" \
    -v aarch64_git_tree_sha1="$AARCH64_GIT_TREE_SHA1" \
    -v old_x86_url="https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.x86_64-linux-gnu.tar.gz" \
    -v old_aarch64_url="https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.aarch64-apple-darwin.tar.gz" \
    -v old_x86_sha256="680215aae0ce2d06fa8ce184e48ca0d7f6de660063a40151a300a7cc6198aa3a" \
    -v old_aarch64_sha256="b62207f943deabcbc34995e35c2d17cae1c0f1376896a190c8c1b0d67719055f" \
    -v old_x86_git_tree_sha1="5970fd65d3ea8d73c0491b35fcdb3d94aa8205c4" \
    -v old_aarch64_git_tree_sha1="f5202bdb3704e2c4c461c51ce4e5a1a90000c650" \
    '{
        # Replace x86_64 URL, SHA256, and git-tree-sha1
        gsub(old_x86_url, x86_url)
        gsub(old_x86_sha256, x86_sha256)
        gsub(old_x86_git_tree_sha1, x86_git_tree_sha1)
        
        # Replace aarch64 URL, SHA256, and git-tree-sha1
        gsub(old_aarch64_url, aarch64_url)
        gsub(old_aarch64_sha256, aarch64_sha256)
        gsub(old_aarch64_git_tree_sha1, aarch64_git_tree_sha1)
        
        print
    }' "$ARTIFACTS_FILE" > "$ARTIFACTS_FILE.tmp"

mv "$ARTIFACTS_FILE.tmp" "$ARTIFACTS_FILE"

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo "Successfully updated $ARTIFACTS_FILE with version $VERSION URLs, SHA256 hashes, and git-tree-sha1 values"
echo "Changes made:"
echo "  - Updated x86_64-linux-gnu URL, SHA256, and git-tree-sha1"
echo "  - Updated aarch64-apple-darwin URL, SHA256, and git-tree-sha1" 