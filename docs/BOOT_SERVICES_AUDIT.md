# macOS Boot Services & Background Processes Audit

**Last Updated:** 2025-11-20
**System:** macOS 15.1 (Darwin 25.1.0)

## Overview

This document provides a comprehensive audit of all services, agents, and processes that run at boot time or in the background on this macOS system. It distinguishes between built-in macOS services and third-party utilities.

## Quick Reference

### Boot & Login Mechanisms on macOS

Unlike Linux's systemd, macOS uses **launchd** as its init system:

| Type | Location | Run Time | Privileges | Purpose |
|------|----------|----------|------------|---------|
| **LaunchDaemons** | `/Library/LaunchDaemons/` | Boot | System (root) | System-wide services |
| **LaunchDaemons** | `/System/Library/LaunchDaemons/` | Boot | System (root) | Built-in macOS services |
| **LaunchAgents** | `~/Library/LaunchAgents/` | Login | User | Per-user services |
| **LaunchAgents** | `/Library/LaunchAgents/` | Login | User | System-wide user services |
| **LaunchAgents** | `/System/Library/LaunchAgents/` | Login | User | Built-in macOS user services |
| **Login Items** | System Preferences | Login | User | GUI apps at login |

## 1. System-Level LaunchDaemons (Boot-time Services)

### Third-Party LaunchDaemons (`/Library/LaunchDaemons/`)

These are third-party services that run at boot time with system privileges:

#### 1.1 Docker Socket (`com.docker.socket.plist`)
- **Program:** `/Library/PrivilegedHelperTools/com.docker.socket`
- **Purpose:** Docker socket management - bridges Docker Desktop socket
- **Arguments:** `/Users/jb/.docker/run/docker.sock`, `/var/run/docker.sock`
- **RunAtLoad:** Yes
- **KeepAlive:** No
- **Status:** ✅ Documented in project
- **Notes:** Part of Docker Desktop installation, required for Docker CLI

#### 1.2 Docker VMNetd (`com.docker.vmnetd.plist`)
- **Program:** `/Library/PrivilegedHelperTools/com.docker.vmnetd`
- **Purpose:** Docker virtual machine networking
- **Status:** ✅ Documented in project
- **Notes:** Manages network interfaces for Docker VMs

#### 1.3 OrbStack Privileged Helper (`dev.orbstack.OrbStack.privhelper.plist`)
- **Program:** `/Library/PrivilegedHelperTools/dev.orbstack.OrbStack.privhelper`
- **Purpose:** OrbStack container runtime privileged operations
- **Associated Bundle:** `dev.kdrag0n.MacVirt`
- **Status:** ✅ Documented in project - OrbStack is Docker alternative
- **Notes:** OrbStack is installed via Homebrew (`brew install --cask orbstack`)

#### 1.4 MacFUSE Launch Service Daemon (`io.macfuse.app.launchservice.daemon.plist`)
- **Program:** `/Library/PrivilegedHelperTools/io.macfuse.app.launchservice.daemon`
- **Purpose:** FUSE filesystem support for macOS
- **Status:** ✅ Documented in project - Required for NTFS support
- **Notes:** See `docs/SetupNTFSSupportMacOS.md`

#### 1.5 MacFUSE Launch Service Broker (`io.macfuse.app.launchservice.broker.plist`)
- **Program:** `/Library/PrivilegedHelperTools/io.macfuse.app.launchservice.broker`
- **Purpose:** FUSE filesystem broker service
- **Status:** ✅ Documented in project
- **Notes:** Companion service to MacFUSE daemon

#### 1.6 Google Updater Wake (`com.google.GoogleUpdater.wake.system.plist`)
- **Program:** Google update service
- **Purpose:** Periodic Google software updates (Chrome, etc.)
- **Status:** ⚠️ Third-party auto-updater
- **Notes:** Can be disabled if Google apps are updated manually

#### 1.7 Google Keystone Daemon (`com.google.keystone.daemon.plist`)
- **Purpose:** Google software update framework
- **Status:** ⚠️ Legacy Google updater
- **Notes:** Older Google update mechanism, consider removing

#### 1.8 Viscosity Helper (`com.sparklabs.ViscosityHelper.plist`)
- **Purpose:** VPN helper for Viscosity VPN client
- **Status:** ⚠️ Not documented in project
- **Notes:** **ACTION NEEDED:** Document or remove if Viscosity no longer used

### Running Status
```
PID   Status  Label
-     0       io.macfuse.app.launchservice.broker
-     0       io.macfuse.app.launchservice.daemon
-     0       com.google.GoogleUpdater.wake.system
-     0       dev.orbstack.OrbStack.privhelper
```

## 2. User-Level LaunchAgents (Login-time Services)

### User-Specific LaunchAgents (`~/Library/LaunchAgents/`)

