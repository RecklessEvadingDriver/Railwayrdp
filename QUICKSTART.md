# Quick Start Guide - Railway VPS

This is a **5-minute setup guide** to get your VPS running on Railway.app.

## 🚀 Deploy in 3 Steps

### Step 1: Deploy to Railway (2 minutes)

1. **Fork this repository** to your GitHub account
2. Go to [Railway.app](https://railway.app) and sign up/login
3. Click **"New Project"** → **"Deploy from GitHub repo"**
4. Select your forked **Railwayrdp** repository
5. Wait for deployment to complete ✅

### Step 2: Enable SSH Access (1 minute)

1. In Railway dashboard, click your service
2. Go to **"Settings"** tab
3. Scroll to **"Networking"** section
4. **Enable "TCP Proxy"** (Critical!)
5. Note your domain and port (e.g., `myapp.railway.app:12345`)

### Step 3: Connect from Termux (2 minutes)

```bash
# In Termux
pkg install openssh -y
ssh root@YOUR_RAILWAY_URL
# Password: railway123
```

**That's it!** You now have a full VPS with:
- ✅ Root access
- ✅ 32GB RAM / 32 vCPU
- ✅ Docker pre-installed
- ✅ Python, Node.js, Git, and build tools

## 📱 Termux Commands

```bash
# Update Termux
pkg update && pkg upgrade -y

# Install SSH client
pkg install openssh -y

# Connect to VPS
ssh root@your-app.railway.app

# Or with custom port
ssh -p PORT root@your-app.railway.app
```

## 🔐 Change Password (Recommended)

**Option 1: In Railway Dashboard**
1. Go to your service → "Variables" tab
2. Add: `ROOT_PASSWORD=your_secure_password`
3. Redeploy

**Option 2: After SSH login**
```bash
passwd root
# Enter new password twice
```

## ⚙️ First Commands After Login

```bash
# Check resources
free -h      # Check RAM (should show ~32GB)
nproc        # Check CPUs (should show 32)

# Update system
apt-get update && apt-get upgrade -y

# Install additional tools
apt-get install -y htop neofetch

# Check system info
neofetch

# Start Docker
dockerd &
docker ps
```

## 🔧 Common Use Cases

### Run a Web Server
```bash
apt-get install -y nginx
service nginx start
```

### Deploy Node.js App
```bash
git clone YOUR_REPO
cd YOUR_REPO
npm install
npm start
```

### Run Docker Containers
```bash
dockerd &
docker run -d -p 80:80 nginx
docker run -d -p 3306:3306 mysql
```

### Host Database
```bash
apt-get install -y postgresql
service postgresql start
```

## 🆘 Troubleshooting

**Can't connect?**
- ✅ Check TCP Proxy is enabled in Railway
- ✅ Use correct domain:port from Railway
- ✅ Try: `ssh -v root@your-app.railway.app` for debug info

**Wrong password?**
- Default is `railway123`
- Check Railway environment variables
- Look at Railway logs for password confirmation

**Connection drops?**
```bash
ssh -o ServerAliveInterval=60 root@your-app.railway.app
```

## 📚 More Information

- **Full Documentation**: See [README.md](README.md)
- **Deployment Guide**: See [DEPLOYMENT.md](DEPLOYMENT.md)
- **Railway Docs**: [docs.railway.app](https://docs.railway.app)

## 🎯 Next Steps

1. ✅ Change default password
2. ✅ Set up SSH keys (more secure)
3. ✅ Install your required software
4. ✅ Deploy your applications
5. ✅ Set up monitoring

---

**Need help?** Open an issue on GitHub or check Railway's Discord community.

**Security Note**: Change the default password immediately and consider using SSH keys instead of passwords for production use.
