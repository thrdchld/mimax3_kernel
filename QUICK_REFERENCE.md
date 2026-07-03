# 🚀 Nitrogen Kernel Build System - Quick Reference

## 📋 File Locations & Purposes

| File | Purpose | Size | Type |
|------|---------|------|------|
| `.github/workflows/build-kernel.yml` | Main GitHub Actions workflow | 9.9 KB | Workflow |
| `scripts/build_aroma_installer.sh` | AROMA installer generator | 8.2 KB | Script |
| `scripts/build-local.sh` | Local build automation | 4.5 KB | Script |
| `BUILD_GUIDE.md` | Complete setup & usage guide | 11 KB | Documentation |
| `SETUP_COMPLETE.md` | Setup summary & next steps | 12 KB | Documentation |
| `.github/workflows/README.md` | Workflow details | 4.2 KB | Documentation |
| `scripts/README.md` | Script reference | 4.4 KB | Documentation |
| `.version` | Kernel version file | 8 bytes | Config |

---

## ⚡ Quick Commands

### Build on GitHub (Automatic)
```bash
# Simply push to trigger build
git push origin main

# Or create a release tag
git tag -a v4.4.302 -m "Release"
git push origin v4.4.302
```

### Local Quick Build
```bash
bash scripts/build-local.sh
# Output: out/boot.img
```

### Create AROMA Installer (After Build)
```bash
bash scripts/build_aroma_installer.sh \
  out/boot.img "4.4.302" "abc1234" "20260703" "1" "stable"
# Output: nitrogen_aroma_installer.zip
```

### Manual Full Build
```bash
export ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- nitrogen_defconfig
make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
```

---

## 📱 Installation Methods

### AROMA (Recommended)
```
Device → Copy .zip → Recovery → Install → Reboot
```

### Fastboot
```bash
fastboot flash boot boot.img && fastboot reboot
```

### ADB Recovery
```bash
adb push boot.img /tmp/
adb shell dd if=/tmp/boot.img of=/dev/block/bootdevice/by-name/boot
```

---

## 🔧 Key Configuration

```
Architecture: arm64
Device: Nitrogen (Mi Max 3)
Kernel Version: 4.4.302
Defconfig: arch/arm64/configs/nitrogen_defconfig (5079 lines)
Cross-Compiler: aarch64-linux-gnu-
Build Partition: /dev/block/bootdevice/by-name/boot
```

---

## 📊 Build Times & Sizes

| Metric | Value |
|--------|-------|
| **First Build** | 20-30 min |
| **Incremental Build** | 5-10 min |
| **Kernel Image** | 8-15 MB |
| **boot.img** | 10-30 MB |
| **AROMA Package** | 20-60 MB |
| **Build Parallel Jobs** | $(nproc) cores |

---

## ✅ Setup Verification

- ✅ Workflow configured and executable
- ✅ Scripts created and executable (chmod +x)
- ✅ Defconfig file exists and valid
- ✅ Documentation complete
- ✅ All environment variables set
- ✅ Ready for first build!

---

## 🎯 First Time User Steps

1. **Read Documentation**
   ```bash
   cat BUILD_GUIDE.md              # Full guide
   cat SETUP_COMPLETE.md           # What was created
   cat .github/workflows/README.md # Workflow details
   ```

2. **Trigger First Build**
   ```bash
   git push origin main            # Auto-triggers workflow
   ```

3. **Monitor Build**
   - Go to GitHub Actions tab
   - Watch workflow progress
   - Check build logs if needed

4. **Download Artifacts**
   - After ~20-30 min
   - Download `nitrogen_aroma_installer.zip`
   - Download `boot.img` (optional)

5. **Install on Device**
   - Copy zip to device
   - Boot to TWRP recovery
   - Install from zip

---

## 🔍 Workflow Automation

### Triggers

| Trigger | Action |
|---------|--------|
| Push to `main` | Auto-build |
| Push to `4.4.*` | Auto-build |
| Create tag `v*` | Release build |
| Actions > Run | Manual build |