#### 2.1 Battery Management (`battery.plist`)
- **Program:** `/usr/local/bin/battery`
- **Arguments:** `maintain_synchronous`, `recover`
- **Purpose:** Battery health management - maintains optimal charge levels
- **RunAtLoad:** Yes
- **Logs:** `~/.battery/battery.log`
- **Status:** ✅ Documented - battery CLI tool
- **Notes:** Installed via Homebrew (`brew install battery`)

#### 2.2 skhd - Hotkey Daemon (`com.koekeishiya.skhd.plist`)
- **Program:** `/opt/homebrew/bin/skhd`
- **Purpose:** System-wide hotkey daemon for window management
- **RunAtLoad:** Yes
- **KeepAlive:** Yes (restarts on crash)
- **Process Type:** Interactive
- **Priority:** -20 (highest)
- **Logs:** `/tmp/skhd_jb.out.log`, `/tmp/skhd_jb.err.log`
- **Status:** ✅ Documented in project
- **Notes:** Works with yabai for tiling window management, installed via Homebrew

#### 2.3 yabai - Window Manager (`com.koekeishiya.yabai.plist`)
- **Program:** `/opt/homebrew/bin/yabai`
- **Purpose:** Tiling window manager for macOS
- **RunAtLoad:** Yes
- **KeepAlive:** Yes (restarts on crash)
- **Process Type:** Interactive
- **Priority:** -20 (highest)
- **Logs:** `/tmp/yabai_jb.out.log`, `/tmp/yabai_jb.err.log`
- **Status:** ⚠️ Partially documented - AeroSpace is the documented window manager
- **Notes:** **ACTION NEEDED:** Either document yabai or remove in favor of AeroSpace

#### 2.4 Nextcloud (`com.nextcloud.desktopclient.plist`)
- **Purpose:** Nextcloud desktop sync client
- **Status:** ✅ Documented - Nextcloud is the sync solution
- **Notes:** Nextcloud app installed via Homebrew cask

#### 2.5 Multipass GUI Autostart (`com.canonical.multipass.gui.autostart.plist`)
- **Type:** Symlink to `/Library/Application Support/com.canonical.multipass/Resources/`
- **Purpose:** Ubuntu VM manager GUI autostart
- **Status:** ⚠️ Not documented in project
- **Notes:** **ACTION NEEDED:** Document if actively used, otherwise remove

#### 2.6 Steam Clean (`com.valvesoftware.steamclean.plist`)
- **Purpose:** Steam cleanup service
- **Status:** ⚠️ Not documented in project
- **Notes:** Gaming-related, document in packages if intentional

#### 2.7-2.9 Google Services
- `com.google.GoogleUpdater.wake.plist` - Google update scheduler
- `com.google.keystone.agent.plist` - Google update agent
- `com.google.keystone.xpcservice.plist` - Google XPC service
- **Status:** ⚠️ Google auto-update services
- **Notes:** Can be disabled if Google apps updated via Homebrew

### Third-Party LaunchAgents (`/Library/LaunchAgents/`)

#### 2.10-2.11 Google Update Services
- `com.google.keystone.agent.plist`
- `com.google.keystone.xpcservice.plist`
- **Status:** Duplicate of user agents
- **Notes:** System-wide Google updaters

## 3. Login Items (GUI Apps at Login)

These apps start automatically when logging in via System Preferences > Login Items:

1. **Tailscale** - VPN mesh network
   - Status: ✅ Documented (`brew install --cask tailscale`)

2. **Hidden Bar** - Menu bar organization
   - Status: ✅ Documented (`brew install --cask hiddenbar`)

3. **Raycast** - Spotlight replacement
   - Status: ✅ Documented (`brew install --cask raycast`)

4. **Google Drive** - Google Drive sync
   - Status: ⚠️ Not in packages.json, document or remove

5. **Nextcloud** - File sync and backup
   - Status: ✅ Documented (`brew install --cask nextcloud`)

6. **AeroSpace** - Tiling window manager
   - Status: ✅ Documented - see `docs/AEROSPACE_CHEATSHEET.md`
   - Config: `config/.aerospace.toml`

7. **Stats** - System monitor
   - Status: ✅ Documented (`brew install --cask stats`)

8. **Display Menu** - Display management
   - Status: ⚠️ Not documented in project

## 4. Background Processes

### Key Non-Apple Background Processes

#### Development Tools
- **Visual Studio Code** - Multiple helper processes
- **Brave Browser** - Multiple processes for tabs/extensions
- **Claude** - AI coding assistant (this interface)
- **kitty** - Terminal emulator

#### System Utilities
- **OrbStack** - Container runtime (Docker alternative)
- **Betterbird** - Email client (Thunderbird fork)
- **Nextcloud** - File sync

#### Development Services
- **npm** - Node package manager instances
- **uv** - Python package manager
- **node** - Node.js runtime instances
- **Python** - Multiple Python processes for MCP servers

#### System Services (Third-party)
- **bluetoothd** - Bluetooth daemon
- **notifyd** - Notification daemon

## 5. System Extensions

