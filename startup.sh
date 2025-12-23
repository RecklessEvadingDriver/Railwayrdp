#!/bin/bash

# Set root password if provided via environment variable
if [ ! -z "$ROOT_PASSWORD" ]; then
    echo "root:$ROOT_PASSWORD" | chpasswd
    echo "Password set for root user"
else
    echo "root:railway123" | chpasswd
    echo "Default password set for root user"
fi

# Generate SSH host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Create necessary directories
mkdir -p /var/run/sshd
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Print connection information
echo "========================================"
echo "Railway VPS Server Started"
echo "========================================"
echo "SSH Port: 22"
echo "Username: root"
echo "Password: ${ROOT_PASSWORD:-railway123}"
echo "========================================"
echo "System Resources:"
echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo "CPU Cores: $(nproc)"
echo "========================================"
echo "To connect from Termux:"
echo "1. Install openssh: pkg install openssh"
echo "2. Connect using: ssh root@YOUR_RAILWAY_URL"
echo "3. Enter password when prompted"
echo "========================================"
echo "To connect with custom port (if needed):"
echo "ssh -p PORT root@YOUR_RAILWAY_URL"
echo "========================================"

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
