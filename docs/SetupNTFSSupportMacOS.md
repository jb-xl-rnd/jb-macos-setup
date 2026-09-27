# NTFS & ext4 Drive Support on macOS

Last verified 2026-09-27 on an M2 MacBook Air, macOS 27.0: macFUSE 5.4.0,
ntfs-3g-mac 2026.7.7, ext4fuse-mac 0.1.3, e2fsprogs 1.47.4 (via the self-test
below, using disk images rather than physical drives).

## What you get

| Filesystem | When plugged in | Read | Write | Tool |
|---|---|---|---|---|
| NTFS | macOS auto-mounts it **read-only** (built-in driver) | ✅ | ✅ manual `ntfs-3g` mount | `ntfs-3g-mac` |
| ext4 | Nothing: macOS has no ext4 driver | ✅ manual `ext4fuse` mount | ❌ | `ext4fuse-mac` |
| exFAT / FAT32 | Auto-mounts read-write | ✅ | ✅ | built-in |

Neither FUSE tool auto-mounts. You mount them by hand, as shown below.

## Install

Ansible handles this (`--tags packages`, from `config/packages.json`). By hand:

```bash
brew install --cask macfuse      # FIRST: the gromgit formulae refuse to install without it
brew tap gromgit/fuse
brew install gromgit/fuse/ntfs-3g-mac gromgit/fuse/ext4fuse-mac
brew install e2fsprogs           # keg-only: tools live in /opt/homebrew/opt/e2fsprogs/sbin/
```

## One-time: allow the macFUSE kernel extension (Apple Silicon)

1. **Recovery → Startup Security Utility.** Shut down, hold the power button until
   the startup options appear, then choose Options. Go to Utilities → Startup Security Utility,
   pick **Reduced Security**, and tick *Allow user management of kernel extensions from
   identified developers*.
2. **Trigger the block.** Back in macOS, try any mount (the self-test below works). It
   fails with a **"System Extension Blocked"** dialog.
3. **Allow it.** Go to System Settings → Privacy & Security → *Security* section → "System
   software from developer 'Benjamin Fleischer' was blocked" → **Allow**. Restart
   **when macOS prompts you to**.
4. **Verify** with the self-test. After a successful mount, this shows the loaded kext:
   ```bash
   kmutil showloaded 2>/dev/null | grep macfuse
   ```

### ⚠️ You have to re-approve after macFUSE / macOS updates

The approval is tied to the kext's bundle ID, and that ID changes between macFUSE
releases (e.g. `io.macfuse.filesystems.macfuse.23` → `.25` with macFUSE 5.x). The old
approval doesn't carry over, so mounts break again until you repeat steps 2–3.

Gotchas from the 2026-09-27 fix:

- **`ntfs-3g` exits 0 but nothing shows in `mount`** means the kext is blocked. The dialog
  pops up on the desktop, not in the terminal.
- **The Allow button goes stale.** It only shows for a while after a block, and a restart
  clears it. One allow + restart silently didn't take. What worked: trigger a fresh
  block, open a *new* Settings window, Allow, then restart from the prompt.
- To see what's approved (`allowed` = 1). Needs sudo, and possibly Full Disk Access
  for your terminal:
  ```bash
  sudo sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy \
    "select bundle_id, allowed from kext_policy where team_id='3T5GSNBU6W'"
  ```
  Compare with the ID actually installed:
  ```bash
  defaults read /Library/Filesystems/macfuse.fs/Contents/Extensions/$(sw_vers -productVersion | cut -d. -f1)/macfuse.kext/Contents/Info CFBundleIdentifier
  ```

## Usage

Find the partition with `diskutil list`. NTFS shows as `Microsoft Basic Data` or
`Windows_NTFS`; ext4 shows as `Linux Filesystem` or `Linux`.

**NTFS, read-write:**

```bash
diskutil unmount /dev/disk6s2              # macOS already mounted it read-only
sudo mkdir -p /Volumes/NTFS
sudo ntfs-3g /dev/disk6s2 /Volumes/NTFS
# ...
sudo umount /Volumes/NTFS                  # always before unplugging
```

**ext4, read-only:**

```bash
sudo mkdir -p /Volumes/linux
sudo ext4fuse /dev/disk6s1 /Volumes/linux -o allow_other
# ...
sudo umount /Volumes/linux
```

## Limitations

- **ext4 is read-only.** `ext4fuse` can't write at all. For read-write ext4 (and btrfs/LUKS),
  the candidate is [anylinuxfs](https://github.com/nohajc/anylinuxfs): it runs a small Linux
  VM and uses the real Linux driver. Not installed or tested yet.
- **`ext4fuse` is an old project.** It reads images made with current `mkfs.ext4` defaults
  fine, but if a drive from a newer Linux won't mount, fall back to anylinuxfs or a Linux box.
- **Windows Fast Startup / hibernation** leaves NTFS marked dirty, and `ntfs-3g` then won't
  mount it read-write. Do a full shutdown in Windows (Shift + Shut Down) or disable Fast
  Startup. `ntfsfix` clears the flag, but only use it as a last resort.
- **BitLocker** volumes aren't supported.
- **FUSE mounts buffer writes.** Always `umount` before unplugging. They're slower than native
  drivers, and macOS leaves `._*` / `.fseventsd` files on NTFS drives it writes to.

## Self-test (no real disks touched)

```bash
# NTFS: build an image, mount it read-write, write, read back, clean up
mkfile 64m /tmp/ntfs.img
/opt/homebrew/opt/ntfs-3g-mac/sbin/mkntfs -F -Q -q /tmp/ntfs.img 2>/dev/null
mkdir -p /tmp/ntfs-mnt && sudo ntfs-3g /tmp/ntfs.img /tmp/ntfs-mnt && sleep 1
echo ntfs-ok | sudo tee /tmp/ntfs-mnt/t.txt >/dev/null && cat /tmp/ntfs-mnt/t.txt
sudo umount /tmp/ntfs-mnt; rm -rf /tmp/ntfs.img /tmp/ntfs-mnt

# ext4: build an image with a file inside, mount it read-only, read
mkdir -p /tmp/ext4-src && echo ext4-ok > /tmp/ext4-src/t.txt
mkfile 64m /tmp/ext4.img
/opt/homebrew/opt/e2fsprogs/sbin/mkfs.ext4 -q -F -d /tmp/ext4-src /tmp/ext4.img
mkdir -p /tmp/ext4-mnt && sudo ext4fuse /tmp/ext4.img /tmp/ext4-mnt -o allow_other && sleep 1
cat /tmp/ext4-mnt/t.txt
sudo umount /tmp/ext4-mnt; rm -rf /tmp/ext4.img /tmp/ext4-src /tmp/ext4-mnt
```

If it works, it prints `ntfs-ok` and then `ext4-ok`. If there's no output and nothing is
mounted, the kext is blocked (see above).

## Troubleshooting: the disk shows no partitions at all

If `diskutil list` shows the disk with only a `0:` line (and `diskutil info` says
`Content (IOContent): None`), there's no partition table, so there's nothing for either
tool to mount. Check whether it's blank before assuming there's data on it:

```bash
sudo dd if=/dev/rdiskN bs=512 count=34 2>/dev/null | xxd | grep -v "0000 0000 0000 0000 0000 0000 0000 0000"
```

No output means the MBR/GPT area is all zeros: the drive is new or was secure-erased.
(2026-09-27: a 512 GB NVMe in a USB enclosure looked like this. It was erased to FAT32 with
`diskutil eraseDisk FAT32 NVME MBR diskN`.)
