# Pinta Installation Workaround

## Issue

Pinta 3.0.2 ARM64 version has missing icons on Apple Silicon Macs due to GTK4/libadwaita compatibility issues.

**GitHub Issue**: [PintaProject/Pinta#1605](https://github.com/PintaProject/Pinta/issues/1605)

## Temporary Workaround

**Use Intel x86_64 build via Rosetta 2** - icons work properly in Intel version.

## Automated Installation

The Ansible playbook automatically:
1. Downloads Intel Pinta 3.0.2 DMG
2. Installs to `/Applications/Pinta.app`
3. Creates shell alias: `pinta`

## Usage

```bash
pinta                          # Uses alias (recommended)
open /Applications/Pinta.app   # Direct launch
```

## Future

This workaround will be **removed** once ARM64 icon issue is fixed (expected in Pinta 3.0.3).