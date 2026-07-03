#!/bin/bash

# Local Kernel Build Script for Testing
# This script can be used to test kernel builds locally before pushing to GitHub

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEFCONFIG="nitrogen_defconfig"
ARCH="arm64"
CROSS_COMPILE="aarch64-linux-gnu-"
JOBS=$(nproc)
OUT_DIR="out"

echo -e "${BLUE}====================================="
echo "Nitrogen Kernel Local Build Script"
echo "=====================================${NC}"

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}[1/5] Checking prerequisites...${NC}"
    
    local missing_tools=()
    
    if ! command -v make &> /dev/null; then
        missing_tools+=("make")
    fi
    
    if ! command -v gcc &> /dev/null; then
        missing_tools+=("gcc")
    fi
    
    if ! command -v aarch64-linux-gnu-gcc &> /dev/null; then
        missing_tools+=("aarch64-linux-gnu-gcc (cross-compiler)")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}✗ Missing tools: ${missing_tools[@]}${NC}"
        echo -e "${YELLOW}Install with: sudo apt-get install build-essential gcc-aarch64-linux-gnu${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All prerequisites met${NC}"
}

# Clean previous builds
clean_build() {
    echo -e "${YELLOW}[2/5] Cleaning previous build...${NC}"
    
    if [ -d "$OUT_DIR" ]; then
        rm -rf "$OUT_DIR"
        echo -e "${GREEN}✓ Cleaned output directory${NC}"
    fi
    
    mkdir -p "$OUT_DIR"
}

# Load defconfig
load_defconfig() {
    echo -e "${YELLOW}[3/5] Loading defconfig...${NC}"
    
    if [ ! -f "arch/$ARCH/configs/$DEFCONFIG" ]; then
        echo -e "${RED}✗ Defconfig not found: arch/$ARCH/configs/$DEFCONFIG${NC}"
        exit 1
    fi
    
    make O="$OUT_DIR" ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" "$DEFCONFIG" \
        || { echo -e "${RED}✗ Failed to load defconfig${NC}"; exit 1; }
    
    echo -e "${GREEN}✓ Defconfig loaded${NC}"
}

# Build kernel
build_kernel() {
    echo -e "${YELLOW}[4/5] Building kernel with $JOBS jobs...${NC}"
    
    make O="$OUT_DIR" ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" \
        -j"$JOBS" 2>&1 | tee build.log
    
    if [ ! -f "$OUT_DIR/arch/$ARCH/boot/Image" ]; then
        echo -e "${RED}✗ Kernel build failed${NC}"
        tail -50 build.log
        exit 1
    fi
    
    echo -e "${GREEN}✓ Kernel built successfully${NC}"
}

# Create boot.img
create_boot_img() {
    echo -e "${YELLOW}[5/5] Creating boot.img...${NC}"
    
    mkdir -p boot_files/kernel boot_files/ramdisk
    
    # Copy kernel
    cp "$OUT_DIR/arch/$ARCH/boot/Image" boot_files/kernel/
    
    # Create minimal ramdisk
    cd boot_files/ramdisk
    mkdir -p proc sys dev
    find . | cpio -H newc -o > ../ramdisk.cpio
    cd ..
    gzip -f ramdisk.cpio
    cd ../..
    
    # Create boot.img
    if command -v mkbootimg &> /dev/null; then
        mkbootimg \
            --kernel boot_files/kernel/Image \
            --ramdisk boot_files/ramdisk/ramdisk.cpio.gz \
            --output "$OUT_DIR/boot.img" \
            --base 0x00000000 \
            --kernel_offset 0x00008000 \
            --ramdisk_offset 0x01000000 \
            --tags_offset 0x00000100 \
            --pagesize 4096
    else
        cat boot_files/kernel/Image boot_files/ramdisk/ramdisk.cpio.gz > "$OUT_DIR/boot.img"
        echo -e "${YELLOW}⚠ mkbootimg not found, created simple boot.img${NC}"
    fi
    
    # Show size
    if [ -f "$OUT_DIR/boot.img" ]; then
        SIZE=$(du -h "$OUT_DIR/boot.img" | awk '{print $1}')
        echo -e "${GREEN}✓ boot.img created: $SIZE${NC}"
    else
        echo -e "${RED}✗ Failed to create boot.img${NC}"
        exit 1
    fi
}

# Print summary
print_summary() {
    echo ""
    echo -e "${BLUE}====================================="
    echo "Build Summary"
    echo "=====================================${NC}"
    echo -e "${GREEN}✓ Build completed successfully${NC}"
    echo ""
    echo "Kernel Image: $OUT_DIR/arch/$ARCH/boot/Image"
    echo "Boot Image: $OUT_DIR/boot.img"
    echo ""
    echo "Next steps:"
    echo "1. To create AROMA installer: bash scripts/build_aroma_installer.sh $OUT_DIR/boot.img"
    echo "2. To verify: ls -lh $OUT_DIR/"
    echo "3. To flash: fastboot flash boot $OUT_DIR/boot.img"
    echo ""
}

# Main execution
main() {
    check_prerequisites
    clean_build
    load_defconfig
    build_kernel
    create_boot_img
    print_summary
}

# Run main
main "$@"
