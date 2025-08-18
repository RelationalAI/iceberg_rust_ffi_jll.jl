# Artifacts.toml Update Scripts

This directory contains scripts to update the `Artifacts.toml` file with new release URLs, SHA256 hashes, and git-tree-sha1 values.

## Scripts Location

All scripts are located in the `iceberg_rust_ffi_binarybuilder/` directory and are designed to work with the GitHub workflow.

## Available Scripts

### 1. `update_with_sed.sh` (Recommended for manual updates)
Simple sed-based script that updates URLs and places placeholder SHA256 values.

**Usage:**
```bash
./update_with_sed.sh [VERSION]
```

**Example:**
```bash
./update_with_sed.sh 0.1.1
```

**What it does:**
- Updates URLs to point to the new version
- Replaces SHA256 values with placeholders
- Creates a timestamped backup
- Provides commands to get actual SHA256 hashes

### 2. `update_artifacts_workflow.sh` (Workflow-specific automated script)
Simplified automated script designed specifically for GitHub workflows.

**Usage:**
```bash
./update_artifacts_workflow.sh [VERSION]
```

**What it does:**
- Downloads the new release files
- Calculates actual SHA256 hashes
- Calculates git-tree-sha1 values using Julia
- Updates URLs, SHA256, and git-tree-sha1 values
- Creates a backup
- Designed for CI/CD environments

### 3. `update_artifacts_auto.sh` (General automated script)
Fully automated script that fetches actual SHA256 hashes and updates everything.

**Usage:**
```bash
./update_artifacts_auto.sh [VERSION]
```

**What it does:**
- Downloads the new release files
- Calculates actual SHA256 hashes
- Calculates git-tree-sha1 values
- Updates URLs, SHA256, and git-tree-sha1 values
- Creates a backup

### 4. `update_artifacts.sh` (Manual SHA256 entry)
Script that requires manual SHA256 values.

**Usage:**
```bash
# Edit the script to set SHA256 values, then run:
./update_artifacts.sh
```

## Manual Update Process

If you prefer to update manually using sed/awk:

### Update URLs only:
```bash
# For x86_64-linux-gnu
sed -i 's|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.x86_64-linux-gnu.tar.gz|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v0.1.1%2B0/iceberg_rust_ffi.v0.1.1.x86_64-linux-gnu.tar.gz|g' Artifacts.toml

# For aarch64-apple-darwin
sed -i 's|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/v0.1.0-alpha/iceberg_rust_ffi.v0.1.0.aarch64-apple-darwin.tar.gz|https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v0.1.1%2B0/iceberg_rust_ffi.v0.1.1.aarch64-apple-darwin.tar.gz|g' Artifacts.toml
```

### Get SHA256 hashes:
```bash
# For x86_64-linux-gnu
curl -L 'https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v0.1.1%2B0/iceberg_rust_ffi.v0.1.1.x86_64-linux-gnu.tar.gz' | sha256sum

# For aarch64-apple-darwin
curl -L 'https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v0.1.1%2B0/iceberg_rust_ffi.v0.1.1.aarch64-apple-darwin.tar.gz' | sha256sum
```

### Calculate git-tree-sha1:
The git-tree-sha1 is a hash that represents the tree structure of the artifact. You can calculate it using Julia:

```julia
using Pkg.Artifacts

# Download and extract the artifact
url = "https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v0.1.1%2B0/iceberg_rust_ffi.v0.1.1.x86_64-linux-gnu.tar.gz"
artifact_path = download_artifact(Base.SHA1("dummy"), url)

# Calculate the git-tree-sha1
tree_hash = artifact_tree_hash(artifact_path)
println(tree_hash)
```

Or you can use the automated script which handles this for you.

## About git-tree-sha1

The `git-tree-sha1` is a Git tree hash that represents the directory structure and file contents of the artifact. It's used by Julia's artifact system to:

1. **Verify integrity**: Ensure the artifact hasn't been tampered with
2. **Deduplication**: Avoid storing identical artifacts multiple times
3. **Consistency**: Ensure all users get the same artifact content

When you update the artifact (new version, different content), the git-tree-sha1 will change because the content has changed.

## URL Pattern

The URL pattern for new releases is:
```
https://github.com/RelationalAI/iceberg_rust_ffi_jll.jl/releases/download/iceberg_rust_ffi-v{VERSION}%2B0/iceberg_rust_ffi.v{VERSION}.{ARCH}.tar.gz
```

Where:
- `{VERSION}` is the version number (e.g., 0.1.1)
- `{ARCH}` is the architecture (x86_64-linux-gnu or aarch64-apple-darwin)

## GitHub Workflow Integration

The `update_artifacts_workflow.sh` script is automatically used by the GitHub workflow in `.github/workflows/build-and-deploy.yml`. The workflow:

1. Detects the version from `build_tarballs.jl`
2. Runs the update script with the detected version
3. Automatically updates URLs, SHA256 hashes, and git-tree-sha1 values
4. Commits the changes to the new branch

No manual intervention is required - the workflow handles everything automatically.

## Backup Files

All scripts create backup files:
- `update_with_sed.sh`: `Artifacts.toml.backup.YYYYMMDD_HHMMSS`
- `update_artifacts_workflow.sh`: `Artifacts.toml.backup.YYYYMMDD_HHMMSS`
- `update_artifacts_auto.sh`: `Artifacts.toml.backup`
- `update_artifacts.sh`: `Artifacts.toml.backup` 