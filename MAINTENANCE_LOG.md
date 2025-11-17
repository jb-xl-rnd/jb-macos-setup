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

## 2025-11-17 - Python Package Audit & UV Tools Update

### Summary
- Performed comprehensive Python package audit
- Updated all UV tools (3 tools with 100+ dependency updates)
- Created automated Python maintenance script
- System Python packages are minimal and up-to-date

### Python Environment Analysis

**Python Installations:**
- Homebrew Python: 3.11, 3.12, 3.13, 3.14 (4 versions)
- Pyenv Python: 3.11.4 (1 version)
- Default: Python 3.14.0

**System Packages (Python 3.14):**
- Total: 6 packages (minimal - EXCELLENT)
- Packages: certifi, cffi, cryptography, pip, pycparser, wheel
- Status: All up-to-date ✅

**User-Local Packages:**
- QSpectrumAnalyzer (SDR spectrum analyzer)
- Location: ~/.local/lib/python3.11/site-packages

**UV Tools:**
- aider-chat v0.79.2 → v0.86.1
- claude-monitor v3.1.0 (updated dependencies)
- zotero-mcp v0.1.2 (updated from GitHub)

### UV Tool Updates

**aider-chat (v0.79.2 → v0.86.1):**
- Major version bump
- 60+ dependency updates including:
  - aiohttp 3.11.14 → 3.12.15
  - litellm 1.63.11 → 1.75.0
  - openai 1.66.3 → 1.99.1
  - pydantic 2.10.6 → 2.11.7
  - scipy 1.13.1 → 1.15.3
  - torch support added
- Added Google AI integrations

**claude-monitor (v3.1.0):**
- Dependency updates:
  - numpy 2.3.2 → 2.3.5
  - pydantic 2.11.7 → 2.12.4
  - rich 14.1.0 → 14.2.0

**zotero-mcp (v0.1.2):**
- Updated from GitHub (latest commit)
- 50+ dependency updates including:
  - chromadb 1.1.1 → 1.3.4
  - torch 2.8.0 → 2.9.1
  - transformers 4.57.0 → 4.57.1
  - pillow 11.3.0 → 12.0.0
  - Added machine learning dependencies

### New Tools Created

**scripts/system/python_maintenance.sh:**
- Comprehensive Python package auditing
- Checks all Python installations
- Audits system, user-local, and UV packages
- Identifies virtual environments
- Provides version recommendations
- Supports quick mode and auto-upgrade

### Recommendations Implemented

1. **Keep Python versions minimal:**
   - Consider removing Python 3.11 and 3.13
   - Keep 3.12 (stable, LTS) and 3.14 (latest)

2. **Package management strategy:**
   - Use UV for all tool installations ✅
   - Keep system packages minimal (currently 6 - ideal) ✅
   - Use virtual environments for projects
   - Avoid pip install --user

3. **Maintenance schedule:**
   - Monthly: `uv tool upgrade --all`
   - Monthly: `./scripts/system/python_maintenance.sh`

### Security & Quality Impact

- All UV tools updated with latest security patches
- No known vulnerabilities in system packages
- Minimal attack surface (only 6 system packages)
- Professional tools (aider-chat, claude-monitor, zotero-mcp) at latest versions

### Configuration Updates

**Files Modified:**
1. `README.md` - Added Python Package Maintenance section
2. `scripts/system/python_maintenance.sh` (NEW) - Python audit tool

### System Health

- ✅ System Python packages: 6 (minimal - excellent)
- ✅ All system packages up-to-date
- ✅ UV tools updated to latest versions
- ✅ No deprecated Python packages
- ⚠️ 4 Python versions installed (consider consolidating to 2)
- ⚠️ 1 user-local package (QSpectrumAnalyzer - SDR tool)

### Next Actions

Consider:
1. Remove Python 3.11 and 3.13 if not actively used
2. Review if QSpectrumAnalyzer is still needed
3. Set up monthly UV tool update schedule

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
