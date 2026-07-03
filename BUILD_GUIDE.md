# Nitrogen Kernel - Build System Setup & Guide

Complete guide for setting up and using the automated Nitrogen Kernel build system with GitHub Actions and professional AROMA installer generation.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [GitHub Actions Setup](#github-actions-setup)
5. [Local Build](#local-build)
6. [AROMA Installer Details](#aroma-installer-details)
7. [Release & Distribution](#release--distribution)
8. [Troubleshooting](#troubleshooting)

## Overview

This project includes:
- **Automated GitHub Actions** for continuous kernel building
- **Professional AROMA Installer** for easy device flashing
- **Boot image generation** for arm64 architecture
- **Release management** with version tracking and checksums
- **Local build scripts** for testing and development

### Project Structure

```
.github/
  workflows/
    build-kernel.yml           # Main GitHub Actions workflow
    README.md                  # Workflow documentation

scripts/
  build-local.sh              # Local build script for testing
  build_aroma_installer.sh    # AROMA installer generation script

.version                       # Kernel version file
```

## Prerequisites

### For Local Building

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  libncurses-dev \
  bison \
  flex \
  libssl-dev \
  libelf-dev \
  bc \
  u-boot-tools \
  kmod \
  cpio \
  squashfs-tools \
  zip \
  unzip \
  git \
  curl \
  gcc-aarch64-linux-gnu \
  binutils-aarch64-linux-gnu \
  libgcc-aarch64-linux-gnu-dev
```

### For GitHub Actions

- GitHub repository with workflow permissions enabled
- Sufficient storage for build artifacts
- Git tags support for releases

## Quick Start

### 1. Enable GitHub Actions

1. Go to repository Settings
2. Navigate to Actions > General
3. Ensure "Allow all actions and reusable workflows" is selected
4. Save changes

### 2. Create Initial Release Tag

```bash
git tag -a v4.4.302 -m "Nitrogen Kernel v4.4.302"
git push origin v4.4.302
```

### 3. Trigger Workflow

**Option A: Automatic (on push)**
```bash
git push origin main
```

**Option B: Manual (Actions tab)**
1. Go to Actions tab
2. Select "Build Kernel with AROMA Installer"
3. Click "Run workflow"
4. Select build type (stable/beta/nightly)

### 4. Monitor Build

1. Go to Actions tab
2. Click the running workflow
3. Expand job details to see live output
4. Wait for completion (~15-30 minutes)

## GitHub Actions Setup

### Workflow Triggers

```yaml
# Automatic triggers:
- Push to main, master, or 4.4.* branches
- Tag creation (v*)
- Manual workflow dispatch
```

### Build Configuration

| Setting | Value |
|---------|-------|
| Defconfig | `nitrogen_defconfig` |
| Architecture | `arm64` |
| Cross-compiler | `aarch64-linux-gnu-` |
| Device | Nitrogen (Mi Max 3) |
| Kernel Version | 4.4.302 |

### Workflow Steps

1. **Checkout** - Clone repository with full history
2. **Build Info** - Gather version, commit, date info
3. **Setup** - Install build tools and dependencies
4. **Build Kernel** - Compile with nitrogen_defconfig
5. **Build boot.img** - Create bootable image
6. **AROMA Package** - Generate installer package
7. **Artifacts** - Prepare release files and checksums
8. **Release** - Upload to GitHub Releases
9. **Summary** - Report build status

### Output Artifacts

The workflow generates:

1. **boot.img** - Raw kernel image (~10-30 MB)
2. **nitrogen_aroma_installer.zip** - AROMA package (~15-50 MB)
3. **Checksums** - SHA256 verification files
4. **Release Notes** - Installation guide and features

## Local Build

### Method 1: Using build-local.sh (Recommended)

```bash
# Make script executable
chmod +x scripts/build-local.sh

# Run build
bash scripts/build-local.sh

# Output:
# - out/arch/arm64/boot/Image
# - out/boot.img
```

### Method 2: Manual Build

```bash
# Set variables
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

# Create output directory
mkdir -p out

# Load defconfig
make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- nitrogen_defconfig

# Build kernel (uses all CPU cores)
make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)

# Result: out/arch/arm64/boot/Image
```

### Building AROMA Installer (Local)

```bash
# After building kernel:
bash scripts/build_aroma_installer.sh \
  out/boot.img \
  "4.4.302" \
  "abc1234" \
  "20260703" \
  "1" \
  "stable"

# Output: nitrogen_aroma_installer.zip
```

## AROMA Installer Details

### What is AROMA?

AROMA Installer is a professional installation framework for Android recovery flashing. It provides:
- **Visual Interface** - User-friendly step-by-step wizard
- **Device Verification** - Ensures compatibility before installing
- **Backup Support** - Optional backup of current boot image
- **Progress Tracking** - Real-time installation feedback
- **Professional UI** - Similar to commercial ROM installers

### AROMA Package Contents

```
nitrogen_aroma_installer.zip
├── META-INF/
│   ├── MANIFEST.MF
│   └── com/google/android/
│       ├── aroma-config       # Main installer configuration
│       ├── updater-script     # Installation script
│       └── edgecase-script    # Error handling
└── system/
    ├── boot/
    │   └── boot.img           # Kernel image
    └── info/
        └── build.prop         # Build information
```

### Installation Steps (On Device)

```
1. Welcome Screen
   ├─ Kernel Version: 4.4.302
   ├─ Build Date: 20260703
   └─ Commit: abc1234

2. Device Compatibility Check
   └─ Verifies device type

3. Installation Options
   ├─ Standard Installation
   ├─ With Backup
   └─ Advanced Options

4. Pre-Installation Verification
   └─ Checks storage, permissions, etc.

5. Installation Confirmation
   └─ Swipe to proceed

6. Installation Progress
   └─ Flashing boot.img to partition

7. Completion
   └─ Reboot to system
```

### AROMA Configuration Files

#### aroma-config
Main installation interface:
- Language selection
- Welcome page with version info
- Device compatibility checks
- Installation option menus
- Pre-installation verification
- Installation confirmation
- Progress tracking

#### updater-script
Actual installation commands:
- Device verification
- boot.img partition location check
- File extraction to boot partition
- Success confirmation

#### edgecase-script
Error handling:
- Device state checks
- Partition availability
- USB debugging status

### Build Metadata

Each installer includes build information for version tracking:

```properties
ro.kernel.version=4.4.302
ro.kernel.commit=abc1234
ro.kernel.build_date=20260703
ro.kernel.build_number=1
ro.kernel.build_type=stable
ro.kernel.device=nitrogen
ro.kernel.arch=arm64
```

## Release & Distribution

### Automatic Release Creation

When you push a tag:
```bash
git tag -a v4.4.302 -m "Release v4.4.302"
git push origin v4.4.302
```

The workflow automatically:
1. Builds the kernel
2. Creates GitHub Release
3. Uploads artifacts with checksums
4. Generates release notes

### Manual Release

1. Go to repository
2. Releases > Draft new release
3. Upload built artifacts:
   - boot.img
   - nitrogen_aroma_installer.zip
   - Checksums (.sha256 files)

### Distribution Methods

#### Method 1: GitHub Releases
- Download directly from releases page
- All versions available
- Includes checksums and notes

#### Method 2: Direct Download
- Copy release download URL
- Use `wget` or `curl` to download
- Verify checksums

#### Method 3: Device Flash
- Copy zip to device storage
- Boot to recovery (TWRP)
- Install from zip

## Troubleshooting

### Build Fails

**Symptom:** Workflow shows red X

**Solutions:**
1. Check build logs:
   - Go to Actions > Click workflow > Expand job
   - Look for error messages

2. Common issues:
   - Missing dependencies: Run setup commands again
   - Defconfig not found: Verify `arch/arm64/configs/nitrogen_defconfig` exists
   - Partition info wrong: Check device-specific boot partition path

### AROMA Installer Issues

**Symptom:** Installation fails in recovery

**Causes & Fixes:**
1. Wrong device: Ensure using Nitrogen device
2. Recovery incompatible: Use TWRP or similar
3. File corrupted: Verify SHA256 checksums
4. Wrong partition: Check updater-script device path

### Boot Image Problems

**Symptom:** Device won't boot after flashing

**Steps:**
1. Restore previous boot.img
2. Check kernel config conflicts
3. Verify device-specific features enabled
4. Try previous kernel version

### Local Build Issues

**Problem:** "aarch64-linux-gnu-gcc not found"

```bash
# Install cross-compiler
sudo apt-get install gcc-aarch64-linux-gnu

# Or use system gcc (if on ARM64 system)
unset CROSS_COMPILE
make ARCH=arm64 -j$(nproc)
```

**Problem:** "Image not found"

```bash
# Check if build succeeded
ls -la out/arch/arm64/boot/

# Look for errors in build.log
tail -100 build.log

# Rebuild with verbose output
make O=out ARCH=arm64 V=1 -j1
```

## Advanced Configuration

### Modifying Defconfig

```bash
# Edit defconfig
nano arch/arm64/configs/nitrogen_defconfig

# Or use menuconfig
make O=out ARCH=arm64 menuconfig
make O=out ARCH=arm64 savedefconfig
cp out/.config arch/arm64/configs/nitrogen_defconfig
```

### Custom Build Variants

Create multiple defconfigs:
```
arch/arm64/configs/
├── nitrogen_defconfig          # Default
├── nitrogen_performance_defconfig
├── nitrogen_battery_saver_defconfig
└── nitrogen_debug_defconfig
```

### Using Different Branches

The workflow supports multiple branches:
```bash
# Branch-specific builds
git checkout -b kernel-4.4
git push origin kernel-4.4
# Workflow automatically triggers
```

## Performance Optimization

### Build Time

- **Parallel Jobs**: Uses all CPU cores (`-j$(nproc)`)
- **Typical Time**: 15-30 minutes on 4-core system
- **Faster**: More CPU cores = faster builds

### Artifact Size

- **boot.img**: ~10-30 MB (compressed)
- **AROMA package**: ~15-50 MB (includes metadata)
- **Optimal**: zip compression reduces size ~50%

## Security & Verification

### Checksum Verification

```bash
# Download files
wget https://github.com/.../boot.img
wget https://github.com/.../boot.img.sha256

# Verify
sha256sum -c boot.img.sha256

# Output: boot.img: OK
```

### Build Reproducibility

Each build includes:
- Exact kernel version
- Git commit hash
- Build date and time
- Build number
- Build type (stable/beta/nightly)

## Support & Resources

### Documentation
- [Linux Kernel Documentation](https://www.kernel.org/)
- [AROMA Installer Documentation](https://aroma.sourceforge.io/)
- [ARM64 Architecture Guide](https://www.kernel.org/doc/html/latest/arm64/)

### Getting Help
1. Check GitHub Issues
2. Review workflow logs
3. Check kernel build documentation
4. Post on XDA Forums

### Reporting Issues

When reporting build issues, include:
- Workflow run number
- Build logs (last 50 lines)
- Device information
- Reproduction steps

## License

This build system is provided as-is. See LICENSE file for details.

---

**Last Updated:** July 2026
**Kernel Version:** 4.4.302
**Build System:** GitHub Actions + AROMA Installer
