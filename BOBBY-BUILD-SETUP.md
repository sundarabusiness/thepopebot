# Bobby's GOAT Autopilot Build — Step-by-Step Setup

**For:** Bobby (retrobob) on Windows PC
**Goal:** Build GOAT Autopilot from GitHub fork, deploy to VPS, launch first job
**Total Time:** ~30 minutes

---

## Phase 1: Prerequisites (5 min)

### Step 1: Verify Prerequisites

**Open PowerShell (Admin)** and run:

```powershell
# Check Node.js
node --version
npm --version

# Check Git
git --version

# Check Tailscale
ping 100.111.3.59
```

**Expected Output:**
```
v22.x.x (Node.js)
9.x.x (npm)
git version 2.x.x
Reply from 100.111.3.59: bytes=32 time=XX ms
```

**If any are missing:**
- Node.js: Download from https://nodejs.org/ (LTS recommended)
- Git: Download from https://git-scm.com/download/win
- Tailscale: Download from https://tailscale.com/download/windows

---

## Phase 2: Clone GOAT Autopilot Fork (3 min)

### Step 2: Clone Repository

**In PowerShell:**

```powershell
# Create projects folder
mkdir C:\projects
cd C:\projects

# Clone the fork
git clone https://github.com/sundarabusiness/thepopebot.git goat-autopilot
cd goat-autopilot

# Verify you're on main branch
git status
```

**Expected Output:**
```
On branch main
nothing to commit, working tree clean
```

### Step 3: Verify Fork Contents

```powershell
# List important files
ls

# Should see:
# - Dockerfile.goat
# - docker-compose.goat.yml
# - .env.example
# - GOAT-QUICKSTART.md
# - config/GOAT-Oracle-SOUL.md
# - setup-claude-*.bat files
```

---

## Phase 3: Install Dependencies (5 min)

### Step 4: Install Node Packages

```powershell
# Install npm dependencies
npm install

# Expected output: "added X packages"

# Verify packages installed
npm list | head -20
```

**This installs:**
- LangGraph (agent framework)
- Next.js (event handler UI)
- Drizzle ORM (database)
- Anthropic SDK
- Grammar.js (Telegram bot)

---

## Phase 4: Setup .env Configuration (5 min)

### Step 5: Create .env File

```powershell
# Copy template
cp .env.example .env

# Open for editing
notepad .env
```

**In Notepad, fill in ONLY these 2 fields:**

```
GH_TOKEN=<YOUR_GITHUB_PAT>
ANTHROPIC_API_KEY=<YOUR_ANTHROPIC_KEY>
```

**How to get GH_TOKEN:**
1. Go to https://github.com/settings/tokens/new
2. Name: "GOAT-Autopilot"
3. Scopes: ✓ repo ✓ workflow ✓ write:org
4. Generate token
5. Copy and paste into .env

**How to get ANTHROPIC_API_KEY:**
1. Go to https://console.anthropic.com/keys
2. Create new API key
3. Copy and paste into .env

**Save File** (Ctrl+S, then close Notepad)

### Step 6: Verify .env

```powershell
# Check the file was created
type .env | findstr /v "^#" | findstr /v "^$"

# Should show your values (GH_TOKEN and ANTHROPIC_API_KEY filled in)
```

---

## Phase 5: Test VPS Connection (3 min)

### Step 7: SSH to VPS

```powershell
# Connect to VPS
ssh root@100.111.3.59

# Enter password when prompted (check session memory for VPS password)
```

**Expected:**
```
root@jeanclawdevps:~#
```

### Step 8: Verify VPS Deployment

```bash
# On VPS, check service status
systemctl status goat-autopilot

# Should show: active (running)

# Check logs (first 20 lines)
journalctl -u goat-autopilot -n 20

# Test API
curl http://localhost:8877/api/ping
# Should respond: {"status":"ok"}
```

### Step 9: View State Files

```bash
# Check initialization
ls -la /opt/goat/state/

# Should see:
# - scrape-log.jsonl (initialized)
# - activity.jsonl (empty, will populate)

# Check environment
cat /opt/goat/.env | grep -v "^#" | grep -v "^$"
```

### Step 10: Exit VPS

```bash
exit
```

**Back in PowerShell on your PC**

---

## Phase 6: Configure GOAT Automation (5 min)

### Step 11: Define Cron Jobs

**In PowerShell:**

```powershell
# Edit cron configuration
notepad config/CRONS.json
```

**Replace entire file with:**

