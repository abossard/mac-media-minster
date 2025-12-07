# Alternatives & Comparisons

This document provides information about alternative technologies and approaches for running the Mac Media & LLM Stack.

## Container Runtime Alternatives

### Podman Desktop (Docker Alternative)

**Podman Desktop** is a Docker-compatible alternative that doesn't require a daemon.

- **Website:** https://podman-desktop.io/
- **macOS Install:** https://podman-desktop.io/docs/installation/macos-install
- **Pros:**
  - No daemon required (rootless by default)
  - Docker CLI compatible
  - Open source (Apache 2.0)
  - Supports Docker Compose via podman-compose
- **Cons:**
  - Smaller community than Docker
  - Some Docker Compose features may not work identically
  - Less mature on macOS compared to Linux

**To use with this project:**
1. Install Podman Desktop instead of Docker Desktop
2. Use `podman compose` instead of `docker compose`
3. Most scripts should work with minimal changes

### Lima + Docker (Lightweight)

**Lima** launches Linux virtual machines with automatic file sharing.

- **GitHub:** https://github.com/lima-vm/lima
- **Pros:**
  - Lightweight
  - Open source
  - Can run Docker, containerd, or other runtimes
- **Cons:**
  - Requires more manual configuration
  - Less user-friendly than Docker Desktop

## Orchestration Alternatives

### K3s (Lightweight Kubernetes)

**K3s** is a lightweight Kubernetes distribution suitable for homelab use.

- **Website:** https://k3s.io/
- **Documentation:** https://docs.k3s.io/

**Pros:**
- Full Kubernetes API
- Better for multi-node setups
- Service discovery and load balancing
- Great for learning Kubernetes

**Cons:**
- More complex than Docker Compose
- Overkill for single-machine setup
- Steeper learning curve
- More resource overhead

**When to consider K3s:**
- You want to learn Kubernetes
- You plan to expand to multiple machines
- You need advanced orchestration features
- You want Helm chart support

### Minikube (Kubernetes Development)

**Minikube** runs a local Kubernetes cluster for development.

- **Website:** https://minikube.sigs.k8s.io/
- **Documentation:** https://minikube.sigs.k8s.io/docs/

**Pros:**
- Full Kubernetes environment
- Good for development and learning
- Supports multiple drivers (Docker, VirtualBox, etc.)

**Cons:**
- Development-focused, not production
- More overhead than Docker Compose
- Requires more resources

**When to consider Minikube:**
- You're learning Kubernetes
- You need to test Kubernetes manifests
- You want a disposable K8s environment

## Media Server Alternatives

### Jellyfin (Plex Alternative)

**Jellyfin** is a free, open-source media server.

- **Website:** https://jellyfin.org/
- **Pros:**
  - Completely free and open source
  - No account required
  - No premium features locked
- **Cons:**
  - Smaller community than Plex
  - Fewer client apps
  - Less polished interface

**To use in this stack:**
Replace Plex in `docker-compose.yml`:
```yaml
jellyfin:
  image: lscr.io/linuxserver/jellyfin:latest
  container_name: jellyfin
  ports:
    - "8096:8096"
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
    - TZ=${TZ}
  volumes:
    - ${DATA_PATH}/jellyfin-config:/config
    - ${DATA_PATH}/movies:/movies
    - ${DATA_PATH}/tv:/tv
    - ${DATA_PATH}/music:/music
  networks:
    - media-network
```

### Emby (Plex Alternative)

**Emby** is another media server with free and premium tiers.

- **Website:** https://emby.media/
- **Pros:**
  - Good feature set
  - Active development
  - Nice interface
- **Cons:**
  - Premium features require subscription
  - Closed source core

## Download Client Alternatives

### qBittorrent (Transmission Alternative)

**qBittorrent** is a popular open-source BitTorrent client.

- **Docker Image:** https://hub.docker.com/r/linuxserver/qbittorrent

