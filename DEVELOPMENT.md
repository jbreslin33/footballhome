# Football Home - Development Workflow

This guide explains how to set up and develop on Football Home locally.

## 🚀 First-Time Setup (One-Time Only)

### Option 1: Automated (Recommended)
```bash
./setup.sh
```

This script checks and installs:
- ✓ Docker & Docker Compose
- ✓ Node.js (for data scraping)
- ✓ Node.js dependencies

### Option 2: Manual Setup
See [SETUP.md](SETUP.md) for step-by-step manual installation.

## 🛠️ Daily Development Workflow

After initial setup, use `dev.sh` for all development tasks:

### Full Rebuild (Fresh Database)
```bash
./dev.sh
```
- Rebuilds Docker containers
- Reinitializes PostgreSQL database
- Loads default data
- **Duration**: 5-15 minutes (first time), ~3-5 minutes after

### Quick Restart (Keep Database)
```bash
./dev.sh --quick
```
- Restarts services
- **Keeps existing database state**
- Great for code changes, config updates
- **Duration**: ~30 seconds

### Fast Rebuild from Saved State
```bash
./dev.sh --replay-only
```
- Rebuilds from last saved database state
- No data scraping
- **Duration**: ~10 seconds
- *Requires running `./dev.sh --save` first*

### With Data Scraping
```bash
# Full APSL league data
./dev.sh --apsl

# CASA league data
./dev.sh --casa

# Both APSL and CASA
./dev.sh --apsl --casa

# Save state for later quick rebuilds
./dev.sh --apsl --casa --save
```

## 📋 Script Comparison

| Command | Docker | Database | Data Scraping | Duration |
|---------|--------|----------|---------------|----------|
| `./setup.sh` | Check/Install | — | — | 1-2 min |
| `./dev.sh` | Rebuild | Recreate | None | 3-15 min |
| `./dev.sh --quick` | Restart | Keep | None | 30 sec |
| `./dev.sh --replay-only` | Rebuild | Restore | None | 10 sec |
| `./dev.sh --apsl` | Rebuild | Recreate | APSL | 10-20 min |

## 🌐 Access the App

Once running, open in your browser:

**URL**: http://localhost:3000

**Demo Login**:
- Email: `jbreslin@footballhome.org`
- Password: `1893Soccer!`

## 📊 Services Running

- **Frontend** (http://localhost:3000): Vanilla JavaScript SPA
- **Backend API** (http://localhost:3001): C++ HTTP server
- **Database** (localhost:5432): PostgreSQL
- **pgAdmin** (http://localhost:5050): Database admin UI (optional)

## 🔍 Troubleshooting

### Docker Not Running
```bash
# Linux
sudo systemctl start docker

# macOS
# Open Docker Desktop from Applications
```

### Container Issues
```bash
# View live logs
docker-compose logs -f

# Restart everything
docker-compose restart

# Full cleanup (removes all data)
docker-compose down
```

### Port Already in Use
If port 3000, 3001, or 5432 is already in use, modify `docker-compose.yml` to use different ports.

## 📚 More Information

- Full command reference: `./dev.sh --help`
- Architecture details: See `backend/README.md`, `frontend/README.md`
- Database schema: See `database/README.md`
- Copilot instructions: See [.github/copilot-instructions.md](.github/copilot-instructions.md)

## 💡 Industry Best Practices

This workflow follows common development patterns:

1. **`setup.sh`** - One-time environment setup (installs dependencies)
2. **`dev.sh`** - Repeatable build/run script (manages application lifecycle)
3. **Docker** - Isolated, reproducible development environment
4. **Fast rebuilds** - `--quick` and `--replay-only` modes for rapid iteration

This separation allows:
- **New developers** to run `setup.sh` once, then `dev.sh`
- **Experienced developers** to use `--quick` or `--replay-only` for faster cycles
- **CI/CD pipelines** to use standardized build commands
- **Easy collaboration** - same build process everywhere
