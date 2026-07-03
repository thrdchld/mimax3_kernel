# Kernel Build Scripts

This directory contains helper scripts for building and packaging the Nitrogen Kernel.

## 📁 Files

### build_aroma_installer.sh
Creates a professional AROMA installer package for easy kernel installation on Android devices.

**Usage:**
```bash
bash build_aroma_installer.sh <boot.img> <version> <commit> <date> <build_number> <build_type>
```

**Parameters:**
- `<boot.img>` - Path to compiled boot image
- `<version>` - Kernel version (e.g., "4.4.302")
- `<commit>` - Git commit hash (e.g., "abc1234")
- `<date>` - Build date in YYYYMMDD format
- `<build_number>` - Build number (e.g., "1")
- `<build_type>` - Build type: stable, beta, or nightly

**Output:**
- `nitrogen_aroma_installer.zip` - Ready-to-flash installer package

**Example:**
```bash
bash build_aroma_installer.sh out/boot.img "4.4.302" "a1b2c3d" "20260703" "42" "stable"
```

### build-local.sh
Complete local build script that handles the entire kernel compilation process.

**Usage:**
```bash
bash build-local.sh
```

**What it does:**
1. ✓ Checks build prerequisites (gcc, make, cross-compiler)
2. ✓ Cleans previous build output
3. ✓ Loads nitrogen_defconfig
4. ✓ Compiles kernel using all available CPU cores
5. ✓ Creates boot.img

**Output:**
- `out/arch/arm64/boot/Image` - Compiled kernel
- `out/boot.img` - Bootable image
- `build.log` - Build output log

**Requirements:**
- Ubuntu/Debian system
- `aarch64-linux-gnu-gcc` cross-compiler
- Standard build tools (make, gcc, etc.)

## 🚀 Quick Start

### Local Build (Testing)
```bash
# One-command build
bash build-local.sh

# Creates out/boot.img
```

### GitHub Actions (Automatic)
```bash
# Push to main branch
git push origin main

# Or manually trigger from Actions tab
# Workflow: "Build Kernel with AROMA Installer"
```

### Full Pipeline (Local)
```bash
# 1. Build kernel
bash build-local.sh

# 2. Create AROMA installer
bash build_aroma_installer.sh out/boot.img "4.4.302" "abc1234" "20260703" "1" "stable"

# Results:
# - out/boot.img (raw image for fastboot)
# - nitrogen_aroma_installer.zip (for recovery)
```

## 🔧 Manual Build Commands

For reference, here are the manual build commands:

```bash
# Set environment
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

# Load defconfig
make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- nitrogen_defconfig

# Build
make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
```

## 📊 Build Statistics

### Typical Build Time
- **First build** (clean): 20-30 minutes
- **Incremental** (with cache): 5-10 minutes
- **Parallel jobs**: Automatically uses all CPU cores

### Output Sizes
- **Kernel Image**: 8-15 MB
- **boot.img**: 10-30 MB
- **AROMA package**: 20-60 MB

## 🐛 Troubleshooting

### "gcc-aarch64-linux-gnu: command not found"
```bash
sudo apt-get install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
```

### "nitrogen_defconfig: No such file"
```bash
# Make sure you're in kernel root directory
cd /workspaces/mimax3_kernel
ls arch/arm64/configs/nitrogen_defconfig
```

### Build fails halfway
```bash
# Check if all dependencies installed
sudo apt-get install build-essential libncurses-dev bison flex libssl-dev libelf-dev

# Clean and retry
rm -rf out
bash build-local.sh
```

### AROMA zip creation fails
```bash
# Ensure zip command available
sudo apt-get install zip unzip

# Check boot.img exists
ls -lh out/boot.img

# Retry AROMA creation
bash build_aroma_installer.sh out/boot.img "4.4.302" "abc" "20260703" "1" "stable"
```

## 📱 Device Installation

### Using AROMA (Recommended)
```
1. Copy nitrogen_aroma_installer.zip to device
2. Boot to recovery (TWRP)
3. Install > Select nitrogen_aroma_installer.zip
4. Swipe to confirm
5. Reboot to system
```

### Using Fastboot (Direct)
```bash
fastboot flash boot out/boot.img
fastboot reboot
```

### Using ADB Recovery
```bash
adb push out/boot.img /tmp/
adb shell dd if=/tmp/boot.img of=/dev/block/bootdevice/by-name/boot
adb reboot
```

## 📝 Notes

- Scripts use ANSI color output for better readability
- All scripts set `set -e` to exit on first error
- Parallel builds use `nproc` to detect CPU count
- Build logs saved for debugging

## 🔗 Related Documentation

- See [BUILD_GUIDE.md](../BUILD_GUIDE.md) for comprehensive setup guide
- See [.github/workflows/README.md](../.github/workflows/README.md) for workflow details
- See kernel README for compile instructions

---

**Last Updated:** July 2026
