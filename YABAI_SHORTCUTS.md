# Yabai & skhd Keyboard Shortcuts Cheatsheet

## Window Navigation
| Shortcut | Action |
|----------|--------|
| **⌥ + h** | Focus window to the left |
| **⌥ + j** | Focus window below |
| **⌥ + k** | Focus window above |
| **⌥ + l** | Focus window to the right |

## Window Movement
| Shortcut | Action |
|----------|--------|
| **⇧ + ⌥ + h** | Swap with window to the left |
| **⇧ + ⌥ + j** | Swap with window below |
| **⇧ + ⌥ + k** | Swap with window above |
| **⇧ + ⌥ + l** | Swap with window to the right |

## Window Resizing
| Shortcut | Action |
|----------|--------|
| **⌃ + ⌥ + h** | Decrease window width |
| **⌃ + ⌥ + j** | Increase window height |
| **⌃ + ⌥ + k** | Decrease window height |
| **⌃ + ⌥ + l** | Increase window width |

## Space Management
| Shortcut | Action |
|----------|--------|
| **⌥ + 1-9** | Switch to space 1-9 |
| **⇧ + ⌥ + 1-9** | Move window to space 1-9 |
| **⌘ + ⌥ + n** | Create new space |
| **⌘ + ⌥ + w** | Delete current space |
| **⌘ + ⌥ + x** | Focus recent space |
| **⌘ + ⌥ + z** | Focus previous space |
| **⌘ + ⌥ + c** | Focus next space |

## Layout Management
| Shortcut | Action |
|----------|--------|
| **⌥ + e** | Toggle window split type (horizontal/vertical) |
| **⌥ + r** | Rotate tree 90° clockwise |
| **⇧ + ⌥ + r** | Rotate tree 270° |
| **⌥ + y** | Mirror tree on y-axis |
| **⌥ + x** | Mirror tree on x-axis |
| **⇧ + ⌥ + 0** | Balance window sizes |
| **⌥ + g** | Toggle padding and gaps |

## Window States
| Shortcut | Action |
|----------|--------|
| **⌥ + f** | Toggle fullscreen |
| **⌥ + d** | Toggle parent zoom |
| **⇧ + ⌥ + Space** | Toggle float |
| **⇧ + ⌥ + c** | Float and center window |

## Display Management
| Shortcut | Action |
|----------|--------|
| **⇧ + ⌥ + n** | Send window to next display |
| **⇧ + ⌥ + p** | Send window to previous display |
| **⌃ + ⌥ + 1-3** | Focus display 1-3 |

## Application Launch
| Shortcut | Action |
|----------|--------|
| **⌘ + Return** | Open new Kitty terminal |

## System
| Shortcut | Action |
|----------|--------|
| **⌃ + ⌥ + ⌘ + r** | Restart yabai |

---

## Key Symbol Reference
- **⌘** = Command
- **⌥** = Option (Alt)
- **⌃** = Control
- **⇧** = Shift

## Tips
- Windows must be in tiling mode (bsp layout) for navigation to work
- Grant accessibility permissions to both yabai and skhd in System Settings
- Check current layout: `yabai -m query --spaces --space`
- Switch to tiling: `yabai -m space --layout bsp`
- Switch to floating: `yabai -m space --layout float`

## Configuration Files
- Yabai config: `~/.yabairc`
- skhd config: `~/.skhdrc`
- Ansible templates: `ansible/templates/yabairc.j2` and `ansible/templates/skhdrc.j2`