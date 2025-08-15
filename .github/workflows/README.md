# Build and Deploy Workflow

This workflow allows you to manually trigger the building and deployment of tarballs for the `iceberg_rust_ffi_jll` package.

## Usage

1. Go to the **Actions** tab in the GitHub repository
2. Select **Build and Deploy Tarballs** from the workflows list
3. Click **Run workflow**
4. Fill in the parameters:
   - **target_branch**: The branch to build and deploy from (default: `main`, but deployment to `main` is not allowed)
   - **targets**: Target platforms to build for, comma-separated (default: `x86_64-linux-gnu`)
   - **version**: Optional version to build (if not specified, uses current version)

**Note**: For safety reasons, deployment to the `main` branch is not allowed. Please use a feature branch or release branch instead.

## Parameters

### target_branch
- **Description**: Branch to build and deploy from
- **Required**: Yes
- **Default**: `main`
- **Type**: String
- **Note**: Deployment to `main` branch is not allowed for safety reasons. Please use a different branch.

### targets
- **Description**: Target platforms to build for (comma-separated)
- **Required**: No
- **Default**: `x86_64-linux-gnu`
- **Type**: String
- **Examples**: 
  - `x86_64-linux-gnu` (single target)
  - `x86_64-linux-gnu,aarch64-apple-darwin` (multiple targets)

### version
- **Description**: Version to build (optional, will use current version if not specified)
- **Required**: No
- **Type**: String
- **Examples**: `0.1.0`, `0.2.0-alpha`

## What the workflow does

1. **Checkout**: Checks out the specified branch
2. **Setup Julia**: Sets up Julia 1.10 environment
3. **Install dependencies**: Installs project dependencies
4. **Show version**: Displays the current version being built
5. **Build tarballs**: Runs `build_tarballs.jl` with the specified parameters
6. **Update Artifacts.toml**: Updates the Artifacts.toml file with new tarball URLs
7. **Show updated file**: Displays the updated Artifacts.toml contents
8. **Commit and push**: Commits the updated Artifacts.toml to the specified branch

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