# Packet Tracker

Measures current packet loss and writes the result as a percentage to `packet_loss.txt`. Each measurement is also appended to `packet_loss.log`.

## Usage

```bash
./track_packet_loss.sh              # defaults to 8.8.8.8
./track_packet_loss.sh 1.1.1.1     # custom host
```

## Running as a daemon

Service definitions are in the `service/` directory. In the relevant file, replace `/INSTALL_PATH` with the absolute path to this repo (e.g. `/home/alice/packet-tracker`).

### macOS — launchd

1. Edit the plist, replacing `/INSTALL_PATH` with your actual path:
   ```bash
   sed -i '' 's|/INSTALL_PATH|/your/actual/path|g' service/com.packet-tracker.plist
   ```

2. Copy it to the LaunchAgents directory:
   ```bash
   cp service/com.packet-tracker.plist ~/Library/LaunchAgents/
   ```

3. Load the service:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.packet-tracker.plist
   ```

The daemon starts automatically on login. Logs are written to `daemon.log` in this directory.

| Action | Command |
|--------|---------|
| Stop   | `launchctl unload ~/Library/LaunchAgents/com.packet-tracker.plist` |
| Start  | `launchctl load ~/Library/LaunchAgents/com.packet-tracker.plist` |
| Status | `launchctl list \| grep packet-tracker` |

### Linux — systemd

1. Edit the unit file, replacing `/INSTALL_PATH` with your actual path:
   ```bash
   sed -i 's|/INSTALL_PATH|/your/actual/path|g' service/packet-tracker.service
   ```

2. Copy it to the systemd user directory:
   ```bash
   mkdir -p ~/.config/systemd/user
   cp service/packet-tracker.service ~/.config/systemd/user/
   ```

3. Enable and start the service:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now packet-tracker.service
   ```

The service starts on login and restarts automatically if it crashes.

| Action  | Command |
|---------|---------|
| Stop    | `systemctl --user stop packet-tracker` |
| Start   | `systemctl --user start packet-tracker` |
| Restart | `systemctl --user restart packet-tracker` |
| Status  | `systemctl --user status packet-tracker` |
| Logs    | `journalctl --user -u packet-tracker -f` |

## Frontends

### Starship prompt

Displays the current packet loss percentage in your shell prompt. Merge the config into your `~/.config/starship.toml`:

```bash
cat frontends/starship/packet_loss.toml >> ~/.config/starship.toml
```

Then add `custom.packet_loss` to your prompt `format` line:

```toml
format = "... $custom.packet_loss..."
```

Shows the current packet loss percentage (e.g. `20%`). Hidden when loss is 0% or the daemon isn't running.