### Build Types
- **stable** - Production (default)
- **beta** - Pre-release testing
- **nightly** - Daily development

---

## 📦 Output Artifacts

### Always Generated
- ✓ `boot.img` - Kernel bootable image
- ✓ `nitrogen_aroma_installer.zip` - Recovery installer
- ✓ `RELEASE_NOTES.txt` - Installation guide
- ✓ `*.sha256` - Checksum verification files

### Automatic Release (On Tag)
- ✓ All above files uploaded
- ✓ Release notes attached
- ✓ Checksums included
- ✓ GitHub Release created

---

## 🛠️ Development Workflow

### For Kernel Developers

```bash
# 1. Make changes to kernel source
nano drivers/...
nano kernel/...

# 2. Test locally
bash scripts/build-local.sh

# 3. Fix issues
nano arch/arm64/configs/nitrogen_defconfig  # Or adjust code

# 4. Commit and push
git add .
git commit -m "Fix feature X"
git push origin main

# 5. GitHub Actions automatically builds
# 6. Download and test artifacts
# 7. Create release tag when ready
git tag -a v4.4.303 -m "Version 4.4.303"
git push origin v4.4.303
```

---

## 🐛 Troubleshooting - Quick Fix

### GitHub Build Fails
→ Check Actions tab logs → Search for "ERROR" → Re-read BUILD_GUIDE.md

### Local Build Won't Start
→ Install tools: `sudo apt-get install build-essential gcc-aarch64-linux-gnu`

### AROMA Won't Install
→ Wrong device? → Use TWRP recovery → Check SHA256 checksum

### Device Won't Boot After Flash
→ Restore previous image → Check kernel defconfig compatibility

---

## 🔗 File Dependencies

```
.github/workflows/build-kernel.yml
├── Calls: scripts/build_aroma_installer.sh
├── Uses: arch/arm64/configs/nitrogen_defconfig
├── Reads: .version (for kernel version)
└── Outputs: boot.img, nitrogen_aroma_installer.zip

scripts/build-local.sh
├── Uses: arch/arm64/configs/nitrogen_defconfig
└── Outputs: out/boot.img

scripts/build_aroma_installer.sh
├── Inputs: boot.img
├── Creates: AROMA directory structure
└── Outputs: nitrogen_aroma_installer.zip
```

---

## 📞 When You Need Help

### For GitHub Actions Issues
→ [.github/workflows/README.md](.github/workflows/README.md)

### For Build Script Issues
→ [scripts/README.md](scripts/README.md)

### For Complete Setup Guide
→ [BUILD_GUIDE.md](BUILD_GUIDE.md)

### For General Questions
→ [SETUP_COMPLETE.md](SETUP_COMPLETE.md)

---

## 💡 Pro Tips

1. **Cache Builds** - Incremental builds use cache, much faster
2. **Parallel Jobs** - Automatically uses all CPU cores
3. **Verify Integrity** - Always check SHA256 checksums
4. **Keep Backups** - Save previous boot.img before flashing
5. **Test Locally** - Always test locally before pushing
6. **Version Tracking** - Keep .version file updated

---

## 🎓 Learning Resources

- Linux Kernel Build: https://www.kernel.org/doc/
- ARM64 Architecture: https://www.kernel.org/doc/html/latest/arm64/
- AROMA Installer: https://aroma.sourceforge.io/
- Device Recovery: TWRP project documentation

---

## ✨ What Makes This Professional

✓ Automated builds on every commit
✓ Professional AROMA installer interface
✓ Device compatibility checks
✓ Build metadata tracking
✓ SHA256 verification
✓ GitHub Releases integration
✓ Complete documentation
✓ Local build support
✓ Error handling & recovery
✓ Version management

---

**Ready to build!** 🚀

For detailed information, see: [BUILD_GUIDE.md](BUILD_GUIDE.md)
