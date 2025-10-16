# Nginx Configuration Files

This directory contains two nginx configuration files for different deployment scenarios:

## Files

### `nginx-simple.conf` (ACTIVE)
- **Purpose**: HTTP-only configuration for local development and initial deployment
- **Features**: 
  - Basic reverse proxy to Express.js API
  - Gzip compression
  - Static file caching
  - No SSL/HTTPS
- **Used by**: `Dockerfile` (currently active)
- **Port**: 80 only

### `nginx.conf` (PRODUCTION READY)
- **Purpose**: Full production configuration with HTTPS support
- **Features**:
  - HTTP to HTTPS redirects
  - SSL/TLS configuration
  - Security headers
  - Rate limiting
  - ACME challenge support for Let's Encrypt
- **Used by**: Manual deployment with SSL certificates
- **Ports**: 80 (redirect) and 443 (HTTPS)

## Usage

### Development/Testing (Current)
The `nginx-simple.conf` is automatically used via the Dockerfile for simple HTTP deployment.

### Production with SSL
To switch to the full SSL configuration:

1. **Setup SSL certificates** (run as root):
   ```bash
   sudo ./scripts/setup-ssl.sh
   ```

2. **Update Dockerfile** to use full config:
   ```dockerfile
   COPY nginx.conf /etc/nginx/nginx.conf
   ```

3. **Rebuild and deploy**:
   ```bash
   podman-compose up -d --build
   ```

## Configuration Details

Both configurations:
- Proxy `/api/*` requests to the Express.js backend (`api:3000`)
- Serve static files with appropriate caching
- Support the PWA service worker and manifest
- Handle SPA routing (fallback to `index.html`)

The production config adds:
- Automatic HTTPS redirects
- Modern TLS configuration
- Security headers (HSTS, X-Frame-Options, etc.)
- Rate limiting for API endpoints
- Let's Encrypt certificate support