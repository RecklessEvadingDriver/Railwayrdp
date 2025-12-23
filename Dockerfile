FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ROOT_PASSWORD=railway123
ENV SSH_PORT=22

# Update and install required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    wget \
    curl \
    git \
    vim \
    nano \
    net-tools \
    htop \
    tmux \
    screen \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    docker.io \
    supervisor \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config \
    && echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config \
    && echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config

# Configure supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# Expose SSH port
EXPOSE 22

# Start services
CMD ["/startup.sh"]
