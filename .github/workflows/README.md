# Build and Deploy Workflow

This workflow allows you to manually trigger the building and deployment of tarballs for the `iceberg_rust_ffi_jll` package. It creates a new branch with the specified name and updates the version in `build_tarballs.jl`.

## Usage

1. Go to the **Actions** tab in the GitHub repository
2. Select **Build and Deploy Tarballs** from the workflows list
3. Click **Run workflow**
4. Fill in the parameters:
   - **branch_name**: Name for the new branch to create (must not exist)
   - **base_version**: Base version to use (e.g., "0.1.0")
   - **targets**: Target platforms to build for, comma-separated (default: `x86_64-linux-gnu`)

**Note**: The workflow will create a new branch and fail if a branch with the same name already exists.

## What gets updated in build_tarballs.jl

The workflow updates two fields in `build_tarballs.jl`:

1. **Version field**: `version = v"{base_version}-{branch_name}"`
   - Example: If base_version is "0.1.0" and branch_name is "feature/new-version", it becomes `version = v"0.1.0-feature/new-version"`

2. **GitSource commit SHA**: Updates the commit SHA in the GitSource line to the current commit
   - Example: `GitSource("https://github.com/RelationalAI/iceberg_rust_ffi.git", "abc123...")` gets updated with the current commit SHA

## Parameters

### branch_name
- **Description**: Name for the new branch to create (must not exist)
- **Required**: Yes
- **Type**: String
- **Examples**: `feature/new-version`, `release/v0.2.0`, `hotfix/bug-fix`
- **Note**: The workflow will fail if a branch with this name already exists.

### base_version
- **Description**: Base version to use (e.g., "0.1.0")
- **Required**: Yes
- **Type**: String
- **Examples**: `0.1.0`, `0.2.0`, `1.0.0`
- **Note**: The final version will be `{base_version}-{branch_name}`

### targets
- **Description**: Target platforms to build for (comma-separated)
- **Required**: No
- **Default**: `x86_64-linux-gnu`
- **Type**: String
- **Examples**: 
  - `x86_64-linux-gnu` (single target)
  - `x86_64-linux-gnu,aarch64-apple-darwin` (multiple targets)

## What the workflow does

1. **Checkout**: Checks out the main branch
2. **Validate branch name**: Ensures the new branch name doesn't exist and isn't "main"
3. **Create new branch**: Creates and checks out a new branch with the specified name
4. **Setup Julia**: Sets up Julia 1.7.3 environment
5. **Install dependencies**: Installs project dependencies
6. **Update version and commit SHA**: Updates `build_tarballs.jl` with version `{base_version}-{branch_name}` and current commit SHA
7. **Build tarballs**: Runs `build_tarballs.jl` with the updated version and commit SHA
8. **Update Artifacts.toml**: Updates the Artifacts.toml file with new tarball URLs
9. **Show updated file**: Displays the updated Artifacts.toml contents
10. **Commit and push**: Commits both `build_tarballs.jl` and `Artifacts.toml` to the new branch

## Supported platforms

The workflow supports the following platforms (as defined in `build_tarballs.jl`):
- `aarch64-apple-darwin` (Apple Silicon macOS)
- `x86_64-linux-gnu` (x86_64 Linux)
- `x86_64-apple-darwin` (Intel macOS)
- `aarch64-linux-gnu` (ARM64 Linux)

## Permissions

The workflow requires the following permissions:
- `contents: write` - To commit changes to the repository
- `packages: write` - To deploy tarballs to GitHub Packages

## Environment variables

The workflow sets the following environment variables for BinaryBuilder:
- `BINARYBUILDER_AUTOMATIC_APPLE: true` - Enables automatic Apple platform handling
- `BINARYBUILDER_RUNNER: true` - Enables BinaryBuilder runner mode 