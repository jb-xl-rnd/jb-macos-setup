# Enable NTFS Support on macOS (Tested on M2 MacBook Air)

## Goal:
Mount NTFS like on Linux using the Linux NTFS driver:

sudo mkdir /Volumes/NTFS
diskutil list
sudo ntfs-3g /dev/disk6s2 /Volumes/NTFS

## Steps:

### 1. Install Homebrew and Required Packages:
Install `ntfs-3g-mac` and `macFUSE`:

brew tap gromgit/homebrew-fuse
brew install --cask macfuse
brew install ntfs-3g-mac

### 2. Enable Kernel Modifications in Recovery Mode:

- Shut down the Mac.
- Hold the Power-On button after tapping it until the BIOS/Settings/Safe Boot prompt appears.
- Select the cog icon (Options) to enter Recovery Mode.
- In the top menu bar, select `Utilities` > `Startup Security Utility`.
- Choose the Security Policy to allow user management (not remote).

### 3. Configure System Permissions:

- Reboot into macOS.
- Attempt the `ntfs-3g` mount command. It should fail and prompt you to adjust system permissions for `macFUSE`.
- Enable the necessary permissions (requires admin password) and reboot.

### 4. Mount NTFS Partition:

- Create the mount directory if you haven't:
sudo mkdir /Volumes/NTFS

- List disk partitions:
diskutil list

sudo ntfs-3g /dev/disk6s2 /Volumes/NTFS

This streamlined guide should help you enable NTFS support on your Mac.
