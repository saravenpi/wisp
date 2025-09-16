# 🌟 WISP Is a Simple Pomodoro

A lightweight, customizable Pomodoro timer with tmux integration. WISP helps you manage focused work sessions using the Pomodoro Technique or custom durations, with beautiful status displays and comprehensive session tracking.

## ✨ Features

- 🍅 **Pomodoro Timer**: Built-in 25-minute work sessions with custom duration support
- 📊 **Session Tracking**: Comprehensive logging with statistics and history
- 🎨 **Customizable Formats**: Multiple display formats for different use cases
- 🔧 **Tmux Integration**: Seamless status bar integration with configurable colors
- ⚡ **Lightweight**: Pure bash implementation with minimal dependencies
- 🎯 **Focus States**: Track running, paused, completed, and cancelled sessions

## 🚀 Quick Start

### Installation

1. **Clone or download this repository**
   ```bash
   git clone https://github.com/saravenpi/wisp.git ~/.local/share/wisp
   cd ~/.local/share/wisp
   ```

2. **Run the installation script**
   ```bash
   ./install.sh
   ```

3. **Add to your PATH** (if not already)
   ```bash
   export PATH="$PATH:$HOME/.local/bin"
   ```

### Basic Usage

```bash
# Start a 25-minute work session
wisp start

# Start a custom duration session
wisp start 45

# Toggle session (start/pause/resume)
wisp toggle

# Stop current session
wisp stop

# View session statistics
wisp stats

# View session history
wisp history
```

## 📦 Installation Methods

### Method 1: Recommended Installation (CLI + Tmux)

**Step 1: Install CLI tools**
```bash
git clone https://github.com/saravenpi/wisp.git
cd wisp
./install.sh
```

This installs:
- `wisp` CLI tool to `~/.local/bin/`
- `wisp-format` formatting utility to `~/.local/bin/`
- Format templates to `~/.config/wisp/formats/`

**Step 2: Add tmux integration** (optional)
Add to your `~/.tmux.conf`:
```bash
# Basic integration
set -g status-right "#(wisp-format tmux)#[fg=default,bg=default]"
bind m run-shell "wisp toggle"
bind M run-shell "wisp-menu"
bind _ run-shell "wisp stop"
```

### Method 2: TPM Plugin Installation

Add wisp as a tmux plugin using [TPM](https://github.com/tmux-plugins/tpm):

1. **Add to your `~/.tmux.conf`:**
   ```bash
   set -g @plugin 'saravenpi/wisp'
   ```

2. **Install with TPM:**
   - Press `prefix + I` to install the plugin
   - Plugin will work with or without CLI installation

3. **Optional: Customize key bindings**
   ```bash
   set -g @wisp_work_toggle_key 'm'    # Default: m
   set -g @wisp_work_menu_key 'M'      # Default: M
   set -g @wisp_work_stop_key '_'      # Default: _
   ```

## 🎨 Customization

### Tmux Status Colors

Customize wisp status colors in your `~/.tmux.conf`:

```bash
# Mellow theme example (included in install)
set -g @wisp_running_fg "#161617"
set -g @wisp_running_bg "#7fb4ca"       # Blue for running
set -g @wisp_paused_fg "#161617"
set -g @wisp_paused_bg "#c4a47c"        # Orange for paused
set -g @wisp_completed_fg "#161617"
set -g @wisp_completed_bg "#90b99f"     # Green for completed
set -g @wisp_inactive_fg "#c9c7cd"
set -g @wisp_inactive_bg "#353539"      # Gray for inactive
```

### Custom Display Formats

Create custom formats in `~/.config/wisp/formats/`:

```bash
# ~/.config/wisp/formats/custom.sh
#!/usr/bin/env bash

format_status() {
    local status="$1"
    local display="$2"

    case "$status" in
        "running")
            echo "🔥 $display"
            ;;
        "paused")
            echo "⏳ $display"
            ;;
        *)
            echo "💤 Idle"
            ;;
    esac
}
```

Use with: `wisp-format custom`

## 📋 Commands Reference

### Session Management
| Command | Description |
|---------|-------------|
| `wisp start [minutes]` | Start new work session (default: 25 min) |
| `wisp toggle` | Toggle session state (start/pause/resume) |
| `wisp pause` | Pause current session |
| `wisp resume` | Resume paused session |
| `wisp stop` | Stop and complete current session |

### Information & Stats
| Command | Description |
|---------|-------------|
| `wisp stats` | Show session statistics |
| `wisp history` | Show detailed session history |
| `wisp today` | Show today's sessions |
| `wisp help` | Show help information |

### Formatting
| Command | Description |
|---------|-------------|
| `wisp-format` | Default format output |
| `wisp-format tmux` | Tmux status bar format |
| `wisp-format minimal` | Minimal format |
| `wisp-format simple` | Simple text format |

## 🎯 Tmux Integration

### Default Key Bindings

When installed as a tmux plugin:

| Key | Action |
|-----|--------|
| `prefix + m` | Toggle work session |
| `prefix + M` | Show wisp menu |
| `prefix + _` | Stop current session |

### Status Bar Integration

WISP automatically integrates with your tmux status bar, showing:

- 🔄 **Running**: `󰥔 23:45` (time remaining)
- ⏸️ **Paused**: `󰏤 23:45` (time when paused)
- ✅ **Completed**: `󰒲 Inactive` (session finished)
- 💤 **Inactive**: `󰒲 Inactive` (no active session)

## 📊 Session Tracking

All sessions are logged to `~/.wisp.yml` with detailed information:

```yaml
sessions:
  - date: 2024-01-15
    start_time: 09:30
    start_timestamp: 1705312200
    type: work
    planned_minutes: 25
    status: completed
    end_time: 09:55
    end_timestamp: 1705313700
```

### Statistics Available

- Total sessions (completed, cancelled, in progress)
- Daily session counts and total time
- Session history with time ranges
- Completion rates and patterns

## 🛠️ Advanced Configuration

### Environment Variables

- `WISP_CONFIG_DIR`: Custom config directory (default: `~/.config/wisp`)
- `WISP_LOG_FILE`: Custom log file location (default: `~/.wisp.yml`)

### Session Auto-completion

Sessions automatically complete when the timer reaches zero. Completed sessions are marked in the log and the status returns to inactive.

## 🔧 Troubleshooting

### Common Issues

**Q: wisp command not found**
A: Ensure `~/.local/bin` is in your PATH or run the install script again.

**Q: Tmux status not updating**
A: Check that `status-interval` is set to 1 second: `set -g status-interval 1`

**Q: Colors not working in tmux**
A: Verify color variables are set in your tmux.conf and that you're using the tmux format.

**Q: Sessions not saving**
A: Check write permissions for `~/.wisp.yml` and ensure the directory exists.

### Debug Mode

Enable verbose logging:

```bash
WISP_DEBUG=1 wisp start
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- Inspired by the Pomodoro Technique
- Built for seamless tmux integration
- Designed for terminal-focused workflows

---

**Happy focused work! 🎯**