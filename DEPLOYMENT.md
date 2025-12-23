# Railway VPS Deployment Guide

## Prerequisites
- Railway.app account
- GitHub account
- Termux (for Android access) or SSH client

## Step-by-Step Deployment

### 1. Prepare Repository
```bash
# Fork or clone this repository
git clone https://github.com/YOUR_USERNAME/Railwayrdp.git
cd Railwayrdp
```

### 2. Deploy on Railway

#### Option A: Deploy via Railway Dashboard
1. Login to [Railway.app](https://railway.app)
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose the `Railwayrdp` repository
5. Railway will automatically detect the Dockerfile
6. Wait for the build to complete

#### Option B: Deploy via Railway CLI
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Deploy
railway up
```

### 3. Configure Service

1. **Enable TCP Proxy** (Critical for SSH access):
   - Go to your service in Railway dashboard
   - Click on "Settings" tab
   - Scroll to "Networking" section
   - Enable "TCP Proxy"
   - A domain and port will be assigned (e.g., `example.railway.app:12345`)

2. **Add Environment Variable** (Optional):
   - Go to "Variables" tab
   - Add variable: `ROOT_PASSWORD` with your desired password
   - Default is `railway123` if not set
   - Click "Add" and redeploy

3. **Verify Deployment**:
   - Check "Deployments" tab for build status
   - View logs to confirm SSH service started
   - Look for "Railway VPS Server Started" message
   - Note your connection details from logs

### 4. Connect from Termux

```bash
# Install Termux from F-Droid (recommended)
# Open Termux and run:

# Update packages
pkg update && pkg upgrade -y

# Install OpenSSH
pkg install openssh -y

# Connect to your VPS
ssh root@your-app.railway.app

# Or with custom port (check Railway settings)
ssh -p PORT root@your-app.railway.app

# Enter password when prompted
# Default: railway123
```

### 5. Connect from Desktop

#### Linux/macOS
```bash
# Standard SSH
ssh root@your-app.railway.app

# With custom port
ssh -p PORT root@your-app.railway.app

# Verbose mode for debugging
ssh -v root@your-app.railway.app
```

#### Windows (Command Prompt/PowerShell)
```cmd
ssh root@your-app.railway.app
```

#### Windows (PuTTY)
1. Download PuTTY from [putty.org](https://www.putty.org/)
2. Open PuTTY
3. Enter hostname: `your-app.railway.app`
4. Enter port: `PORT` (from Railway settings)
5. Click "Open"
6. Login: `root` / `railway123`

## Verification

After connecting, verify your environment:

```bash
# Check you're root
whoami
# Output: root

# Check system resources
free -h
# Should show ~32GB RAM

nproc
# Should show 32 CPU cores

# Check root privileges
sudo -l
# Should show (ALL : ALL) ALL

# Check disk space
df -h

# Check network
ip a

# Check installed tools
which python3 node npm docker git
```

## Post-Deployment Setup

### 1. Change Root Password

```bash
# SSH into VPS
ssh root@your-app.railway.app

# Change password
passwd root

# Enter new password twice
```

### 2. Set Up SSH Key Authentication (Recommended)

From your local machine (Termux or desktop):

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to VPS
ssh-copy-id root@your-app.railway.app

# Test connection (should not ask for password)
ssh root@your-app.railway.app
```

Manual method:
```bash
# On local machine, get your public key
cat ~/.ssh/id_ed25519.pub

# Copy the output

# On VPS
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "PASTE_YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 3. Install Additional Software

```bash
# Update package lists
apt-get update && apt-get upgrade -y

# Install web servers
apt-get install -y nginx apache2

# Install databases
apt-get install -y postgresql mysql-server redis-server mongodb

# Install additional languages
apt-get install -y php ruby golang-go rust

# Install monitoring tools
apt-get install -y htop btop iotop nethogs

# Install text editors
apt-get install -y emacs neovim

# Install security tools
apt-get install -y fail2ban ufw
```

### 4. Configure Docker

```bash
# Start Docker daemon
dockerd &

# Or add to startup in supervisord.conf

# Test Docker
docker run hello-world

# Run a web server
docker run -d -p 80:80 nginx
```

### 5. Set Up Firewall (Optional)

```bash
# Install UFW
apt-get install -y ufw

# Allow SSH
ufw allow 22/tcp

# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw enable

# Check status
ufw status
```

## Resource Monitoring

Monitor your 32GB RAM / 32 vCPU resources:

```bash
# Interactive process monitoring
htop

# Or use btop (modern alternative)
btop

# Memory usage
free -h
watch -n 1 free -h

# CPU information
lscpu
cat /proc/cpuinfo

# Disk usage
df -h
du -sh /*

# I/O statistics
iostat -x 1

# Network monitoring
nethogs  # Real-time bandwidth by process
iftop    # Network interface monitoring
ss -tuln # Socket statistics

# System load
uptime
w
```

## Common Tasks

### Web Application Deployment

```bash
# Install Node.js app
cd /opt
git clone YOUR_REPO
cd YOUR_REPO
npm install
npm start &

# Or use PM2 for process management
npm install -g pm2
pm2 start app.js
pm2 startup
pm2 save
```

### Database Setup

```bash
# PostgreSQL
service postgresql start
sudo -u postgres psql
CREATE DATABASE mydb;
\q

# MySQL
service mysql start
mysql -u root -p
CREATE DATABASE mydb;
exit;

# Redis
service redis-server start
redis-cli ping
```

### Nginx Configuration

```bash
# Start Nginx
service nginx start

# Test configuration
nginx -t

# Reload
nginx -s reload

# Configure site
nano /etc/nginx/sites-available/default
```

## Troubleshooting

### Build Fails on Railway
- Check Railway build logs in dashboard
- Ensure Dockerfile is in repository root
- Verify all COPY commands reference existing files
- Check for syntax errors in Dockerfile

### Cannot Connect via SSH

1. **Check TCP Proxy is enabled**:
   - Railway dashboard → Service → Settings → Networking
   - TCP Proxy must be ON

2. **Verify connection details**:
   ```bash
   # Check Railway logs for connection info
   # Note the exact domain and port
   ```

3. **Test connectivity**:
   ```bash
   # Test if port is reachable
   nc -zv your-app.railway.app PORT
   
   # Or use telnet
   telnet your-app.railway.app PORT
   ```

4. **Try verbose SSH**:
   ```bash
   ssh -vvv root@your-app.railway.app
   ```

### Authentication Failed

1. Check password is correct (default: `railway123`)
2. Verify ROOT_PASSWORD environment variable in Railway
3. Check Railway logs for password confirmation
4. Try resetting password via environment variable

### Connection Drops/Timeout

```bash
# Keep connection alive
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3 root@your-app.railway.app

# Or add to ~/.ssh/config:
cat >> ~/.ssh/config << EOF
Host railway-vps
    HostName your-app.railway.app
    Port PORT
    User root
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF

# Then connect with:
ssh railway-vps
```

### Docker Won't Start

```bash
# Start manually
dockerd &

# Check logs
journalctl -u docker

# Or add to supervisor config for auto-start
```

### Performance Issues

```bash
# Check CPU usage
top
htop

# Check memory
free -h

# Check I/O wait
iostat -x 1

# Check network
iftop
nethogs

# Check for resource-heavy processes
ps aux --sort=-%mem | head
ps aux --sort=-%cpu | head
```

## Security Best Practices

### 1. Disable Password Authentication

After setting up SSH keys:

```bash
# Edit SSH config
nano /etc/ssh/sshd_config

# Change these lines:
PasswordAuthentication no
PermitRootLogin prohibit-password

# Restart SSH
service ssh restart
```

### 2. Install Fail2ban

```bash
# Install
apt-get install -y fail2ban

# Configure
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
nano /etc/fail2ban/jail.local

# Start
service fail2ban start
systemctl enable fail2ban

# Check status
fail2ban-client status sshd
```

### 3. Keep System Updated

```bash
# Create update script
cat > /root/update.sh << 'EOF'
#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get autoremove -y
apt-get autoclean
EOF

chmod +x /root/update.sh

# Run weekly (add to crontab)
crontab -e
# Add: 0 3 * * 0 /root/update.sh
```

### 4. Monitor Logs

```bash
# Auth logs
tail -f /var/log/auth.log

# System logs
journalctl -f

# Failed login attempts
grep "Failed password" /var/log/auth.log

# Successful logins
grep "Accepted password" /var/log/auth.log
```

## Advanced Usage

### SSH Config File

Create `~/.ssh/config` on your local machine:

```
Host railway-vps
    HostName your-app.railway.app
    Port 12345
    User root
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes
```

Then connect simply with:
```bash
ssh railway-vps
```

### Port Forwarding

```bash
# Local → Remote (access VPS service locally)
ssh -L 8080:localhost:80 root@your-app.railway.app
# Now visit localhost:8080 in browser

# Remote → Local (expose local service via VPS)
ssh -R 8080:localhost:3000 root@your-app.railway.app
# Now VPS:8080 forwards to your local:3000

# Dynamic forwarding (SOCKS proxy)
ssh -D 9999 root@your-app.railway.app
# Configure browser to use SOCKS5 proxy localhost:9999
```

### Persistent Storage

```bash
# Add volume in Railway dashboard
# Mount at /data

# Move application data to persistent storage
mkdir -p /data/apps
mkdir -p /data/databases
mkdir -p /data/logs

# Example: Move PostgreSQL data
service postgresql stop
mv /var/lib/postgresql /data/
ln -s /data/postgresql /var/lib/postgresql
service postgresql start
```

### Automated Backups

```bash
# Create backup script
cat > /root/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/data/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup databases
mysqldump --all-databases > $BACKUP_DIR/mysql_$DATE.sql
sudo -u postgres pg_dumpall > $BACKUP_DIR/postgres_$DATE.sql

# Backup important directories
tar -czf $BACKUP_DIR/apps_$DATE.tar.gz /opt/*

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete
EOF

chmod +x /root/backup.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /root/backup.sh
```

## Support

For issues:
- **Railway Platform**: [Railway Docs](https://docs.railway.app)
- **SSH Issues**: Check OpenSSH documentation
- **This Project**: Open issue on GitHub

## Next Steps

✅ Connect to VPS via SSH
✅ Change default password  
✅ Set up SSH key authentication
✅ Install required software
✅ Configure firewall
✅ Set up monitoring
✅ Configure persistent storage
✅ Set up automated backups

---

**Enjoy your Railway VPS!** 🚀
