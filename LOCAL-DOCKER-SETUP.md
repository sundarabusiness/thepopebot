# Local Docker Setup for GOAT Autopilot (Testing Before VPS)

**Goal:** Run GOAT Autopilot locally in Docker + test everything before deploying to VPS

**Options:**
1. **Docker Desktop** (EASIEST) — Docker + optional Kubernetes
2. **Minikube** (MORE CONTROL) — Lightweight Kubernetes cluster

---

## Option 1: Docker Desktop (Recommended for Bobby)

### Step 1: Install Docker Desktop

**Windows:**
1. Download: https://www.docker.com/products/docker-desktop
2. Run installer
3. Accept defaults
4. Restart computer
5. Docker Desktop starts automatically

**Verify:**
```powershell
docker --version
docker run hello-world
# Should print: "Hello from Docker!"
```

### Step 2: Clone Private Repo

```powershell
git clone https://github.com/sundarabusiness/goat-autopilot.git
cd goat-autopilot
```

### Step 3: Create Local .env

```powershell
cp .env.example .env
notepad .env
# Fill in: GH_TOKEN, ANTHROPIC_API_KEY
```

### Step 4: Run Locally with Docker Compose

```powershell
# Start services
docker-compose -f docker-compose.goat.yml up

# Expected output:
# ✓ goat-autopilot (port 8877)
# ✓ mission-control (port 8888)
# [+] Running 2/2
```

### Step 5: Test Locally

**In new PowerShell:**
```powershell
# Test API
curl http://localhost:8877/api/ping
# Should return: {"status":"ok"}

# Test dashboard
start http://localhost:8888
# Should show: Mission Control dashboard
```

### Step 6: Stop Services

```powershell
# Press Ctrl+C in Docker Compose terminal
# Or in new PowerShell:
docker-compose -f docker-compose.goat.yml down
```

---

## Option 2: Minikube (For Kubernetes Testing)

### Step 1: Install Minikube

**Windows (Admin PowerShell):**
```powershell
choco install minikube
# Or download: https://minikube.sigs.k8s.io/docs/start/
```

### Step 2: Start Minikube Cluster

```powershell
minikube start --driver=docker
minikube status
# Should show: running
```

### Step 3: Deploy GOAT Autopilot

```powershell
# Point Docker to Minikube's Docker daemon
& minikube -p minikube docker-env | Invoke-Expression

# Clone and run
git clone https://github.com/sundarabusiness/goat-autopilot.git
cd goat-autopilot

# Use docker-compose inside minikube
docker-compose -f docker-compose.goat.yml up
```

### Step 4: Test

```powershell
# Get Minikube IP
$ip = minikube ip
echo "Access at: http://$ip:8877"

# Test
curl "http://$ip:8877/api/ping"
start "http://$ip:8888"  # Mission Control
```

### Step 5: Cleanup

```powershell
minikube stop
# Or delete completely:
minikube delete
```

---

## Fastest Path: Docker Desktop Only

```powershell
# 1. Install Docker Desktop (one-time)
#    https://www.docker.com/products/docker-desktop

# 2. Clone repo
git clone https://github.com/sundarabusiness/goat-autopilot.git
cd goat-autopilot

# 3. Create .env
cp .env.example .env
# Fill in GH_TOKEN, ANTHROPIC_API_KEY

# 4. Start
docker-compose -f docker-compose.goat.yml up

# 5. Test (new terminal)
curl http://localhost:8877/api/ping
start http://localhost:8888

# 6. Stop
docker-compose -f docker-compose.goat.yml down
```

---

## What Gets Tested Locally

✅ **Docker images build correctly**
✅ **Services start and connect**
✅ **API endpoints respond** (/api/ping, /api/locks, etc.)
✅ **Configuration loads** (.env, CRONS.json, TRIGGERS.json)
✅ **Mission Control dashboard** loads and updates
✅ **Networking between containers** works
✅ **Error handling** is correct

❌ **Not fully tested locally** (needs VPS):
- GitHub Actions workflows
- Agent Oracle full validation
- Systemd service (VPS-specific)
- External webhooks (needs public IP)

---

## Troubleshooting Local Docker

### "Docker daemon not running"
```powershell
# Start Docker Desktop
# Click Docker icon in system tray → Open
# Or restart: Settings > Resources > Restart Docker Engine
```

### "Port 8877 already in use"
```powershell
# Find process
netstat -ano | findstr :8877

# Kill it
taskkill /PID <process_id> /F

# Or change port in docker-compose.goat.yml:
# ports: "9877:3000"  (local:container)
```

### "Cannot connect to Docker daemon"
```powershell
# Restart Docker Desktop completely
# Task Manager → Find "Docker Desktop"
# Kill process
# Restart Docker Desktop app
```

### "Container exits immediately"
```powershell
# Check logs
docker-compose -f docker-compose.goat.yml logs goat-autopilot

# Common causes:
# - Missing .env file
# - GH_TOKEN or ANTHROPIC_API_KEY not set
# - Port already in use
# - File permissions

# Fix and try again
docker-compose -f docker-compose.goat.yml up
```

### "Cannot find docker-compose.goat.yml"
```powershell
# Make sure you're in the right directory
ls docker-compose.goat.yml
# Should exist in repo root

# If not, wrong location
cd /path/to/goat-autopilot
```

---

## Bobby's Checklist

- [ ] Docker Desktop installed + running
- [ ] `docker --version` shows version
- [ ] `docker run hello-world` succeeds
- [ ] Private repo cloned: `git clone https://github.com/sundarabusiness/goat-autopilot.git`
- [ ] `.env` created with GH_TOKEN + ANTHROPIC_API_KEY
- [ ] `docker-compose -f docker-compose.goat.yml up` starts without errors
- [ ] `curl http://localhost:8877/api/ping` returns `{"status":"ok"}`
- [ ] http://localhost:8888 loads in browser (Mission Control)
- [ ] Logs show no errors (docker-compose logs)
- [ ] `docker-compose down` stops cleanly
- [ ] Ready to deploy to VPS!

---

## Next: Deploy to VPS

Once local testing passes:

```powershell
# Push changes
git push origin main

# SSH to VPS
ssh root@100.111.3.59

# Clone fresh on VPS
cd /opt/goat
git clone https://github.com/sundarabusiness/goat-autopilot.git goat-autopilot-src
cd goat-autopilot-src

# Start on VPS
docker-compose -f docker-compose.goat.yml up -d
systemctl restart goat-autopilot

# Verify
curl http://localhost:8877/api/ping
```

---

**Local testing → VPS deployment → Production! 🚀**