```json
[
  {
    "name": "scrape-toyota-bountiful",
    "schedule": "0 */4 * * *",
    "enabled": true,
    "type": "agent",
    "job": "Scrape Toyota Bountiful inventory using Algolia API. Output: state/inventory.csv with columns Stock,Year,Make,Model,Trim,Price,Mileage,VIN,Drivetrain,Color,Notes,Photos. Check vehicle_count, price ranges ($6k-$30k), photo accessibility. Log results."
  },
  {
    "name": "scrape-mazda-bountiful",
    "schedule": "0 */6 * * *",
    "enabled": true,
    "type": "agent",
    "job": "Scrape Bountiful Mazda inventory from HTML page. Output: state/inventory.csv with same schema as Toyota. Verify CTA JSON sections, VIN extracts, photo URLs. Log results."
  }
]
```

**Save File**

### Step 12: Define Webhook Triggers

```powershell
# Edit trigger configuration
notepad config/TRIGGERS.json
```

**Replace entire file with:**

```json
[
  {
    "watch_path": "/api/build-lists",
    "fire": [
      {
        "name": "build-lists-manual",
        "type": "agent",
        "job": "Build vehicle lists for Thomas (P1), Bryan (P2), Trevor (P2) from state/inventory.csv. Score all types on FB marketplace velocity. Output: lists/{thomas,bryan,trevor}.json + bench_*.json. Verify no overlaps."
      }
    ]
  },
  {
    "watch_path": "/api/posting-page",
    "fire": [
      {
        "name": "generate-posting-page",
        "type": "agent",
        "job": "Generate HTML posting page from active lists. Include: PIN gate, photo gallery, blur tool, flag buttons, copy button, SOLD tracking. Output: posting_page_{timestamp}.html"
      }
    ]
  }
]
```

**Save File**

### Step 13: Commit Configuration

```powershell
# Stage changes
git add .env config/CRONS.json config/TRIGGERS.json

# Commit
git commit -m "config: Bobby initial setup - CRONS + TRIGGERS

- Toyota scrape every 4 hours
- Mazda scrape every 6 hours
- Manual triggers for list building and posting page generation
- Ready for first autonomous jobs"

# Push to GitHub
git push origin main
```

**Expected:**
```
[main abc1234] config: Bobby initial setup...
 3 files changed, 15 insertions(+)
```

---

## Phase 7: Claude Code Setup (5 min)

### Step 14: Download Claude Setup Script

```powershell
# Already in goat-autopilot folder
# Run the interactive setup script
.\setup-claude-choose.bat
```

**Menu appears:**
```
[1] Option 1: VPS Ollama (EASIEST, Recommended)
[2] Option 2: Local Ollama (Good)
[3] Option 3: Local LiteLLM (FAST, Full Setup)
```

**Bobby's Recommendation:** Option 1 (fastest to start) or Option 3 (for RTX 5080 power)

**Pick: 1**

**Result:** Claude Code launches and connects to VPS Ollama

---

## Phase 8: First Test Job (2 min)

### Step 15: Kick Off First Scrape

**In Claude Code:**

```
Help me trigger the first scrape job. I want to test:
1. GitHub job branch creation
2. Agent Oracle validation
3. PR merge workflow
4. How do I POST to /api/create-job with curl?
```

**Claude will help you construct:**

```powershell
# Back in PowerShell
$apiKey = "your-api-key-from-.env"

curl -X POST http://100.111.3.59:8877/api/create-job `
  -H "x-api-key: $apiKey" `
  -H "Content-Type: application/json" `
  -d '{
    "type": "agent",
    "job": "Test scrape: Verify Toyota Bountiful Algolia API connection. Report vehicle_count, price_range, photo_availability."
  }'
```

**Expected Response:**
```json
{
  "job_id": "abc-def-123-xyz",
  "status": "queued",
  "branch": "job/abc-def-123-xyz"
}
```

### Step 16: Monitor Job Execution

**In Browser:**

```
http://100.111.3.59:8888
```

**Mission Control Dashboard shows:**
- Job status: PENDING → RUNNING → COMPLETED
- Agent activity in real-time
- Oracle validation logs

**Or via SSH:**

```powershell
ssh root@100.111.3.59

# Check job logs
tail -f /opt/goat/logs/job-abc-def-123-xyz/session.jsonl

# Check Oracle validation
tail -f /opt/goat/state/scrape-log.jsonl
```

### Step 17: Verify Results

```bash
# On VPS
# Check if PR was created
cd /opt/goat/goat-autopilot-src
git fetch origin
git branch -r | grep job/

