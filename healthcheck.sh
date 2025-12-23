#!/bin/bash
# Health check script for Railway

# Check if SSH is running
if pgrep -x "sshd" > /dev/null; then
    echo "✓ SSH daemon is running"
else
    echo "✗ SSH daemon is not running"
    exit 1
fi

# Check if port 22 is listening
if netstat -tuln | grep -q ":22"; then
    echo "✓ Port 22 is listening"
else
    echo "✗ Port 22 is not listening"
    exit 1
fi

# Check if supervisor is running
if pgrep -x "supervisord" > /dev/null; then
    echo "✓ Supervisor is running"
else
    echo "✗ Supervisor is not running"
    exit 1
fi

echo "✓ All services are healthy"
exit 0
