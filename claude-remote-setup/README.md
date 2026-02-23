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

### All aliases

| Alias | What it does |
|-------|-------------|
| `cc-remote` | Connect via mosh, auto-attach tmux |
| `cc-remote-ssh` | Connect via plain SSH (fallback) |
| `cc-attach` | Attach to existing tmux session over SSH |
| `cc-start` | Start Claude Code in a caffeinated tmux session |
| `cc-status` | Check if Claude Code is running on remote |
| `cc-kill` | Kill tmux session and caffeinate on remote |

### tmux basics

| Key | Action |
|-----|--------|
| `Ctrl-b d` | Detach (session keeps running) |
| `Ctrl-b [` | Enter scroll mode (q to exit) |
| `Ctrl-b %` | Split pane vertically |
| `Ctrl-b "` | Split pane horizontally |
| `Ctrl-b c` | New window |
| `Ctrl-b n/p` | Next/previous window |

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
