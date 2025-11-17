# Homebrew Maintenance Log

This file tracks major maintenance activities, package removals, and system updates.

---

## 2025-11-17 - Initial Audit & Cleanup

### Summary
- Performed comprehensive audit of all Homebrew packages (298 formulae, 36 casks)
- Removed deprecated packages
- Cleaned up unbrewed files causing conflicts
- Updated documentation and added maintenance procedures

### Packages Removed

#### Deprecated Formulae
- **pyside@2** (58.4 MB) - Deprecated Qt bindings for Python
  - Reason: No longer maintained, security concerns
  - Replacement: PySide6 or PyQt6 (install when needed)

- **python@3.10** (59.4 MB) - Auto-removed as unused dependency
  - Reason: Orphaned after pyside@2 removal
  - Note: Multiple Python versions still available (3.11, 3.12, 3.13, 3.14)

- **qt@5** (358.1 MB) - Auto-removed as unused dependency
  - Reason: Orphaned after pyside@2 removal
  - Note: Latest Qt version still installed

#### Deprecated Casks
- **betterdiscord-installer** - Discord modification tool
  - Reason: Deprecated, violates Discord ToS, security risk
  - Replacement: None recommended

- **blheli-configurator** - ESC configuration tool
  - Reason: No longer maintained
  - Replacement: BLHeli_32 Suite or modern ESC tools

- **autodesk-fusion** (duplicate entry)
  - Reason: Duplicate of autodesk-fusion360
  - Note: autodesk-fusion360 remains installed

#### Deprecated Tap
- **homebrew/services** (1.9 MB)
  - Reason: Functionality now built into Homebrew core
  - Replacement: Use `brew services` command directly

### System Files Cleaned

#### Unbrewed Files Removed
Location: `/usr/local/lib` and `/usr/local/include`

Files:
- `libraylib.5.5.0.dylib`
- `raylib.h`, `raymath.h`, `rcamera.h`, `rlgl.h`
- `raylib.pc`

Reason: Manual raylib installation conflicting with Homebrew-managed version

### Cleanup Results

**Space Freed:**
- Direct removals: ~475.8 MB
- Cache cleanup: ~134.7 MB
- Unbrewed files: ~5 MB
- **Total: ~612 MB**

**Final State:**
- ✅ `brew doctor`: "Your system is ready to brew"
- ✅ No deprecated packages remaining
- ✅ No unbrewed file conflicts
- ✅ All packages up-to-date

### Configuration Updates

**Files Modified:**
1. `config/packages.json`
   - Removed pyside@2, python@3.10, qt@5
   - Removed betterdiscord-installer, blheli-configurator, autodesk-fusion
   - Added python@3.14 (new version)

2. `README.md`
   - Added comprehensive Maintenance section
   - Added instructions for handling deprecated packages
   - Added security best practices

3. `install.sh`
   - Added System Maintenance menu option
   - Integrated brew doctor checks

4. `scripts/system/brew_maintenance.sh` (NEW)
   - Automated maintenance script
   - Supports quick mode and verbose output
   - Comprehensive health checks

### Recommendations for Next Maintenance

Consider reviewing:
1. **Multiple Python versions** - Keep only 3.12 (stable) and 3.14 (latest)?
2. **Qt framework** - Large installation, remove if not doing Qt development
3. **SDR tools** (airspy, hackrf, hamlib) - Remove if not actively used
4. **System monitors** - Consolidate btop/htop/iftop/nvtop/asitop

### Maintenance Schedule

**Recommended:**
- Weekly: Quick check (`./scripts/system/brew_maintenance.sh --quick`)
- Monthly: Full maintenance (`./scripts/system/brew_maintenance.sh`)
- Quarterly: Deep audit and review unused packages

---

## Template for Future Entries

### YYYY-MM-DD - [Brief Description]

**Summary:**
[What was done]

**Packages Added/Removed:**
- Package name (size) - reason

**Issues Resolved:**
- Issue description

**Space Impact:**
- Space freed/used

**System Health:**
- brew doctor status

**Notes:**
[Any important observations]

---
