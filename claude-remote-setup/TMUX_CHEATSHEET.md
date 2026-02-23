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

## Scrollback / Copy Mode

```
Ctrl-b [        Enter scroll mode
  PgUp/PgDn      Scroll
  Up/Down         Scroll line by line
  /               Search forward
  ?               Search backward
  n               Next search result
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

## Remember

- **Detach** (`Ctrl-b d`) keeps everything running. **Exit** kills the window.
- The status bar at the bottom shows your windows. Highlighted = active.
- Mouse works for clicking panes, scrolling, and resizing.
