# CHANGELOG

All notable changes to the Mac Media & LLM Stack automation project.

## [1.0.0] - 2024-12-07

### Added
- Initial release of Mac Media & LLM Stack automation
- Complete Docker Compose stack with:
  - Transmission (BitTorrent client)
  - Sonarr (TV automation)
  - Radarr (Movie automation)
  - Plex Media Server
  - Navidrome (Music server)
  - Watchtower (Auto-updates)
- Automation scripts:
  - `bootstrap_mac.sh` - Full automated installation
  - `start_stack.sh` / `stop_stack.sh` - Service management
  - `update_stack.sh` - Manual container updates
  - `backup_configs.sh` / `restore_configs.sh` - Config backup/restore
  - `lmstudio_server_login.sh` - LM Studio server automation
  - `verify_setup.sh` - Pre-installation verification
- macOS LaunchAgent configurations for auto-start
- Comprehensive documentation in README.md
- Configuration templates (.env.template)

### Features
- External storage support at `/Volumes/space`
- Auto-detection of PUID/PGID for proper permissions
- All data persisted to external drive
- Automatic container updates via Watchtower
- Optional LM Studio integration for local LLM hosting
- Complete backup and restore functionality
- Detailed troubleshooting guide

### Documentation
- Complete setup guide
- Service configuration instructions
- LM Studio setup and headless mode documentation
- Maintenance and update procedures
- Troubleshooting section with common issues
- Links to all official documentation

### Security
- No secrets in repository (use .env file)
- Proper file permissions on scripts
- Network isolation for containers (except Plex for discovery)
- User/group ID mapping to host user

### Compatibility
- macOS 15 (Sequoia) or later
- Apple Silicon (M1/M2/M4) recommended
- Works with Intel Macs with Docker Desktop
- Docker Desktop for Mac
- Homebrew package manager
