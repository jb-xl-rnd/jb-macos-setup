# LazyVim Telescope Configuration

## Current Focus: Content Search
Enhanced telescope configuration to prioritize content searching within files over hidden file discovery.

### Configured Key Bindings:
- `<leader>fg` - Live grep search (search file contents)
- `<leader>fw` - Grep word under cursor
- `<leader>ff` - Find files (LazyVim default, filename search only)

### Content Search Features:
- Ripgrep integration with smart case matching
- Ignores version control files but searches other ignored files with `--no-ignore-vcs`
- Excludes common noise: `.git/`, `node_modules/`, `*.lock` files
- Optimized for performance with `--trim` flag

## Hidden Files Issue - Temporarily Set Aside
**Previous Issue**: Telescope's `find_files` with `hidden = true` doesn't work properly in LazyVim.

**Decision**: Focus on content search functionality first. Hidden file search can be addressed later if needed.

### Working Content Search Test:
Run telescope live grep (`<leader>fg`) and search for content patterns across the codebase.