**To use in this stack:**
```yaml
qbittorrent:
  image: lscr.io/linuxserver/qbittorrent:latest
  container_name: qbittorrent
  ports:
    - "8080:8080"  # Web UI
    - "6881:6881"
    - "6881:6881/udp"
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
    - TZ=${TZ}
    - WEBUI_PORT=8080
  volumes:
    - ${DATA_PATH}/qbittorrent-config:/config
    - ${DATA_PATH}/downloads:/downloads
  networks:
    - media-network
```

### Deluge (Transmission Alternative)

**Deluge** is a lightweight BitTorrent client.

- **Docker Image:** https://hub.docker.com/r/linuxserver/deluge

## Music Server Alternatives

### Airsonic-Advanced (Navidrome Alternative)

**Airsonic-Advanced** is a fork of Airsonic with additional features.

- **GitHub:** https://github.com/airsonic-advanced/airsonic-advanced

### Funkwhale (Navidrome Alternative)

**Funkwhale** is a federated music server.

- **Website:** https://funkwhale.audio/

## LLM/AI Alternatives

### Ollama (LM Studio Alternative)

**Ollama** is a command-line tool for running LLMs locally.

- **Website:** https://ollama.ai/
- **Pros:**
  - Simple CLI interface
  - Easy model management
  - Docker support
- **Cons:**
  - No built-in GUI
  - Fewer features than LM Studio

**To use in this stack:**
Add to `docker-compose.yml`:
```yaml
ollama:
  image: ollama/ollama:latest
  container_name: ollama
  ports:
    - "11434:11434"
  volumes:
    - ${DATA_PATH}/ollama:/root/.ollama
  networks:
    - media-network
```

### Text Generation WebUI (LM Studio Alternative)

**Text Generation WebUI** provides a web interface for running LLMs.

- **GitHub:** https://github.com/oobabooga/text-generation-webui

## Recommendation by Use Case

### Simple Home Media Server
**Use this stack as-is** with Docker Compose. It's the simplest and most reliable option.

### Learning Kubernetes
Replace Docker Compose with **K3s** and convert to Kubernetes manifests or Helm charts.

### Maximum Control & Privacy
Replace Plex with **Jellyfin** and Docker Desktop with **Podman Desktop**.

### Development Environment
Use **Minikube** for a disposable Kubernetes environment to test configurations.

### Multi-Machine Setup
Expand to **K3s** cluster across multiple machines for high availability.

### Lightweight Alternative
Use **Podman Desktop** instead of Docker Desktop to reduce resource usage.

## Migration Paths

### From Docker Compose to Kubernetes

1. Use **kompose** to convert docker-compose.yml to Kubernetes manifests:
   ```bash
   brew install kompose
   kompose convert -f docker-compose.yml
   ```

2. Deploy to K3s:
   ```bash
   kubectl apply -f .
   ```

### From Plex to Jellyfin

1. Stop Plex container
2. Copy media library paths (they remain the same)
3. Start Jellyfin and add libraries pointing to same paths
4. Jellyfin will scan and create its own metadata

### From LM Studio to Ollama

1. Note which models you're using in LM Studio
2. Install Ollama: `brew install ollama`
3. Pull models: `ollama pull llama2`
4. Access via API: `http://localhost:11434`

## Community Resources

- **Awesome-Selfhosted:** https://github.com/awesome-selfhosted/awesome-selfhosted
- **LinuxServer.io Forums:** https://discourse.linuxserver.io/
- **r/selfhosted:** https://reddit.com/r/selfhosted
- **r/homelab:** https://reddit.com/r/homelab

## Conclusion

This stack uses Docker Compose because it's:
- **Simple:** Easy to understand and maintain
- **Reliable:** Well-tested and widely used
- **Documented:** Extensive community resources
- **Sufficient:** Handles all requirements for a single-machine setup

Consider alternatives when you need:
- **K3s/Kubernetes:** Multi-machine orchestration
- **Podman:** Docker alternative without daemon
- **Jellyfin:** Free alternative to Plex
- **Ollama:** Command-line LLM runner

For most home media server use cases, the provided Docker Compose stack is the recommended approach.
