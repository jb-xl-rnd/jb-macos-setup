# AeroSpace Tiling Window Manager - Hotkey Cheat Sheet

## Core Window Management

### Focus Windows (Navigate)
| Hotkey | Action |
|--------|--------|
| `⌥ H` | Focus window to the left |
| `⌥ J` | Focus window below |
| `⌥ K` | Focus window above |
| `⌥ L` | Focus window to the right |

### Move Windows
| Hotkey | Action |
|--------|--------|
| `⌥ ⇧ H` | Move window left |
| `⌥ ⇧ J` | Move window down |
| `⌥ ⇧ K` | Move window up |
| `⌥ ⇧ L` | Move window right |

### Resize Windows
| Hotkey | Action |
|--------|--------|
| `⌥ -` | Shrink window by 50 pixels |
| `⌥ =` | Grow window by 50 pixels |

## Layout Management

### Layout Switching
| Hotkey | Action |
|--------|--------|
| `⌥ /` | Toggle between tiles, horizontal, and vertical layouts |
| `⌥ ,` | Toggle between accordion, horizontal, and vertical layouts |

## Workspace Management

### Switch to Workspace
| Hotkey | Action |
|--------|--------|
| `⌥ 1-9` | Switch to workspace 1-9 |
| `⌥ A-Z` | Switch to workspace A-Z (except H,J,K,L) |
| `⌥ Tab` | Switch to previous workspace (back-and-forth) |

### Move Window to Workspace
| Hotkey | Action |
|--------|--------|
| `⌥ ⇧ 1-9` | Move window to workspace 1-9 |
| `⌥ ⇧ A-Z` | Move window to workspace A-Z (except H,J,K,L) |
| `⌥ ⇧ Tab` | Move workspace to next monitor |

## Service Mode
Enter service mode with `⌥ ⇧ ;` then use:

| Key | Action | Notes |
|-----|--------|-------|
| `Esc` | Reload config & exit service mode | |
| `R` | Reset layout (flatten workspace tree) | Removes all splits |
| `F` | Toggle floating/tiling for window | |
| `Backspace` | Close all windows except current | |
| `⌥ ⇧ H` | Join with window on left | Merge containers |
| `⌥ ⇧ J` | Join with window below | Merge containers |
| `⌥ ⇧ K` | Join with window above | Merge containers |
| `⌥ ⇧ L` | Join with window on right | Merge containers |
| `↑` | Volume up | |
| `↓` | Volume down | |
| `⇧ ↓` | Mute (volume to 0) | |

## Quick Reference

### Most Used Commands
- **Navigate:** `⌥` + vim keys (`H`,`J`,`K`,`L`)
- **Move windows:** `⌥ ⇧` + vim keys
- **Workspaces:** `⌥` + number/letter
- **Move to workspace:** `⌥ ⇧` + number/letter
- **Previous workspace:** `⌥ Tab`
- **Service mode:** `⌥ ⇧ ;`

### Workspace Layout
- Numbers: 1-9 (typically for main work)
- Letters: A-Z (specialized workspaces)
  - Note: H, J, K, L are used for navigation

### Tips
1. **Vim-style navigation:** Uses H (left), J (down), K (up), L (right)
2. **Smart resize:** Automatically determines which edge to resize
3. **Wrap-around monitors:** Moving workspace to monitor wraps around
4. **Service mode:** Access advanced features and configuration reload
5. **Back-and-forth:** Quickly toggle between two workspaces with `⌥ Tab`

## Configuration File
- Config location: `~/.aerospace.toml`
- Reload config: Enter service mode (`⌥ ⇧ ;`) then press `Esc`

## CLI Commands
```bash
# List all windows
aerospace list-windows

# List all workspaces
aerospace list-workspaces

# Focus specific workspace
aerospace workspace <name>

# Move window to workspace
aerospace move-node-to-workspace <name>

# Toggle fullscreen
aerospace fullscreen

# Balance window sizes
aerospace balance-sizes
```

## Common Workflows

### Setting up a Development Environment
1. `⌥ 1` - Go to workspace 1
2. Open terminal and editor
3. `⌥ /` - Arrange in tiles
4. `⌥ -` or `⌥ =` - Adjust sizes

### Multi-monitor Setup
1. `⌥ ⇧ Tab` - Move workspace to external monitor
2. Use workspaces across monitors freely

### Quick Window Cleanup
1. `⌥ ⇧ ;` - Enter service mode
2. `Backspace` - Close all but current window

### Reset Messy Layout
1. `⌥ ⇧ ;` - Enter service mode  
2. `R` - Flatten/reset the layout

---
*Legend: `⌥` = Option/Alt, `⇧` = Shift, `⌘` = Command*