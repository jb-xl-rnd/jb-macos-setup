# Claude Code Remote Setup

Ansible playbook that configures two macOS machines (Apple Silicon) for persistent, reconnectable Claude Code sessions over Tailscale.

```
┌──────────────┐    mosh (UDP)     ┌──────────────────────┐
│  My Laptop   │──── over ────────>│    Remote Mac         │
│  (client)    │   Tailscale       │  (server/workhorse)   │
└──────────────┘                   │                       │
                                   │  tmux session         │
                                   │   └─ claude code      │
                                   │       (keeps running) │
                                   │                       │
                                   │  caffeinate           │
                                   │   (prevents sleep)    │
                                   └───────────────────────┘
```

**Connection stack:** Tailscale (encrypted network) > mosh (resilient UDP) > tmux (session persistence) > caffeinate (prevent sleep)

## Prerequisites

**Both machines:**
- macOS on Apple Silicon
- Homebrew installed
- Tailscale installed, logged in, and connected

**Remote Mac (server):**
- Remote Login (SSH) enabled in System Settings, OR the playbook will enable it
- Your SSH public key in `~/.ssh/authorized_keys` (the playbook can handle this)

**Control machine (your laptop):**
- Ansible installed (`brew install ansible`)
- `community.general` collection: `ansible-galaxy collection install community.general`

## Quick Start

### 1. Configure variables

Edit `group_vars/all.yml`:
```yaml
target_user: jb                                    # macOS user on remote Mac
tailscale_hostname: your-mac-mini.tail12345.ts.net  # from: tailscale status
```

Edit `inventory.yml`:
```yaml
ansible_host: your-mac-mini.tail12345.ts.net  # same Tailscale hostname
```

### 2. Run the playbooks

```bash
cd claude-remote-setup

# Configure the remote Mac (server)
ansible-playbook -i inventory.yml server.yml --ask-become-pass

# Configure your laptop (client)
ansible-playbook -i inventory.yml client.yml
```

The `--ask-become-pass` flag is needed for server tasks that require sudo (sshd config, firewall, energy settings).

### 3. Source your shell

```bash
source ~/.zshrc
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `target_user` | `jb` | macOS username on remote Mac |
| `tailscale_hostname` | *(must set)* | Remote Mac's Tailscale hostname |
| `tmux_session_name` | `claude` | Name of the persistent tmux session |
| `tmux_history_limit` | `100000` | tmux scrollback buffer lines |
| `mosh_ports` | `60000:60010` | UDP port range for mosh |
| `homebrew_prefix` | `/opt/homebrew` | Homebrew install path (Apple Silicon) |

## Understanding the Connection Layers

When you run `cc-remote`, you're going through multiple nested layers. Understanding these prevents confusion about what `exit` does and where you are.

```
Your Laptop
 └─ mosh  ........................ resilient UDP connection (survives Wi-Fi changes, laptop sleep)
     └─ tmux  ................... session manager on the remote Mac (persists after disconnect)
         └─ zsh shell  ......... your actual working shell
             └─ claude  ........ or whatever you're running
```

### What happens when you type `exit`

Each `exit` peels back one layer. This is the most common source of confusion:

| Where you are | What `exit` does | What you wanted instead |
|---------------|-----------------|------------------------|
| Inside Claude Code | Quits Claude Code, back to shell | -- |
| In a tmux shell | **Closes that tmux window.** If it's the last window, **kills the tmux session** and drops you to mosh | **Detach instead:** `Ctrl-b d` |
| In mosh (after tmux dies) | Closes mosh, back to your laptop | -- |

**The golden rule:** Never `exit` out of tmux. Always **detach** with `Ctrl-b d`. Detaching leaves everything running on the remote. Exiting kills it.

### Quick reference: Where am I?

- **You see `[claude] 0:zsh*` in a status bar at the bottom** — you're inside tmux
- **You see `mosh [...]` in your terminal title** — you're in mosh but tmux isn't running
- **Neither** — you're on your local machine

## Usage

### Daily workflow

```bash
# Connect to remote Mac (lands in tmux automatically)
cc-remote

# Inside the session, start Claude Code
caffeinate -s claude

# Detach from tmux (session keeps running)
# Press: Ctrl-b d

# Walk away, close lid, whatever. Claude keeps working.

# Reconnect later
cc-remote

# You're back in the same tmux session. Scroll up to catch up.
```

### Disconnecting safely

| Method | What happens | Session survives? |
|--------|-------------|-------------------|
| `Ctrl-b d` | Detach tmux, then type `exit` to close mosh | Yes |
| Close laptop lid | mosh freezes, tmux keeps running | Yes |
| Wi-Fi drops | mosh reconnects automatically when network returns | Yes |
| `exit` in shell | Kills tmux window (dangerous if last window) | Only if other windows exist |
| `cc-kill` from laptop | Intentionally tears down everything | No (that's the point) |

### All aliases

| Alias | What it does |
|-------|-------------|
| `cc-remote` | Connect via mosh, auto-attach tmux |
| `cc-remote-ssh` | Connect via plain SSH (fallback) |
| `cc-attach` | Attach to existing tmux session over SSH |
| `cc-start` | Start Claude Code in a caffeinated tmux session |
| `cc-status` | Check if Claude Code is running on remote |
| `cc-kill` | Kill tmux session and caffeinate on remote |

## tmux Guide

tmux is a terminal multiplexer — think of it as tabs and split panes that live on the remote machine. All tmux commands start with a **prefix key**: `Ctrl-b` (hold Ctrl, press b, release both, then press the command key).

### Windows (tabs)

Windows are like browser tabs. The status bar at the bottom shows them.

```
[claude] 0:zsh* 1:claude  2:htop                    01:42
         ^^^^^  ^^^^^^^^  ^^^^^^
         tab 0  tab 1     tab 2     (* = active)
