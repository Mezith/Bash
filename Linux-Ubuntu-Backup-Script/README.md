### System Backup Script
An automated Bash script for creating compressed system backups with logging, exclusions, stored to an external and local drive.

## Overview
This script creates a full system backup using tar, writes it to a temporary internal location, and then moves the completed archive to a final destination (typically an external drive). It includes:
- Automatic logging
- Exclusions
- Safe temporary staging before final transfer
- Runtime duration tracking

## Cleanup of old backups

It’s designed for reliability and simplicity — ideal for scheduled backups via cron or manual runs.

## Features
- Full system backup using tar -czf
- Excludes volatile or unnecessary directories (/proc, /sys, /dev, /run, etc.)
- Prevents recursion by excluding the backup directories themselves
- Writes to a temporary internal location first to avoid partial backups on external drives
- Moves completed backup to final destination
- Logs all actions to a logfile
- Tracks total runtime

## File Paths
These paths can be customized inside the script:
| Purpose | Default Path |
| --- | --- |
| Temporary backup location | ``/home/user/BackupTempLg/backup.tar.gz`` |
| Final backup location | ``/home/user/Backups/backup.tar.gz`` |
| Log file | ``/home/user/BackupTempLg/backup.log`` |

## Usage
Manually:
```
./backup.sh
```
Or scheduled via cron:
```
0 3 * * * /path/to/backup.sh
```
This example runs the backup every day at 3 AM.

## What the Script Does
### 1. Starts Logging
All output (stdout + stderr) is redirected to the logfile:
```
/home/user/BackupTempLg/backup.log
```
### 2. Creates a Compressed Backup
The script uses tar to archive the entire filesystem while excluding:
- Virtual filesystems (/proc, /sys, /dev, /run)
- Temporary directories (/tmp, /var/tmp)
- Mount points (/mnt, /media)
- Backup directories themselves
- Lost+found

This prevents unnecessary data and recursion.
### 3. Removes Old Backup
If a previous backup exists at the final destination, it is removed.

### 4. Moves New Backup to Final Location
The completed archive is moved from the internal drive to the external drive (or any absolute path you use).

### 5. Logs Total Runtime
The script prints the total time taken in minutes and seconds.

## Example Log Output
```
2026-05-06 13:45:12 - Backup script started
2026-05-06 13:45:12 - Creating backup at /home/user/BackupTempLg/backup.tar.gz
2026-05-06 13:47:03 - Backup created successfully
2026-05-06 13:47:03 - Removing old backup
2026-05-06 13:47:03 - Moving new backup to /home/user/Backups/backup.tar.gz
2026-05-06 13:47:03 - Backup completed in 1 min 51 sec
```

## Requirements
- Bash 4+
- Sufficient disk space for temporary and final backup locations
- Permissions to read system directories and write to backup paths

## Notes
- This script is intended for full system backups.
- For incremental or differential backups, consider layering rsync or borg on top.
- Ensure your external drive is mounted before running the script.
