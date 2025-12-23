# Example Custom Configuration for Railway VPS

## Environment Variables

You can set these in Railway dashboard under "Variables" tab:

```
# Root password (change this!)
ROOT_PASSWORD=your_secure_password_here

# Optional: SSH port (default: 22)
SSH_PORT=22

# Optional: Additional configuration
LANG=en_US.UTF-8
TZ=America/New_York
```

## Adding Custom Services

### Example 1: Auto-start Docker daemon

Edit `supervisord.conf`:

```ini
[program:docker]
command=/usr/bin/dockerd
autostart=true  # Change from false to true
autorestart=true
```

### Example 2: Auto-start your application

Add to `supervisord.conf`:

```ini
[program:myapp]
command=/opt/myapp/start.sh
directory=/opt/myapp
autostart=true
autorestart=true
user=root
stdout_logfile=/var/log/myapp.log
stderr_logfile=/var/log/myapp-error.log
```

### Example 3: Auto-start web server

Add to `supervisord.conf`:

```ini
[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true
stdout_logfile=/var/log/nginx-access.log
stderr_logfile=/var/log/nginx-error.log
```

## Custom Startup Scripts

### Add commands to startup.sh

Edit `startup.sh` and add your commands before the final `exec` line:

```bash
# Your custom initialization here

# Example: Clone your repository
git clone https://github.com/youruser/yourrepo.git /opt/myapp

# Example: Install Python dependencies
pip3 install -r /opt/myapp/requirements.txt

# Example: Set up database
service postgresql start
sudo -u postgres createdb mydb

# Example: Configure firewall
ufw allow 80/tcp
ufw allow 443/tcp

# Keep this at the end
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
```

## Custom Dockerfile Additions

### Install additional software

Add before the `CMD` line in `Dockerfile`:

```dockerfile
# Install additional databases
RUN apt-get update && apt-get install -y \
    postgresql \
    redis-server \
    mongodb \
    && apt-get clean

# Install additional languages
RUN apt-get update && apt-get install -y \
    ruby \
    golang-go \
    php \
    && apt-get clean

# Install custom tools
RUN pip3 install jupyter pandas numpy
RUN npm install -g pm2 typescript

# Copy your application
COPY ./myapp /opt/myapp
RUN chmod +x /opt/myapp/start.sh
```

## SSH Key Authentication

### Set up passwordless login (more secure)

1. **On your local machine (Termux or desktop):**

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub
```

2. **Add public key to Dockerfile:**

```dockerfile
# Add your SSH public key
RUN mkdir -p /root/.ssh && \
    echo "ssh-ed25519 AAAAC3... your_email@example.com" >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys
```

3. **Disable password authentication (optional):**

Edit Dockerfile SSH configuration:

```dockerfile
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
```

## Persistent Data with Railway Volumes

### Configure persistent storage

1. In Railway dashboard:
   - Go to your service
   - Click "Volumes" tab
   - Add volume, mount at `/data`

2. Update your application to use `/data`:

```bash
# In startup.sh or your app
mkdir -p /data/databases
mkdir -p /data/uploads
mkdir -p /data/logs

# Link to persistent storage
ln -sf /data/databases /var/lib/postgresql
ln -sf /data/logs /var/log/myapp
```

## Resource Limits

### Optimize for different workloads

#### For CPU-intensive tasks:

Add to Dockerfile:

```dockerfile
# Optimize for multi-core compilation
ENV MAKEFLAGS="-j32"
ENV CMAKE_BUILD_PARALLEL_LEVEL=32
```

#### For memory-intensive tasks:

Add to startup.sh:

```bash
# Configure swap if needed (though Railway provides 32GB RAM)
# Usually not necessary with 32GB RAM

# Configure system limits
ulimit -n 65535  # Max open files
ulimit -u 65535  # Max user processes
```

## Custom Networking

### Port forwarding examples

Add to Dockerfile:

```dockerfile
# Expose additional ports
EXPOSE 22    # SSH (already exposed)
EXPOSE 80    # HTTP
EXPOSE 443   # HTTPS
EXPOSE 3000  # Your app
EXPOSE 5432  # PostgreSQL
EXPOSE 6379  # Redis
EXPOSE 27017 # MongoDB
```

Then in Railway dashboard, you can map these ports.

## Security Hardening

### Add fail2ban for SSH protection

Add to Dockerfile:

```dockerfile
RUN apt-get update && apt-get install -y fail2ban
COPY fail2ban.conf /etc/fail2ban/jail.local
```

Create `fail2ban.conf`:

```ini
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

### Add firewall rules

Add to startup.sh:

```bash
# Configure UFW
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
```

## Monitoring Setup

### Add system monitoring

Add to Dockerfile:

```dockerfile
# Install monitoring tools
RUN apt-get update && apt-get install -y \
    prometheus-node-exporter \
    grafana \
    netdata
```

Add to supervisord.conf:

```ini
[program:node-exporter]
command=/usr/bin/prometheus-node-exporter
autostart=true
autorestart=true

[program:netdata]
command=/usr/sbin/netdata -D
autostart=true
autorestart=true
```

## Automated Backups

### Create backup script

Add to Docker image:

```dockerfile
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh
```

Create `backup.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/data/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup databases
pg_dumpall > $BACKUP_DIR/postgres_$DATE.sql
mongodump --out $BACKUP_DIR/mongo_$DATE

# Backup application data
tar -czf $BACKUP_DIR/app_$DATE.tar.gz /opt/myapp

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup completed: $DATE"
```

Add to startup.sh:

```bash
# Schedule daily backups
echo "0 2 * * * /usr/local/bin/backup.sh" | crontab -
```

## Example: Complete Node.js App Setup

```dockerfile
# Add after the main RUN command in Dockerfile

# Install PM2 for Node.js process management
RUN npm install -g pm2

# Copy application
COPY myapp /opt/myapp
WORKDIR /opt/myapp
RUN npm install

# Expose application port
EXPOSE 3000
```

Add to supervisord.conf:

```ini
[program:nodejs-app]
command=pm2 start /opt/myapp/app.js --no-daemon
directory=/opt/myapp
autostart=true
autorestart=true
stdout_logfile=/var/log/nodejs-app.log
stderr_logfile=/var/log/nodejs-app-error.log
```

---

**Note**: After making changes to Dockerfile, supervisord.conf, or startup.sh, commit and push to GitHub, then redeploy on Railway.