```

| Keys | Action |
|------|--------|
| `Ctrl-b c` | Create new window (tab) |
| `Ctrl-b n` | Next window |
| `Ctrl-b p` | Previous window |
| `Ctrl-b 0-9` | Jump to window by number |
| `Ctrl-b ,` | Rename current window |
| `Ctrl-b w` | Visual window picker (use arrows + enter) |

### Panes (splits)

Panes split a single window into multiple terminals side by side.

| Keys | Action |
|------|--------|
| `Ctrl-b %` | Split vertically (left/right) |
| `Ctrl-b "` | Split horizontally (top/bottom) |
| `Ctrl-b arrow` | Move between panes |
| `Ctrl-b z` | Zoom pane (fullscreen toggle) |
| `Ctrl-b x` | Kill current pane |

### Scrollback

The buffer holds 100,000 lines. Essential for catching up on Claude Code output after reconnecting.

| Keys | Action |
|------|--------|
| `Ctrl-b [` | Enter scroll mode |
| `Up/Down` or `PgUp/PgDn` | Scroll (while in scroll mode) |
| `q` | Exit scroll mode |
| Mouse scroll | Also works (mouse mode is enabled) |

### Session management

| Keys | Action |
|------|--------|
| `Ctrl-b d` | **Detach** (the most important one) |
| `Ctrl-b s` | List/switch sessions |
| `Ctrl-b $` | Rename session |

### Example workflow with multiple windows

```bash
# You're connected via cc-remote, inside tmux

# Window 0: Claude Code
caffeinate -s claude

# Open a new window for a side task
# Press: Ctrl-b c
# Now in window 1 - run tests, check logs, whatever
tail -f /some/log

# Switch back to Claude
# Press: Ctrl-b 0

# Detach and leave everything running
# Press: Ctrl-b d
# Then: exit  (closes mosh)

# Later, reconnect
cc-remote
# Both windows are still there, Claude is still running
```

## Troubleshooting

### `mosh-server: command not found`

The #1 issue on macOS. Mosh starts mosh-server via a non-interactive SSH command. On Apple Silicon, Homebrew's `/opt/homebrew/bin` is NOT in PATH for non-interactive shells.

**Fix:** The playbook adds Homebrew to PATH in `~/.zshenv` (sourced for all shell types). If you still hit this, verify on the remote:

```bash
cat ~/.zshenv
# Should contain: export PATH="/opt/homebrew/bin:$PATH"
```

### Connection refused

Remote Login (SSH) is not enabled on the remote Mac.

```bash
# On the remote Mac:
sudo systemsetup -setremotelogin on
```

Or enable in System Settings > General > Sharing > Remote Login.

### Remote Mac is sleeping

The playbook disables sleep via `pmset`. Verify:

```bash
# On the remote Mac:
pmset -g | grep sleep
# Should show: sleep 0, disablesleep 1
```

For per-process sleep prevention, wrap commands with `caffeinate -s`:
```bash
caffeinate -s claude
```

### Firewall blocking mosh

```bash
# On the remote Mac:
MOSH_PATH=$(readlink -f /opt/homebrew/bin/mosh-server)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add "$MOSH_PATH"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp "$MOSH_PATH"
```

### SSH multiplexing issues

If connections hang, clear stale control sockets:
```bash
rm -f ~/.ssh/controlmasters/*
```

## Security Notes

### What the playbook changes on the remote Mac

**SSH daemon (`/etc/ssh/sshd_config`):**
- Disables password authentication (key-only)
- Disables keyboard-interactive authentication
- Restricts login to the specified user
- Disables root login
- Limits auth attempts to 3
- Sets login grace time to 20 seconds

**Firewall:**
- Adds mosh-server as an allowed application

**Energy:**
- Disables system sleep (`pmset disablesleep 1, sleep 0`)

**User dotfiles:**
- `~/.zshenv` — Homebrew PATH (for mosh)
- `~/.zshrc` — tmux auto-attach block
- `~/.tmux.conf` — full replacement

### What the playbook changes on your laptop

**User dotfiles:**
- `~/.ssh/config` — adds `claude-remote` host block
- `~/.zshrc` — adds `cc-*` aliases
- `~/.ssh/id_ed25519` — generates key if not present

All dotfile modifications use `blockinfile` with unique markers and are safe to re-run.

## Re-running

The playbook is fully idempotent. Re-run anytime to ensure configuration is correct:

```bash
ansible-playbook -i inventory.yml server.yml --ask-become-pass
ansible-playbook -i inventory.yml client.yml
```