### Camera Extensions
- **OBS Virtual Camera** (`com.obsproject.obs-studio.mac-camera-extension`)
  - Version: 31.0.2
  - Team ID: 2MMRE5MTB8
  - Status: ✅ Documented - OBS Studio installed
  - Purpose: Virtual camera for streaming/recording

### Kernel Extensions
- **None** - No third-party kernel extensions detected ✅
- Note: macOS has deprecated kernel extensions in favor of system extensions

## 6. Services Not Covered by This Project

### Action Items - Services to Document or Remove

1. **Viscosity VPN** (`com.sparklabs.ViscosityHelper.plist`)
   - [ ] Document in packages.json if actively used
   - [ ] Remove if no longer needed
   - [ ] Alternative: Tailscale is already documented

2. **yabai Window Manager**
   - [ ] Document alongside or instead of AeroSpace
   - [ ] Choose one window manager and document setup
   - [ ] Remove the other to avoid conflicts

3. **Multipass** (`com.canonical.multipass.gui.autostart.plist`)
   - [ ] Document in packages.json if used for VMs
   - [ ] Remove if OrbStack/Docker Desktop sufficient
   - [ ] Consider if needed alongside OrbStack

4. **Google Update Services** (multiple)
   - [ ] Disable if managing Google apps via Homebrew
   - [ ] Or document as intentional auto-update mechanism
   - [ ] Unload with: `launchctl unload ~/Library/LaunchAgents/com.google.*.plist`

5. **Steam Clean** (`com.valvesoftware.steamclean.plist`)
   - [ ] Document if gaming setup is part of system
   - [ ] Remove if not actively gaming

6. **Google Drive**
   - [ ] Add to packages.json if intentional
   - [ ] Or remove in favor of Nextcloud only

7. **Display Menu**
   - [ ] Identify what app this is
   - [ ] Document in packages.json or remove

## 7. Security & Performance Recommendations

### High Priority
1. **Reduce Google update services** - 5 separate update services is excessive
2. **Choose one window manager** - yabai vs AeroSpace (AeroSpace is documented)
3. **Review VM needs** - OrbStack vs Multipass (both for containers/VMs)

### Medium Priority
4. **Disable unused VPN** - Viscosity vs Tailscale (Tailscale is documented)
5. **Consolidate sync** - Google Drive vs Nextcloud (Nextcloud is documented)

### Low Priority
6. **Document all Login Items** - Ensure everything at login is intentional
7. **Review LaunchAgent priorities** - skhd/yabai at -20 (highest) may be excessive

## 8. Maintenance Commands

### List all services
```bash
# Run full audit
./scripts/system/boot_services_audit.sh --verbose --output audit_report.txt

# List running services
launchctl list

# List non-Apple services
launchctl list | grep -v "com.apple"
```

### Manage LaunchAgents/LaunchDaemons
```bash
# Unload a service
launchctl unload ~/Library/LaunchAgents/service.plist

# Load a service
launchctl load ~/Library/LaunchAgents/service.plist

# Check service status
launchctl list | grep service-name
```

### Manage Login Items
```bash
# List login items
osascript -e 'tell application "System Events" to get the name of every login item'

# Remove via System Settings > General > Login Items
```

### Clean up unused services
```bash
# After uninstalling an app, remove its LaunchAgent/Daemon
rm ~/Library/LaunchAgents/com.company.app.plist
launchctl remove com.company.app
```

## 9. Automated Audit

Run the audit script regularly to track changes:

```bash
# Quick audit
./scripts/system/boot_services_audit.sh

# Detailed audit with output
./scripts/system/boot_services_audit.sh --verbose --output ~/Desktop/boot_audit_$(date +%Y%m%d).txt

# Add to maintenance schedule (monthly recommended)
```

## 10. Summary Statistics

**LaunchDaemons:**
- Third-party: 10 services
- System (built-in): 190+ services

**LaunchAgents:**
- User: 11 services
- Third-party system: 2 services
- System (built-in): 250+ services

**Login Items:** 8 apps

**Running Services:** 6 non-Apple launchd services active

**System Extensions:** 1 (OBS Virtual Camera)

**Kernel Extensions:** 0 (none, good security posture)

## 11. Comparison with Project Documentation

### ✅ Well Documented
- Battery management
- skhd/yabai (window management - though AeroSpace preferred)
- Nextcloud
- AeroSpace
- OrbStack
- MacFUSE/NTFS support
- OBS Studio
- Tailscale
- Hidden Bar
- Raycast
- Stats

### ⚠️ Needs Documentation or Removal
- Viscosity VPN (LaunchDaemon)
- Multipass (LaunchAgent)
- Steam Clean (LaunchAgent)
- Google Drive (Login Item)
- Display Menu (Login Item)
- Google Update Services (multiple, consider disabling)
- yabai (document or remove in favor of AeroSpace)

---

**Next Steps:**
1. Review the "Action Items" section
2. Run `./scripts/system/boot_services_audit.sh` to generate current state
3. Document or remove undocumented services
4. Update `config/packages.json` with any intentional services
5. Run audit monthly to track changes