# Check scraped inventory
ls -la state/inventory.csv
head -5 state/inventory.csv

# Check Oracle passed validation
cat /opt/goat/state/scrape-log.jsonl | tail -1
```

---

## Phase 9: Understand the Workflow (5 min)

### Step 18: Learn the Loop

**The GOAT Autopilot loop:**

```
1. Cron fires (or manual webhook)
   ↓
2. Event Handler creates GitHub job branch
   ↓
3. GitHub Actions spins up Docker container
   ↓
4. Pi agent (autonomous AI) executes job
   ↓
5. Results committed to job branch
   ↓
6. GitHub opens Pull Request
   ↓
7. Agent Oracle validates PR
   ↓
8. If valid: Auto-merge to main + commit to logs
   If invalid: Escalate to COO (you) for review
   ↓
9. Mission Control shows status in real-time
   ↓
10. Team gets notification (Slack/Discord)
```

### Step 19: Check Agent Oracle Logs

```bash
# On VPS
cat /opt/goat/state/scrape-log.jsonl | jq .
cat /opt/goat/state/list-build-log.jsonl | jq .
cat /opt/goat/state/posting-page-log.jsonl | jq .
```

**Each line is one job:**
```json
{
  "timestamp": "2026-02-23T14:22:00Z",
  "dealer": "toyota_bountiful",
  "status": "PASSED",
  "vehicle_count": 47,
  "photos_avg": 5.2,
  "commit": "abc1234"
}
```

---

## Phase 10: Troubleshooting Checklist (if anything fails)

### If Claude Code Won't Launch

```powershell
# Install Claude globally
npm install -g @anthropic-ai/claude

# Try again
claude
```

### If Job Doesn't Create

```powershell
# Check .env is readable
type .env | findstr GH_TOKEN
type .env | findstr ANTHROPIC

# Verify GH_TOKEN is valid
git config --global user.name "Bobby"
git config --global user.email "bobby@example.com"
git push origin main  # Should work if token is valid
```

### If VPS API Doesn't Respond

```powershell
# Check connectivity
ping 100.111.3.59

# SSH and check service
ssh root@100.111.3.59
systemctl status goat-autopilot
systemctl restart goat-autopilot
```

### If Job Hangs

```bash
# On VPS
# Check Docker container
docker ps -a | grep goat

# Check logs
docker logs -f <container_id>

# Force cancel (last resort)
docker kill <container_id>
```

---

## Summary: What Bobby Just Built

✅ **Local Development Environment**
- Node.js + npm
- Git repository cloned
- .env configured
- Claude Code ready

✅ **VPS Infrastructure** (Already running)
- GOAT Autopilot service (:8877)
- Mission Control dashboard (:8888)
- Agent Oracle oversight
- GitHub Actions workflows

✅ **Automation Configuration**
- CRONS.json: Scheduled jobs (scrape-toyota, scrape-mazda)
- TRIGGERS.json: Manual endpoints (/api/build-lists, /api/posting-page)
- Ready for first autonomous job

✅ **Next: Scale It**
- Kick off scrape jobs (manual or cron)
- Monitor via Mission Control
- Review Oracle logs
- Scale to multiple dealerships

---

## Next Steps for Bobby

1. **Launch Claude Code:**
   ```
   .\setup-claude-choose.bat
   Pick Option 1 or 3
   ```

2. **Ask Claude for Help:**
   ```
   "Help me test the first GOAT Autopilot job. What's the exact curl command?"
   ```

3. **Kick Off First Job:**
   ```
   curl -X POST http://100.111.3.59:8877/api/create-job ...
   ```

4. **Monitor in Mission Control:**
   ```
   http://100.111.3.59:8888
   ```

5. **Check Oracle Logs:**
   ```
   ssh root@100.111.3.59
   tail -f /opt/goat/state/scrape-log.jsonl
   ```

---

**Status:** ✅ Bobby's build setup is complete!

**Time Breakdown:**
- Phase 1: 5 min (prerequisites)
- Phase 2: 3 min (clone)
- Phase 3: 5 min (install)
- Phase 4: 5 min (env setup)
- Phase 5: 3 min (VPS test)
- Phase 6: 5 min (config)
- Phase 7: 5 min (Claude)
- Phase 8: 2 min (first job)
- Phase 9: 5 min (learn workflow)
- Phase 10: varies (troubleshooting)

**Total: ~30-40 minutes**

---

**Questions?** Use Claude Code:
```
claude "I'm stuck on [step X]. Help me [problem]."
```
