# tmux Cheatsheet

All commands start with the **prefix**: `Ctrl-b` (hold Ctrl, press b, release both, then press the next key).

## Survival Basics

```
Ctrl-b d        Detach (leave everything running, go back to local)
Ctrl-b c        New window (tab)
Ctrl-b n        Next window
Ctrl-b p        Previous window
Ctrl-b [        Scroll mode (PgUp/PgDn to scroll, q to exit)
```

## Windows (Tabs)

```
Ctrl-b c        Create new window
Ctrl-b n        Next window
Ctrl-b p        Previous window
Ctrl-b 0-9      Jump to window by number
Ctrl-b w        Visual window picker
Ctrl-b ,        Rename current window
Ctrl-b &        Kill current window (asks for confirmation)
```

## Panes (Splits)

```
Ctrl-b %        Split left/right
Ctrl-b "        Split top/bottom
Ctrl-b arrow    Move between panes
Ctrl-b z        Zoom pane (fullscreen toggle, press again to unzoom)
Ctrl-b x        Kill current pane
Ctrl-b space    Cycle pane layouts
Ctrl-b {        Swap pane left
Ctrl-b }        Swap pane right
```

## Copy / Paste

**To copy text to your Mac clipboard through mosh + tmux:**

Hold **Shift** while mouse-selecting text, then **Cmd+C**. This bypasses tmux's
mouse capture and lets Kitty handle the selection natively. This is the most
reliable method through the mosh → tmux chain.

**Shift + mouse select → Cmd+C → Cmd+V.** That's it.

## Scrollback / Copy Mode

```
Ctrl-b [        Enter scroll mode
  PgUp/PgDn      Scroll
  Up/Down         Scroll line by line
  /               Search forward
  ?               Search backward
  n               Next search result
  Space           Start selection (vi mode)
  Enter           Copy selection and exit
  q               Exit scroll mode
Mouse scroll    Also works (mouse mode enabled)
```

## Sessions

```
Ctrl-b d        Detach from session
Ctrl-b s        List sessions (switch between them)
Ctrl-b $        Rename current session
```

## From the Command Line

```bash
tmux ls                          List sessions
tmux new -s name                 New session named "name"
tmux attach -t name              Attach to session "name"
tmux kill-session -t name        Kill session "name"
tmux kill-server                 Kill everything
```

## Resize Panes

```
Ctrl-b Ctrl-arrow    Resize pane in arrow direction (hold Ctrl, tap arrow repeatedly)
```

## Working with Claude Code in tmux

When you're connected via mosh with Claude running in a tmux window, your layers look like this:

```
Kitty tab (local)
 └─ mosh connection
     └─ tmux session "claude"
         ├─ window 0: zsh shell
         ├─ window 1: claude code (running)  <── you are here
         └─ window 2: htop or whatever
```

### Leave Claude running, go back to laptop

This is the most common thing you'll do. Two steps:

```
1. Ctrl-b d          Detach from tmux (everything keeps running)
2. exit              Close the mosh connection (back to Kitty)
```

Claude continues working on the remote. Reconnect later with `cc-remote`.

You can also just **close the Kitty tab** or **close your laptop lid** — mosh
handles the disconnect gracefully and tmux keeps everything alive.

### Switch away from Claude to another window

Don't leave — just switch windows. Claude keeps running in its window.

```
Ctrl-b c             Create a new window (opens a fresh shell)
Ctrl-b n / Ctrl-b p  Switch between windows
Ctrl-b 0             Jump back to window 0
Ctrl-b w             Visual picker (arrow keys + enter)
```

The status bar at the bottom shows all windows. The active one is highlighted.

### Check on Claude from another window

Switch to a different tmux window and peek:

```
Ctrl-b 1             Switch to window 1 (where Claude is)
                     Scroll up with Ctrl-b [ then PgUp
                     Press q to exit scroll mode
Ctrl-b 0             Switch back to your shell
```

### Stop Claude (kill one window)

If you want to stop Claude but keep your other tmux windows:

```
Ctrl-b 1             Switch to the Claude window
Ctrl-c               Interrupt Claude
exit                  Close that window's shell
```

Or from any window, kill a specific one:

```
Ctrl-b &             Kill the CURRENT window (confirms with y/n)
```

### Nuke everything (kill the whole session)

From your laptop (not connected):

```bash
cc-kill              Kills tmux session + any caffeinate processes
```

Or if you're inside tmux:

```bash
tmux kill-session    Kills the current session and all its windows
```

## Remember

- **Detach** (`Ctrl-b d`) keeps everything running. **Exit** kills the window.
- The status bar at the bottom shows your windows. Highlighted = active.
- Mouse works for clicking panes, scrolling, and resizing.
- Closing your laptop lid is fine — mosh + tmux handle it.
