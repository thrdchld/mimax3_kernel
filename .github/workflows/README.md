# Nitrogen Kernel Build System

This directory contains the GitHub Actions workflow for building the Nitrogen Kernel with professional AROMA installer support.

## Files Overview

- **build-kernel.yml** - Main GitHub Actions workflow that:
  - Checks out the kernel source code
  - Sets up the build environment with necessary tools
  - Compiles the kernel using nitrogen_defconfig
  - Creates boot.img
  - Builds an AROMA installer package
  - Generates release notes and checksums
  - Uploads artifacts to GitHub releases

## Workflow Features

### Build Configuration
- **Architecture**: arm64 (ARM 64-bit)
- **Device**: Nitrogen (Mi Max 3)
- **Defconfig**: nitrogen_defconfig from arch/arm64/configs/
- **Cross Compiler**: aarch64-linux-gnu

### Output Artifacts
1. **boot.img** - Raw kernel boot image
2. **nitrogen_aroma_installer.zip** - Professional AROMA installer package
3. **boot.img.sha256** - SHA256 checksum for boot.img
4. **nitrogen_aroma_installer.zip.sha256** - SHA256 checksum for AROMA package
5. **RELEASE_NOTES.txt** - Installation instructions and feature list

### Build Triggers
The workflow runs automatically on:
- Pushes to main/master/4.4.* branches
- Tag creation (v*)
- Manual workflow dispatch with build type selection (stable/beta/nightly)

### Build Types
- **stable** - Production ready builds
- **beta** - Pre-release testing builds
- **nightly** - Daily development builds

## AROMA Installer Features

The AROMA installer package includes:
- Professional installer interface with step-by-step guidance
- Device compatibility verification
- Installation option selection (standard, with backup, advanced)
- Pre-installation checks and verification
- Boot image flashing to the correct partition
- Build information display (version, date, commit hash)
- Installation progress tracking

## Usage

### Triggering a Build

1. **Automatic build** - Push commits or tags to trigger automatically
2. **Manual build** - Go to Actions > Build Kernel with AROMA Installer > Run workflow > Select build type

### Installation on Device

#### Method 1: AROMA Installer (Recommended)
1. Copy `nitrogen_aroma_installer.zip` to your device
2. Reboot to recovery (TWRP or similar)
3. Select Install > Choose `nitrogen_aroma_installer.zip`
4. Swipe to confirm
5. Reboot to system

#### Method 2: Fastboot (Direct)
1. Download `boot.img`
2. Connect device to computer in bootloader mode
3. Run: `fastboot flash boot boot.img`
4. Reboot: `fastboot reboot`

#### Method 3: Recovery Manual (Advanced)
1. Push boot.img: `adb push boot.img /tmp/`
2. Use recovery's install/flash menu to flash the image
3. Reboot device

## Configuration Files

### scripts/build_aroma_installer.sh
This script handles the creation of the AROMA installer package with:
- Directory structure creation
- Boot image packaging
- AROMA configuration generation
- Installation script creation
- Package compression and verification

### Environment Variables
- `KERNEL_DEFCONFIG` - Set to `nitrogen_defconfig`
- `KERNEL_ARCH` - Set to `arm64`
- `CROSS_COMPILE` - Set to `aarch64-linux-gnu-`
- `OUT_DIR` - Output directory (default: `out`)

## Build Information in AROMA

Each build includes metadata:
- **Kernel Version** - From .version file
- **Build Number** - GitHub Actions run number
- **Build Type** - stable/beta/nightly
- **Build Date & Time** - Timestamp of build
- **Git Commit** - Short SHA of build commit
- **Branch** - Git branch name
- **Device** - Nitrogen
- **Architecture** - arm64

## Security & Verification

All builds include:
- SHA256 checksums for integrity verification
- Git commit tracking for transparency
- Build metadata for version management
- Professional installer interface for confidence

## Troubleshooting

### If kernel doesn't boot:
1. Verify device compatibility
2. Flash to correct boot partition
3. Check if using latest AROMA installer
4. Try previous build version

### If AROMA installer fails:
1. Ensure recovery supports AROMA (TWRP recommended)
2. Check available storage space
3. Verify file integrity using SHA256 checksums

## Support

For issues or questions:
- Check GitHub Issues on the repository
- Review build logs in Actions
- Verify device compatibility (Nitrogen/Mi Max 3)
