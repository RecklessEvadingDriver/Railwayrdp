# Railway VPS Server

A containerized VPS (Virtual Private Server) designed for deployment on Railway.app with full root privileges and optimized for high-performance computing (32GB RAM / 32 vCPU). Access via SSH from anywhere, including Termux on Android.

## Features

- 🖥️ **Full SSH Access**: Complete terminal access with root privileges
- 🔐 **Root Privileges**: Full administrative access for deploying any application
- 📱 **Termux Compatible**: Easily accessible from Android devices via Termux terminal
- ⚡ **High Performance**: Optimized for Railway's 32GB RAM / 32 vCPU infrastructure
- 🐳 **Docker Ready**: Docker pre-installed for container deployments
- 🚀 **Quick Deploy**: One-click deployment on Railway.app
- 🛠️ **Development Tools**: Pre-installed with Python, Node.js, Git, and build tools

## Quick Start

### Deploy on Railway.app

1. **Fork this repository** to your GitHub account

2. **Create a new project on Railway**:
   - Go to [Railway.app](https://railway.app)
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose this repository

3. **Configure Environment Variables** (Optional):
   - `ROOT_PASSWORD`: Set a custom root password (default: railway123)

4. **Enable TCP Proxy** (Important for SSH):
   - Go to your service settings in Railway
   - Under "Networking" tab
   - Enable "TCP Proxy" 
   - Note the assigned domain and port

5. **Deploy**:
   - Railway will automatically detect the Dockerfile and build your container
   - Wait for the deployment to complete
   - Note the public URL and port provided by Railway

### Connect from Termux (Android)

1. **Install Termux** from F-Droid (recommended) or Google Play Store

2. **Install OpenSSH in Termux**:
   ```bash
   pkg update && pkg upgrade
   pkg install openssh
   ```

3. **Connect to your VPS**:
   ```bash
   ssh root@YOUR_RAILWAY_URL
   ```
   
   Or if Railway assigns a custom port:
   ```bash
   ssh -p PORT root@YOUR_RAILWAY_URL
   ```

   Enter password: `railway123` (or your custom password)

### Connect from Desktop

#### Any Platform (Linux/Mac/Windows)
```bash
ssh root@YOUR_RAILWAY_URL
```

Or with custom port:
```bash
ssh -p PORT root@YOUR_RAILWAY_URL
```

#### Windows (Alternative - PuTTY)
1. Download PuTTY from [putty.org](https://www.putty.org/)
2. Enter your Railway URL in "Host Name"
3. Set port (usually 22 or custom port from Railway)
4. Click "Open"
5. Login with username: `root` and your password

## Configuration

### Changing the Root Password

Set the `ROOT_PASSWORD` environment variable in your Railway project settings:

1. Go to your Railway project
2. Click on your service
3. Go to "Variables" tab
4. Add: `ROOT_PASSWORD=your_secure_password`
5. Redeploy the service

### Resource Optimization

The VPS is designed to leverage Railway's high-performance infrastructure:
- **32GB RAM**: Suitable for running multiple applications, databases, or development environments
- **32 vCPU**: Enables parallel processing and compilation
- **Docker Support**: Run containerized applications with ease

### Installing Additional Software

Once connected via SSH, you have full root access to install any software:

```bash
# Update package lists
apt-get update

# Install development tools
apt-get install -y python3-full python3-pip nodejs npm golang-go

# Install databases
apt-get install -y postgresql mysql-server mongodb redis-server

# Install web servers
apt-get install -y nginx apache2 caddy

# Install monitoring tools
apt-get install -y htop btop iotop nethogs
```

## Architecture

### Components

- **OpenSSH Server**: SSH daemon for secure remote access on port 22
- **Docker**: Container runtime for deploying applications
- **Supervisor**: Process manager to keep services running
- **Build Tools**: GCC, Make, and other essential compilation tools
- **Development Stack**: Python3, Node.js, NPM pre-installed

### File Structure

```
.
├── Dockerfile              # Container configuration
├── supervisord.conf        # Service manager configuration
├── startup.sh             # Initialization script
├── railway.json           # Railway deployment configuration
├── docker-compose.yml     # Local testing configuration
├── healthcheck.sh         # Health monitoring script
├── connect-termux.sh      # Quick connection guide
├── README.md              # This file
└── DEPLOYMENT.md          # Detailed deployment guide
```

## Common Use Cases

### 1. Web Application Hosting

```bash
# Install and configure nginx
apt-get install -y nginx
systemctl start nginx

# Deploy your app
git clone YOUR_REPO
cd YOUR_REPO
npm install
npm start
```

### 2. Docker Container Deployment

```bash
# Start Docker daemon
dockerd &

# Run containers
docker run -d -p 80:80 nginx
docker run -d -p 5432:5432 postgres
```

### 3. Development Environment

```bash
# Clone your project
git clone YOUR_PROJECT
cd YOUR_PROJECT

# Install dependencies
pip3 install -r requirements.txt
# or
npm install

# Run your application
python3 app.py
# or
npm start
```

### 4. Database Hosting

```bash
# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib

# Start PostgreSQL
service postgresql start

# Create database
sudo -u postgres createdb mydb
```

### 5. CI/CD Runner

```bash
# Install GitHub Actions runner
# Or GitLab runner
# Or Jenkins

# Configure and start
./run.sh
```

## Security Considerations

⚠️ **Important Security Notes**:

1. **Change the default password** immediately after deployment
   ```bash
   passwd root
   ```

2. **Use SSH keys instead of passwords** (Recommended):
   ```bash
   # On your local machine (Termux or desktop)
   ssh-keygen -t ed25519
   
   # Copy public key to VPS
   ssh-copy-id root@YOUR_RAILWAY_URL
   
   # Or manually add to authorized_keys
   cat ~/.ssh/id_ed25519.pub | ssh root@YOUR_RAILWAY_URL "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
   ```

3. **Disable password authentication** (after setting up SSH keys):
   ```bash
   # On VPS
   sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
   service ssh restart
   ```

4. **Keep the system updated** regularly:
   ```bash
   apt-get update && apt-get upgrade -y
   ```

5. **Configure firewall** (if needed):
   ```bash
   apt-get install -y ufw
   ufw allow 22/tcp
   ufw allow 80/tcp
   ufw allow 443/tcp
   ufw enable
   ```

6. **Monitor access logs**:
   ```bash
   tail -f /var/log/auth.log
   ```

## Troubleshooting

### Cannot connect to VPS

1. Check if the service is running on Railway
2. Verify you have TCP Proxy enabled in Railway settings
3. Check the correct URL and port
4. Ensure your firewall allows outbound SSH connections
5. Check Railway logs for any errors

### Connection refused

1. Verify SSH service is running:
   ```bash
   # In Railway logs, check for SSH startup messages
   ```
2. Try with verbose mode:
   ```bash
   ssh -v root@YOUR_RAILWAY_URL
   ```
3. Check if port is correct (Railway may assign custom port)

### Authentication failed

1. Verify you're using the correct password
2. Check if password was properly set via environment variable
3. Try resetting password in Railway variables

### Slow performance

1. Check resource usage:
   ```bash
   htop
   free -h
   ```
2. Monitor network:
   ```bash
   nethogs
   iftop
   ```
3. Check disk I/O:
   ```bash
   iotop
   ```

### Docker won't start

```bash
# Start Docker manually
dockerd &

# Check Docker status
docker ps

# If issues persist, check logs
journalctl -u docker
```

## Advanced Usage

### Setting up SSH Key Authentication

From Termux or your local machine:

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to VPS
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@YOUR_RAILWAY_URL

# Now you can connect without password
ssh root@YOUR_RAILWAY_URL
```

### Running Services

```bash
# Using systemd
systemctl start service_name
systemctl enable service_name

# Using supervisor (already installed)
# Edit /etc/supervisor/conf.d/supervisord.conf
supervisorctl reread
supervisorctl update
```

### Port Forwarding (Local to Remote)

```bash
# Forward local port to VPS
ssh -L 8080:localhost:80 root@YOUR_RAILWAY_URL

# Now access localhost:8080 on your machine to reach VPS port 80
```

### Reverse Tunnel (Remote to Local)

```bash
# Forward VPS port to local machine
ssh -R 8080:localhost:3000 root@YOUR_RAILWAY_URL

# VPS port 8080 now forwards to your local port 3000
```

### File Transfer

```bash
# Upload file to VPS
scp file.txt root@YOUR_RAILWAY_URL:/root/

# Download file from VPS
scp root@YOUR_RAILWAY_URL:/root/file.txt ./

# Upload directory
scp -r directory/ root@YOUR_RAILWAY_URL:/root/

# Using rsync (more efficient)
rsync -avz file.txt root@YOUR_RAILWAY_URL:/root/
```

## Resource Monitoring

Monitor your 32GB RAM / 32 vCPU resources:

```bash
# Interactive process viewer
htop

# Memory usage
free -h

# CPU information
lscpu

# Disk usage
df -h

# Network connections
netstat -tuln

# Real-time network usage
nethogs

# I/O statistics
iostat

# System information
neofetch
```

## Persistent Storage

Railway provides persistent storage. Configure it:

1. Go to Railway dashboard
2. Select your service
3. Go to "Volumes" tab
4. Add a volume and mount path (e.g., `/data`)
5. Store important data in mounted directory

Example usage:
```bash
# Store databases in persistent volume
mv /var/lib/postgresql /data/postgresql
ln -s /data/postgresql /var/lib/postgresql
```

## Performance Optimization

### Optimize for 32 vCPU

```bash
# Set make to use all cores
export MAKEFLAGS="-j32"

# Compile with all cores
make -j32

# Configure applications to use multiple threads
export OMP_NUM_THREADS=32
```

### Memory Management

```bash
# Monitor memory usage
watch -n 1 free -h

# Clear cache if needed
sync && echo 3 > /proc/sys/vm/drop_caches
```

## Support

For issues related to:
- **Railway deployment**: Check [Railway documentation](https://docs.railway.app)
- **SSH connection**: Refer to OpenSSH documentation
- **This project**: Open an issue in this repository

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**Note**: This VPS is designed for development and testing purposes. For production use, implement additional security measures such as fail2ban, proper firewall rules, SSH key-only authentication, and regular security updates.