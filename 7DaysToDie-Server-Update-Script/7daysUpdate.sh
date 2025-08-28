#!/bin/bash

LOCKFILE="/tmp/7daysUpdate.lock"
LOGFILE="/home/user/Log/cronlog.txt"

# Acquire lock
exec 200>"$LOCKFILE"
flock -n 200 || exit 1

# Deletes Lock File if still exists on restart
trap 'rm -f "$LOCKFILE"' EXIT

# Redirect all output to log file
exec >> "$LOGFILE" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] --- Script started ---"

# Fetch latest experimental version from SteamCMD
latest_version=$(/usr/games/steamcmd +runscript /home/user/scripts/7daysappinfo.txt \
    | grep -A 2 "latest_experimental" \
    | grep buildid \
    | sed 's/[^0-9]//g')

# Get currently installed version
current_version=$(grep buildid /home/user/7days/steamapps/appmanifest_294420.acf \
    | sed 's/[^0-9]//g')

# Get current player count
player_count=$(rcon -c /usr/local/bin/rcon.yaml -e 7dtd -t telnet lp \
    | grep Total \
    | sed 's/[^0-9]//g')

# Get the current day in game
day_count=$(rcon -c /usr/local/bin/rcon.yaml -e 7dtd -t telnet gt \
    | grep Day \
    | sed -n 's/^Day \([0-9]\+\),.*/\1/p')

# Get the current time in game
current_time=$(rcon -c /usr/local/bin/rcon.yaml -e 7dtd -t telnet gt \
    | grep Day \
    | sed -n 's/.*, *//p')

# Extract hours and minutes
hour=${current_time%%:*}
minute=${current_time##*:}
#hour=${hour#0}

# Validate version numbers
if ! [[ "$latest_version" =~ ^[0-9]+$ ]] || ! [[ "$current_version" =~ ^[0-9]+$ ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Invalid version numbers. latest=$latest_version current=$current_version"
    /home/user/scripts/discord_msg.sh "Update Error Detected" "🚨🚨🚨**ERROR**🚨🚨🚨\n**Invalid Version Numbers**\n*Latest*: $latest_version\n*Current*: $current_version" 16711680
    exit 1
fi

# Validate player count (fallback to 1 if not a number)
if ! [[ "$player_count" =~ ^[0-9]+$ ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Could not detect player count. Defaulting to 0."
    player_count=0
fi

# Function to warn players and perform update
perform_update_with_warning() {
    if [ "$1" == "warn" ]; then
	/home/user/scripts/discord_msg.sh "Server Update Detected" "🛠️🛠️🛠️**Updating**🛠️🛠️🛠️\n**Versions**\n*Latest*: $latest_version *Current*: $current_version\nServer restart in 5 minutes" 15105570
        for ((i=300; i>=0; i--)); do
            if [ $i -gt 60 ]; then
                if (( i % 60 == 0 )); then
                    msg="Say \"Server restarting for an update in $((i / 60)) minute(s)\""
                    rcon -c /usr/local/bin/rcon.yaml -e 7dtd -t telnet "$msg"
                fi
            else
                msg="Say \"Server restarting for an update in $i second(s)\""
                rcon -c /usr/local/bin/rcon.yaml -e 7dtd -t telnet "$msg"
            fi
            sleep 1
        done
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] New version detected. Stopping server..."
    /home/user/scripts/discord_msg.sh "Server Update Detected" "🛠️🛠️🛠️**Updating**🛠️🛠️🛠️\n**Versions**\n*Latest*: $latest_version *Current*: $current_version\nStopping the Server." 15105570
    sudo systemctl stop 7daystodie

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Updating server..."
    /home/user/scripts/discord_msg.sh "Starting Server Update" "⏳⏳⏳**Server Stopped**⏳⏳⏳" 3447003
    /usr/games/steamcmd +runscript /home/user/scripts/7daysscript.txt

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting server..."
    /home/user/scripts/discord_msg.sh "Server Update Complete" "⏳⏳⏳**Starting Server**⏳⏳⏳" 3066993
    sudo systemctl start 7daystodie

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Update complete."
    /home/user/scripts/discord_msg.sh "Server Update Complete" "✅✅✅**Server Started**✅✅✅" 3066993
}

# Function to determine if it's safe to update (i.e., not during Horde Night)
is_safe_to_update() {
    # Strip leading zeros from hour to avoid octal issues
    local normalized_hour=$((10#$hour))

    # Return 0 (true) if it's safe, 1 (false) if it's Horde time
    if ((
        (day_count % 7 == 0 && normalized_hour >= 19) ||        # During Horde Day evening
        ((day_count - 1) % 7 == 0 && normalized_hour < 4)       # After midnight on post-Horde night
    )); then
        return 1  # NOT safe to update
    else
        return 0  # Safe to update
    fi
}

# Main logic
if [ "$latest_version" != "$current_version" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Update required. latest=$latest_version current=$current_version"
    if [ "$player_count" -gt 0 ]; then
        if is_safe_to_update; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Players online: $player_count. Warning before update."
            perform_update_with_warning "warn"
        else
	    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Horde Day: Active, $player_count player(s) online. Temporarily skipping update."
	fi
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] No players online. Proceeding with update."
        perform_update_with_warning
    fi
else
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Connected: $player_count No update needed. Server Version: $current_version Steam Version: $latest_version."
fi
