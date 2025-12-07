# Quick Reference

Quick command reference for Mac Media & LLM Stack.

## Installation

```bash
# Clone repository
git clone https://github.com/abossard/mac-media-minster.git
cd mac-media-minster

# Verify setup (optional)
./scripts/verify_setup.sh

# Run bootstrap
./scripts/bootstrap_mac.sh
```

## Daily Operations

### Start/Stop Services

```bash
# Start all services
./scripts/start_stack.sh

# Stop all services
./scripts/stop_stack.sh

# Restart a specific service
docker compose restart sonarr
```

### Check Status

```bash
# Check running containers
docker compose ps

# View logs
docker compose logs          # All services
docker compose logs -f       # Follow logs
docker compose logs sonarr   # Specific service
```

### Update Containers

```bash
# Manual update
./scripts/update_stack.sh

# Note: Watchtower automatically updates daily at 4 AM
```

## Configuration

### Edit Environment Variables

```bash
nano .env
# After changes:
./scripts/stop_stack.sh
./scripts/start_stack.sh
```

### Service Configuration Files

Located on external drive at `/Volumes/space/*-config/`

## Backup & Restore

```bash
# Create backup
./scripts/backup_configs.sh

# Restore from backup
./scripts/restore_configs.sh /Volumes/space/backup/media-stack-backup_TIMESTAMP.tar.gz
```

## Web Interfaces

| Service | URL | Purpose |
|---------|-----|---------|
| Transmission | http://localhost:9091 | Download client |
| Sonarr | http://localhost:8989 | TV show management |
| Radarr | http://localhost:7878 | Movie management |
| Plex | http://localhost:32400/web | Media server |
| Navidrome | http://localhost:4533 | Music server |

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose logs [service-name]

# Restart service
docker compose restart [service-name]

# Full restart
./scripts/stop_stack.sh
./scripts/start_stack.sh
```

### Permission Issues

```bash
# Check your IDs
id -u  # Should match PUID in .env
id -g  # Should match PGID in .env

# Update .env if needed
nano .env
```

### Docker Desktop Issues

```bash
# Check Docker is running
docker info

# Restart Docker Desktop from menu bar
```

## Advanced

### Run Single Container

```bash
docker compose up -d sonarr
```

### View Container Details

```bash
docker inspect [container-name]
```

### Access Container Shell

```bash
docker compose exec sonarr /bin/bash
```

### Clean Up

```bash
# Remove stopped containers
docker compose down

# Remove with volumes (WARNING: deletes data)
docker compose down -v

# Clean unused images
docker image prune -f
```

## LaunchAgents

### Disable Auto-Start

```bash
launchctl unload ~/Library/LaunchAgents/com.user.media-stack.plist
```

### Enable Auto-Start

```bash
launchctl load ~/Library/LaunchAgents/com.user.media-stack.plist
```

### View LaunchAgent Logs

```bash
tail -f ~/Library/Logs/media-stack.log
tail -f ~/Library/Logs/lmstudio-server.log
```

## LM Studio

### Start Server Manually

```bash
/Applications/LM\ Studio.app/Contents/Resources/lms server start
```

### Check Server Status

```bash
curl http://localhost:1234/v1/models
```

## File Locations

- **Repository:** `~/mac-media-minster/` (or wherever you cloned)
- **Data:** `/Volumes/space/`
- **Configs:** `/Volumes/space/*-config/`
- **Backups:** `/Volumes/space/backup/`
- **Logs:** `~/Library/Logs/`
- **LaunchAgents:** `~/Library/LaunchAgents/`

## Support

For detailed documentation, see [README.md](README.md)

For issues, visit: https://github.com/abossard/mac-media-minster/issues
