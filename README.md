# Mac Media & LLM Stack

Complete automation setup for Mac Mini M4 / macOS 15 Sequoia providing a full media center with Docker Compose and local LLM capabilities.

## 🎯 Overview

This project provides a turnkey automation solution for running a complete media server and AI stack on macOS with:

- **Media Automation:** Sonarr (TV), Radarr (Movies), Transmission (Torrents)
- **Media Servers:** Plex Media Server, Navidrome (Music)
- **Auto-Updates:** Watchtower for automatic container updates
- **Local AI:** LM Studio for local LLM hosting with WebUI and MCP support
- **External Storage:** All data on `/Volumes/space` for easy backup
- **Auto-Start:** Launch agents for system startup

## 📋 Prerequisites

### System Requirements
- **Hardware:** Mac Mini M4 (or any Apple Silicon Mac)
- **OS:** macOS 15 (Sequoia) or later
- **Storage:** External drive mounted at `/Volumes/space` (recommended 500GB+)
- **Memory:** 16GB RAM minimum recommended
- **Network:** Stable internet connection for initial setup

### Required Software
- **Docker Desktop for Mac (Apple Silicon):** [Download here](https://docs.docker.com/desktop/setup/install/mac-install/)
- **Homebrew:** Installed automatically by bootstrap script if missing
- **LM Studio:** [Download from lmstudio.ai](https://lmstudio.ai) (optional, for AI features)

## 🚀 Quick Start

### 1. Prepare External Storage

Ensure your external drive is:
1. Connected to your Mac
2. Mounted at `/Volumes/space`
3. Writable with sufficient free space (500GB+ recommended)

### 2. Clone This Repository

```bash
git clone https://github.com/abossard/mac-media-minster.git
cd mac-media-minster
```

### 3. Verify Prerequisites (Optional but Recommended)

```bash
./scripts/verify_setup.sh
```

This will check:
- macOS version compatibility
- External storage availability
- Required software installation
- Repository file integrity

### 4. Run Bootstrap Script

```bash
./scripts/bootstrap_mac.sh
```

This script will:
- ✅ Verify macOS version compatibility
- ✅ Check external storage availability
- ✅ Install Homebrew (if needed)
- ✅ Install required tools (git, etc.)
- ✅ Check Docker Desktop installation
- ✅ Create directory structure on external drive
- ✅ Generate `.env` file with your system settings
- ✅ Pull and start all Docker containers
- ✅ Configure auto-start launch agents

### 5. Complete Docker Desktop Setup

If Docker Desktop isn't installed yet:
1. Download from: https://docs.docker.com/desktop/setup/install/mac-install/
2. Install and start Docker Desktop
3. Complete the first-run wizard
4. **Note:** Modern versions of Docker Desktop automatically share `/Volumes` directories. If you encounter permission issues:
   - Go to Docker Desktop → Settings → Resources
   - Verify `/Volumes/space` is accessible or add it if needed
5. Re-run `./scripts/bootstrap_mac.sh`

## 📦 What Gets Installed

### Docker Containers

All containers run via Docker Compose with automatic restart policies:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| **Transmission** | 9091 | BitTorrent client with web UI | [LinuxServer Docs](https://docs.linuxserver.io/images/docker-transmission/) |
| **Sonarr** | 8989 | TV show automation | [LinuxServer Docs](https://docs.linuxserver.io/images/docker-sonarr/) |
| **Radarr** | 7878 | Movie automation | [LinuxServer Docs](https://docs.linuxserver.io/images/docker-radarr/) |
| **Plex** | 32400 | Media server | [LinuxServer Docs](https://docs.linuxserver.io/images/docker-plex/) |
| **Navidrome** | 4533 | Modern music server | [Navidrome Docs](https://www.navidrome.org/docs/installation/docker/) |
| **Watchtower** | - | Auto-updates containers | [Watchtower Docs](https://containrrr.dev/watchtower/) |

### Directory Structure

On `/Volumes/space`:

```
/Volumes/space/
├── downloads/              # Transmission download directory
├── movies/                 # Radarr movie library
├── tv/                     # Sonarr TV library
├── music/                  # Navidrome music library
├── backup/                 # Configuration backups
├── transmission-config/    # Transmission configuration
├── sonarr-config/         # Sonarr configuration
├── radarr-config/         # Radarr configuration
├── plex-config/           # Plex configuration
├── navidrome-config/      # Navidrome configuration
└── lmstudio/              # LM Studio models & config (optional)
```

## 🔧 Configuration

### Environment Variables

The `.env` file contains important configuration:

```bash
PUID=501              # Your user ID (auto-detected)
PGID=20               # Your group ID (auto-detected)
TZ=Europe/Zurich      # Your timezone
PLEX_CLAIM=           # Optional Plex claim token
DATA_PATH=/Volumes/space
```

To get a Plex claim token:
1. Visit: https://www.plex.tv/claim
2. Copy the token (valid for 4 minutes)
3. Add to `.env` as `PLEX_CLAIM=claim-xxxxx`
4. Restart Plex: `docker compose restart plex`

### Customizing Docker Compose

Edit `docker-compose.yml` to:
- Change port mappings
- Add additional services
- Modify environment variables
- Adjust restart policies

After changes, apply with:
```bash
./scripts/stop_stack.sh
./scripts/start_stack.sh
```

## 🎬 Using Your Media Stack

### Access Web Interfaces

Once running, access your services at:

- **Transmission:** http://localhost:9091
- **Sonarr:** http://localhost:8989
- **Radarr:** http://localhost:7878
- **Plex:** http://localhost:32400/web
- **Navidrome:** http://localhost:4533

### Initial Configuration

#### 1. Transmission (Download Client)
1. Open http://localhost:9091
2. Go to Settings → Network
3. Note the peer port (default: 51413)
4. Set download directory: `/downloads` (already configured)

#### 2. Sonarr (TV Shows)
1. Open http://localhost:8989
2. Go to Settings → Download Clients → Add → Transmission
   - Host: `transmission`
   - Port: `9091`
   - Category: `tv`
3. Add indexers in Settings → Indexers
4. Add root folder: `/tv`

#### 3. Radarr (Movies)
1. Open http://localhost:7878
2. Go to Settings → Download Clients → Add → Transmission
   - Host: `transmission`
   - Port: `9091`
   - Category: `movies`
3. Add indexers in Settings → Indexers
4. Add root folder: `/movies`

#### 4. Plex Media Server
1. Open http://localhost:32400/web
2. Sign in with your Plex account
3. Add libraries:
   - Movies: `/movies`
   - TV Shows: `/tv`
   - Music: `/music`

#### 5. Navidrome (Music)
1. Open http://localhost:4533
2. Create admin account on first run
3. Music library is automatically scanned from `/music`

## 🤖 LM Studio Setup (Local AI)

### Installation

1. **Download LM Studio:**
   ```bash
   open https://lmstudio.ai
   ```
   Download the macOS version and install to `/Applications`

2. **Manual Installation:**
   - Drag `LM Studio.app` to `/Applications`
   - Launch LM Studio from Applications

3. **Download a Model:**
   - Open LM Studio
   - Go to the Search tab
   - Download a model (e.g., "llama-2-7b-chat")

### Server Mode Configuration

LM Studio provides an OpenAI-compatible API server:

1. **GUI Method:**
   - Open LM Studio
   - Go to the "Local Server" tab
   - Click "Start Server"
   - Server runs at http://localhost:1234 (default)
   - Enable CORS if needed for web applications

2. **Headless/CLI Method:**
   ```bash
   /Applications/LM\ Studio.app/Contents/Resources/lms server start
   ```

3. **Auto-Start (Optional):**
   The bootstrap script configures a LaunchAgent that can automatically start LM Studio server at login. Edit the plist if needed:
   ```bash
   nano ~/Library/LaunchAgents/com.user.lmstudio-server.plist
   ```

### LM Studio Documentation

- **App capabilities:** https://lmstudio.ai/docs/app
- **Developer API:** https://lmstudio.ai/docs/developer
- **CLI commands:** https://lmstudio.ai/docs/cli
- **Headless mode:** https://lmstudio.ai/docs/developer/core/headless
- **Setup guide:** https://gptforwork.com/help/ai-models/endpoints/set-up-lm-studio-on-macos

## 🔄 Management Scripts

### Start/Stop Stack

```bash
# Start all containers
./scripts/start_stack.sh

# Stop all containers
./scripts/stop_stack.sh
```

### Update Containers

```bash
# Pull latest images and restart containers
./scripts/update_stack.sh
```

Note: Watchtower automatically updates containers daily at 4 AM. Manual updates are optional.

### Backup & Restore

```bash
# Backup all configurations
./scripts/backup_configs.sh

# Restore from backup
./scripts/restore_configs.sh /Volumes/space/backup/media-stack-backup_20240101_120000.tar.gz
```

Backups include:
- All service configurations
- LM Studio config (if stored on external drive)
- Stored in `/Volumes/space/backup/`
- Automatic cleanup (keeps last 10 backups)

**Important:** Media files (movies, TV, music) are NOT included in config backups. Use Time Machine or rsync for media backups.

## 🔄 Auto-Start Configuration

The bootstrap script configures LaunchAgents for automatic startup at login:

### Media Stack LaunchAgent
- Location: `~/Library/LaunchAgents/com.user.media-stack.plist`
- Starts: Docker Compose media stack
- Logs: `~/Library/Logs/media-stack.log`

### LM Studio LaunchAgent (Optional)
- Location: `~/Library/LaunchAgents/com.user.lmstudio-server.plist`
- Starts: LM Studio headless server
- Logs: `~/Library/Logs/lmstudio-server.log`

### Managing LaunchAgents

```bash
# Disable auto-start
launchctl unload ~/Library/LaunchAgents/com.user.media-stack.plist

# Enable auto-start
launchctl load ~/Library/LaunchAgents/com.user.media-stack.plist

# Check status
launchctl list | grep media-stack
```

## 🛠 Maintenance

### Container Logs

```bash
# View all logs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# Logs for specific service
docker compose logs sonarr
docker compose logs -f transmission
```

### Container Status

```bash
# Check running containers
docker compose ps

# Check Docker Desktop status
docker info
```

### Watchtower Auto-Updates

Watchtower automatically checks for and applies container updates:
- **Schedule:** Daily at 4:00 AM
- **Behavior:** Pulls new images, recreates containers, cleans up old images
- **Configuration:** Edit `docker-compose.yml` under `watchtower` service

To modify update schedule:
```yaml
watchtower:
  ...
  environment:
    - WATCHTOWER_POLL_INTERVAL=86400  # seconds (86400 = 24 hours)
```

**Watchtower Documentation:** https://containrrr.dev/watchtower/

### Docker Desktop Updates

- Docker Desktop includes an auto-updater
- Check for updates: Docker Desktop → Settings → Software updates
- Release notes: https://docs.docker.com/desktop/release-notes/

## 🐛 Troubleshooting

### Containers Won't Start

```bash
# Check Docker Desktop is running
docker info

# Check container logs
docker compose logs

# Restart containers
./scripts/stop_stack.sh
./scripts/start_stack.sh
```

### Permission Issues

Ensure PUID/PGID in `.env` match your user:
```bash
# Check your IDs
id -u  # Should match PUID
id -g  # Should match PGID

# Update .env if needed
nano .env

# Restart stack
./scripts/stop_stack.sh
./scripts/start_stack.sh
```

### External Drive Not Accessible

```bash
# Check mount point
ls -la /Volumes/space

# Verify in Docker Desktop
# Docker Desktop → Settings → Resources → File Sharing
# Ensure /Volumes/space is listed
```

### Port Conflicts

If ports are already in use, edit `docker-compose.yml`:
```yaml
services:
  sonarr:
    ports:
      - "8989:8989"  # Change left number (host port)
```

### LM Studio Server Issues

```bash
# Check if server is running
curl http://localhost:1234/v1/models

# View logs
cat ~/Library/Logs/lmstudio-server.log

# Restart manually
/Applications/LM\ Studio.app/Contents/Resources/lms server stop
/Applications/LM\ Studio.app/Contents/Resources/lms server start
```

### Reset Everything

To start fresh:
```bash
# Stop and remove containers
docker compose down -v

# Remove all data (WARNING: destructive!)
rm -rf /Volumes/space/{downloads,movies,tv,music}/*
rm -rf /Volumes/space/*-config

# Re-run bootstrap
./scripts/bootstrap_mac.sh
```

## 📚 Additional Resources

### Official Documentation

- **LinuxServer.io:** https://docs.linuxserver.io/
- **Docker Desktop for Mac:** https://docs.docker.com/desktop/setup/install/mac-install/
- **Sonarr:** https://wiki.servarr.com/sonarr
- **Radarr:** https://wiki.servarr.com/radarr
- **Plex:** https://support.plex.tv/
- **Navidrome:** https://www.navidrome.org/docs/
- **Watchtower:** https://containrrr.dev/watchtower/
- **LM Studio:** https://lmstudio.ai/docs/

### Alternative Tools (For Reference)

- **Podman Desktop:** https://podman-desktop.io/ (Docker alternative)
- **K3s:** https://k3s.io/ (Lightweight Kubernetes)
- **Minikube:** https://minikube.sigs.k8s.io/ (Local Kubernetes)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This project is provided as-is for personal use. Please respect the licenses of all included software and Docker images.

## ⚠️ Legal Notice

This software is for personal media management only. Ensure you comply with all applicable laws and regulations regarding media downloads and copyright in your jurisdiction. The authors assume no responsibility for misuse.