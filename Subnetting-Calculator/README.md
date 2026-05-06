# Subnetting Calculator
A lightweight, dependency‑free Bash tool for calculating network, broadcast, host ranges, and total hosts from a variety of mask formats.

## Overview
This script performs IPv4 subnet calculations using Bash — no external binaries, no ipcalc, no awk, no bc. It supports multiple input formats and handles all the bitwise logic internally.
You can enter an IP address paired with:
- CIDR notation (e.g., 192.168.1.10/24)
- Dotted‑decimal masks (e.g., 192.168.1.10/255.255.255.0)
- Hexadecimal masks (e.g., 192.168.1.10/0xffffff00)

### The script then outputs:
- Network address
- Broadcast address
- Usable host range
- Total usable hosts

All calculations are done using bitwise operations implemented in Bash.

## Features
- Supports CIDR, dotted masks, and hex masks
- Converts between binary, decimal, and hex mask formats
- Performs bitwise AND and OR on octets
- Calculates network, broadcast, first host, last host, and host count
- Bash (no external tools)
- Easy to read, extend, and integrate into larger scripts

## Usage
```
./subnet.sh IP/CIDR
./subnet.sh IP/MASK
./subnet.sh IP/0xHEX
```

## Examples

### CIDR
```
./subnet.sh 10.0.5.17/20
```
### Decimal Subnet
```
./subnet.sh 172.16.10.50/255.255.240.0
```
### Hex Subnet
```
./subnet.sh 192.168.1.10/0xffffff00
```
## Output Example
```
Network Address: 192.168.1.0
Broadcast Address: 192.168.1.255
Usable Host Range: 192.168.1.1 - 192.168.1.254
Total Hosts: 254
```

## Host Range
The script converts IPs to 32‑bit integers, increments/decrements, and converts back to octets:
- First usable host
- Last usable host
- Total usable hosts

## Requirements
- Bash 4+
- Linux or macOS
