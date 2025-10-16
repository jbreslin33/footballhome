# SSL/HTTPS Setup Guide for Football Home

This guide explains how to set up SSL certificates with Let's Encrypt Certbot for your Football Home application.

## Prerequisites

1. **Domain Setup**: Your domain must point to your server's public IP
2. **Ports Open**: Ensure ports 80 and 443 are accessible from the internet
3. **Root Access**: SSL setup requires root privileges

## Quick Setup (Automated)

### 1. Run the SSL Setup Script

```bash
# Basic setup with default domain (footballhome.org)
sudo ./scripts/setup-ssl.sh

# Custom domain and email
sudo ./scripts/setup-ssl.sh yourdomain.com admin@yourdomain.com
```

### 2. Switch to HTTPS Configuration

```bash
# Switch to HTTPS mode
./scripts/ssl-config.sh https

# Rebuild and restart containers
podman-compose up -d --build
# OR
docker-compose up -d --build
```

### 3. Test Your SSL Setup

```bash
# Test HTTPS access
curl -I https://yourdomain.com

# Check SSL certificate details
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com
```

## Manual Setup Steps

If you prefer to understand each step:

### 1. Install Certbot

```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
```

### 2. Stop Running Containers

```bash
cd /home/jbreslin/sandbox/footballhome
podman-compose down  # or docker-compose down
```

### 3. Get SSL Certificate

```bash
# Replace with your domain and email
sudo certbot certonly \
    --standalone \
    --email admin@yourdomain.com \
    --agree-tos \
    --no-eff-email \
    --domains yourdomain.com,www.yourdomain.com
```

### 4. Copy Certificates to Project

```bash
# Create SSL directory
mkdir -p ssl

# Copy certificates (replace 'yourdomain.com' with your domain)
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/yourdomain.com.crt
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/yourdomain.com.key

# Fix permissions
sudo chown -R $USER:$USER ssl/
chmod 644 ssl/yourdomain.com.crt
chmod 600 ssl/yourdomain.com.key
```

### 5. Update Nginx Configuration

```bash
# Switch to HTTPS configuration
./scripts/ssl-config.sh https

# Or manually edit frontend/Dockerfile to use nginx.conf instead of nginx-simple.conf
```

### 6. Restart Application

```bash
podman-compose up -d --build
```

## Configuration Management

### Check Current SSL Status

```bash
./scripts/ssl-config.sh status
```

### Switch Between HTTP and HTTPS

```bash
# Switch to HTTP-only (development)
./scripts/ssl-config.sh http
podman-compose up -d --build

# Switch to HTTPS (production)
./scripts/ssl-config.sh https
podman-compose up -d --build
```

## Certificate Renewal

### Automatic Renewal (Recommended)

The setup script automatically configures renewal:

- **Frequency**: Every Sunday at 2:00 AM
- **Script**: `./scripts/renew-ssl.sh`
- **Logs**: `/var/log/ssl-renewal.log`

### Manual Renewal

```bash
# Renew certificates manually
sudo certbot renew

# Copy renewed certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/yourdomain.com.crt
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/yourdomain.com.key

# Restart web container
podman-compose restart web
```

### Check Renewal Status

```bash
# Check when certificates expire
sudo certbot certificates

# Test renewal process (dry run)
sudo certbot renew --dry-run

# View renewal logs
tail -f /var/log/ssl-renewal.log
```

## Troubleshooting

### Common Issues

#### Certificate Request Fails

**Problem**: `Failed to obtain SSL certificate`

**Solutions**:
1. Verify DNS: `nslookup yourdomain.com`
2. Check port 80 access: `curl -I http://yourdomain.com`
3. Ensure no other web server is running: `sudo netstat -tulpn | grep :80`
4. Check firewall: `sudo ufw status` or `sudo iptables -L`

#### Container Won't Start with SSL

**Problem**: Web container fails to start after enabling HTTPS

**Solutions**:
1. Check certificate files exist:
   ```bash
   ls -la ssl/
   ```
2. Verify certificate permissions:
   ```bash
   ls -la ssl/yourdomain.com.*
   ```
3. Check nginx config syntax:
   ```bash
   podman run --rm -v $(pwd)/frontend/nginx.conf:/etc/nginx/nginx.conf nginx:alpine nginx -t
   ```

#### HTTPS Not Working

**Problem**: Site loads on HTTP but not HTTPS

**Solutions**:
1. Check if port 443 is open:
   ```bash
   sudo netstat -tulpn | grep :443
   ```
2. Test certificate:
   ```bash
   openssl x509 -in ssl/yourdomain.com.crt -text -noout
   ```
3. Check container logs:
   ```bash
   podman-compose logs web
   ```

### Reset SSL Setup

If you need to start over:

```bash
# Remove certificates
sudo rm -rf /etc/letsencrypt/live/yourdomain.com/
sudo rm -rf /etc/letsencrypt/archive/yourdomain.com/
sudo rm -rf ssl/

# Switch back to HTTP
./scripts/ssl-config.sh http
podman-compose up -d --build

# Try setup again
sudo ./scripts/setup-ssl.sh yourdomain.com
```

## Security Best Practices

### Certificate Security
- Keep private keys secure (600 permissions)
- Never commit certificates to version control
- Use strong passwords for certificate storage
- Monitor certificate expiration dates

### Nginx Security
The production nginx.conf includes:
- Modern TLS configuration (TLS 1.2 and 1.3)
- Security headers (HSTS, X-Frame-Options, etc.)
- Rate limiting for API endpoints
- Proper SSL cipher selection

### Monitoring
- Set up monitoring for certificate expiration
- Monitor SSL Labs rating: https://www.ssllabs.com/ssltest/
- Check logs regularly: `tail -f /var/log/ssl-renewal.log`

## Files and Directories

```
footballhome/
├── ssl/                          # SSL certificates (created by setup)
│   ├── yourdomain.com.crt       # Public certificate
│   └── yourdomain.com.key       # Private key
├── scripts/
│   ├── setup-ssl.sh             # Main SSL setup script
│   ├── ssl-config.sh            # Configuration switcher
│   └── renew-ssl.sh             # Renewal script (auto-created)
└── frontend/
    ├── nginx.conf               # HTTPS configuration
    ├── nginx-simple.conf        # HTTP-only configuration
    └── NGINX_README.md          # Nginx documentation
```

## Next Steps

After SSL is working:
1. Update any hardcoded HTTP URLs in your application
2. Set up SSL monitoring and alerting
3. Consider implementing HPKP (HTTP Public Key Pinning) for additional security
4. Enable HTTP/2 for better performance (already configured in nginx.conf)