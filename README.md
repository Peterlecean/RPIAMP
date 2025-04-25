# An Efficient VPN Solution for a Geographically Distributed Sensor Network

## Overview

This project provides a modular, secure, and lightweight VPN-based architecture to connect sensor nodes deployed across different geographical areas. Designed for use with Raspberry Pi or NUC systems, it integrates OpenVPN for secure networking, SDR for signal processing, and dynamic DNS for seamless remote access.

## Hardware & Requirements

- Raspberry Pi Zero 2 W or Intel NUC
- USB SDR dongle (RTL-SDR or equivalent)
- Linux-based OS (Debian/Ubuntu recommended)
- Internet connection for each node
- OpenVPN and Easy-RSA packages
- DuckDNS account (free)

## Installation

Clone the repository and run the automated setup script (with sudo):

```bash
git clone https://github.com/Peterlecean/RPIAMP.git
cd RPIAMP
chmod +x setup.sh
./setup.sh
```

The script handles package installation, VPN configuration, and DuckDNS setup.

## Configuration Steps

1. **Generate OpenVPN credentials** for each node.
2. **Edit DuckDNS config** to link dynamic IPs to each node's hostname.
3. **Configure SDR settings** (optional) to receive/stream data.
4. **Deploy client configs** and test the VPN tunnel.

## Use Cases

- Remote environmental monitoring
- Distributed acoustic sensing
- IoT network management
- Emergency or field-deployed networks

## License

This project is open-source and licensed under the GPL-3.0 License.
