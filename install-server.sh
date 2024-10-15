#!/bin/bash

# Ensure script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Put your Server IP here.
SERVER_IP=$1
if [ -z "$SERVER_IP" ]; then
    echo "Usage: $0 <SERVER_IP>"
    exit 1
fi

# Update and install dependencies
echo "Updating and installing dependencies..."
apt-get update && apt-get install -y python3-venv python3-pip git qrencode

# Clone Algo VPN repository
echo "Cloning Algo VPN repository..."
git clone https://github.com/N4hu4t/Algo-VPN.git
# git clone https://github.com/trailofbits/algo.git (original repository)
cd algo

# Remove the line '/usr/lib/ipsec/lookip' from ubuntu.yml
echo "Removing problematic line from the Algo VPN configuration..."
sed -i '/\/usr\/lib\/ipsec\/lookip/d' /root/algo/roles/strongswan/tasks/ubuntu.yml
# lookip is not installed in ubuntu 22/24 you may installed if you want.
echo "Remove possible hold packages"
rm /var/lib/dpkg/lock-frontend
rm /var/lib/dpkg/lock
rm /var/lib/apt/lists/lock
rm /var/cache/apt/archives/lock
echo "Installing Algo..."
# Install Algo VPN
echo "Setting up Python virtual environment and installing Algo dependencies..."
python3 -m venv env
source env/bin/activate
python3 -m pip install -U pip virtualenv
python3 -m pip install -r requirements.txt

# Run Algo VPN setup
echo "Running Algo setup..."
./algo

echo "Generating qr code..."
qrencode -t ansiutf8 < /root/algo/configs/$SERVER_IP/wireguard/phone.conf
# Completion message
echo "Setup is complete! Algo VPN is running with Stunnel on port 443 for obfuscation."
