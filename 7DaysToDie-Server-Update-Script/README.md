# 7 Days to Die — Automated Server Update Script
A fully automated, Horde‑safe, player‑aware update system for 7 Days to Die dedicated servers.
This script checks for new Steam builds, warns players, avoids Horde Night, updates the server, and restarts it — all with Discord notifications and detailed logging.

## Overview
Running a 7 Days to Die server means dealing with frequent experimental updates, unexpected build pushes, and the risk of corrupting worlds if updates happen at the wrong time.
This script solves that by automating the entire update workflow safely and intelligently.

Includes:
- Steam version checking
- Player count detection
- RCON integration
- Discord notifications
- Locking to prevent duplicate runs
- Full logging
- Notifications during shutdown and restart
Perfect for cron‑based automation.

## Features
### ✔ Automatic Version Detection
The script compares:
- Latest experimental build ID from SteamCMD
- Currently installed build ID from appmanifest_294420.acf

If they differ, an update is required.

### ✔ Player‑Aware Updating
If players are online:
- The script warns them with a 5‑minute countdown
- Messages are sent every minute, then every second in the final minute
- Discord receives update notifications
If no players are online, the update proceeds immediately.

### ✔ Horde Night Protection
The script refuses to update during:
- Horde Night evening (Day % 7 == 0, hour ≥ 19)
- Post‑Horde early morning (Day % 7 == 1, hour < 4)
Prevents player deaths.

### ✔ RCON Integration
The script uses RCON to fetch:
- Player count
- Current in‑game day
- Current in‑game time
And to broadcast countdown messages.

### ✔ Discord Notifications
Every major event is pushed to Discord:
- Update detected
- Countdown warnings
- Server stopping
- Server updating
- Server restarting
- Update complete

### ✔ Lockfile Protection
A lockfile prevents overlapping runs:
```
/tmp/7daysUpdate.lock
```
If the script is already running, new instances exit immediately.

### ✔ Full Logging
All output is redirected to:
```
/home/user/Log/cronlog.txt
```
This includes timestamps, errors, warnings, and update results.

## How It Works
### 1. Acquire Lock
Prevents duplicate executions.

### 2. Fetch Latest Steam Version
Uses SteamCMD and a custom script to extract the latest experimental build ID.

### 3. Read Installed Version
Parses the server’s appmanifest_294420.acf.

### 4. Check Player Count
Uses RCON to determine if players are online.

### 5. Check Horde Night Safety
The script determines if the current in‑game time is safe for an update.

### 6. Update Logic
If an update is needed:
- Warn players (if any)
- Send Discord notifications
- Stops the server
- Run SteamCMD update
- Restarts the server
- Confirms completion
If no update is needed, it logs the current version and exits cleanly.

## Example Cron Entry
Run the updater every 10 minutes:
```
*/10 * * * * /home/user/scripts/7days_update.sh
```
## Requirements
- SteamCMD
- RCON CLI tool
- Systemd service named 7daystodie
- Discord webhook script (discord_msg.sh)
- Bash 4+

## File Structure (Recommended)
```
/home/user/scripts/
    ├── 7days_update.sh
    ├── 7daysappinfo.txt
    ├── 7daysscript.txt
    ├── discord_msg.sh
/home/user/7days/
    └── steamapps/appmanifest_294420.acf
/home/user/Log/
    └── cronlog.txt
```
## Notes
- This script is designed for experimental branch servers.
- If your server uses mods, you may want to add a mod‑update hook.
