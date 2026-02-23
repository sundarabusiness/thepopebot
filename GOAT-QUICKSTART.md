# GOAT Autopilot — Quick Start Guide for Johnny

## What This Is

**ThePopeBot fork for GOAT Empire** — Autonomous vehicle scraping, list building, and marketplace posting with Agent Oracle oversight. Runs 24/7 on VPS with full audit trail (every action = git commit).

**Architecture:**
```
GitHub (Job Branch) → Docker Agent (runs scraper/list-builder/generator) → Opens PR
     ↑                                                                            ↓
     └─ Agent Oracle validates → Escalates to COO if needed ← PR Merge Complete
```

---

## Prerequisites

✅ GitHub account with repo push access (`sundarabusiness/thepopebot`)
✅ GitHub Personal Access Token (GH_TOKEN) with `repo`, `workflow`, and `write:org` scopes
✅ Anthropic API key (or local Ollama fallback)
✅ VPS access: `root@100.111.3.59` (Tailscale)

---

## 1. Clone & Setup (5 min)

```bash
# Clone the fork
git clone https://github.com/sundarabusiness/thepopebot.git goat-autopilot
cd goat-autopilot

# Create .env from template
cp .env.example .env

# Edit .env with your credentials
nano .env
# Fill in:
# - AUTH_SECRET (generate: `openssl rand -base64 32`)
# - GH_TOKEN (GitHub PAT)
# - ANTHROPIC_API_KEY (or OPENAI_BASE_URL for Ollama)
```

---

## 2. Verify VPS Deployment (2 min)

```bash
# SSH to VPS
ssh root@100.111.3.59

# Check service status
systemctl status goat-autopilot
# Should show: active (running)

# Check logs
journalctl -u goat-autopilot -f
# Should show: Event handler listening on port 8877

# Test API
curl http://localhost:8877/api/ping
# Should return: {"status":"ok"}
```

---

## 3. Test End-to-End (10 min)

### 3a. Create a Test Job

```bash
# On VPS, create a test scrape job
cat > /tmp/test-job.json <<EOF
{
  "type": "agent",
  "job": "Scrape Toyota Bountiful inventory and generate CSV. Check vehicle count, prices, photos. Log results."
}
EOF

# Post to Event Handler
curl -X POST http://localhost:8877/api/create-job \
  -H "x-api-key: $(grep 'API_KEY' /opt/goat/.env)" \
  -H "Content-Type: application/json" \
  -d @/tmp/test-job.json
```

### 3b. Monitor Job Execution

```bash
# Watch Mission Control dashboard
open http://100.111.3.59:8888
# Should show:
# - New job in "Agents" section
# - Status changing from PENDING → RUNNING
# - Log entries in Activity Feed

# Or check GitHub branches
cd ~/goat-autopilot && git fetch origin
git branch -r
# Should see: origin/job/uuid-timestamp
```

### 3c. Agent Oracle Validates

```bash
# Check Oracle's validation log
cat /opt/goat/state/scrape-log.jsonl
# Should show:
# {
#   "timestamp": "2026-02-23T...",
#   "status": "PASSED",
#   "vehicle_count": 47,
#   "commit": "abc1234"
# }
```

### 3d. PR Merge & Notification

```bash
# Check for merged PR
git log --oneline | head -5
# Should see: Merge pull request #N from origin/job/...

# Check VPC Chat notification
# Should see: [ORACLE] ✅ Scrape validation PASSED: 47 vehicles, prices $6.2k-$28.5k
```

---

## 4. Production Workflows

### Workflow: Scrape Every 4 Hours

**In `config/CRONS.json`:**
```json
[
  {
    "name": "scrape-toyota-bountiful",
    "schedule": "0 */4 * * *",
    "type": "agent",
    "job": "Run browser scraper for Toyota Bountiful Algolia API. Produce state/inventory.csv with columns: Stock,Year,Make,Model,Trim,Price,Mileage,VIN,Drivetrain,Color,Notes,Photos"
  }
]
```

**Trigger:** Cron fires at 0:00, 4:00, 8:00, 12:00, 16:00, 20:00 UTC
**Agent Oracle:** Validates → Escalates if vehicle_count drift >20%, price changes >15%, or photos dead

---

### Workflow: Build Lists After Scrape Approval

**Manual Trigger (COO approves via Mission Control):**
```bash
curl -X POST http://100.111.3.59:8877/api/create-job \
  -H "x-api-key: YOUR_API_KEY" \
  -d '{
    "type": "agent",
    "job": "Build lists for Thomas, Bryan, Trevor from inventory.csv. Score all vehicle types on FB marketplace velocity. Thomas P1 (picks first), Bryan P2, Trevor P2. No overlaps. Output: lists/{thomas,bryan,trevor}.json + bench_*.json"
  }'
```

**Agent Oracle:** Validates list composition → checks for overlaps → escalates if bench sizing wrong

---

### Workflow: Generate Posting Pages

**After Lists Approved:**
```bash
curl -X POST http://100.111.3.59:8877/api/create-job \
  -H "x-api-key: YOUR_API_KEY" \
  -d '{
    "type": "agent",
    "job": "Generate HTML posting pages for each agent list. Include: PIN gate (4-digit SHA-256), photo gallery, blur tool, flag buttons, copy button, SOLD tracking. File: posting_page_{timestamp}.html"
  }'
```

**Agent Oracle:** QA checks HTML validity, PIN logic, listing tone, photo accessibility

---

## 5. Agent Oracle Escalation Rules

**Escalate to COO (require human approval):**
- Scrape vehicle count drops >20%
- >3 photo URLs dead
- Price changes >15% (dealer repricing)
- Duplicate VINs detected
- List overlap found
- >3 listings fail tone check

**Handle Autonomously (no escalation):**
- Transient GitHub API failures → retry 3x
- Minor price variations ±$200
- Photo count variations
- Bench rebalancing

---

## 6. Mission Control Dashboard

**Access:** http://100.111.3.59:8888

**Shows:**
- **Who's Online** — Team presence (green/yellow/gray), last seen
- **File Locks** — What files are locked, by whom, auto-expire time
- **Agents** — All 20+ agents, last active, status
- **Activity Feed** — All locks, unlocks, agent job status, PR merges
- **Services Health** — Ollama, LiteLLM, Dashboard, Chat, Oracle

**Your CLI Tools:**
- `cowork lock goat_config.json "testing new settings"`
- `cowork unlock goat_config.json`
- `cowork status` — Show all locks + online users

---

## 7. Troubleshooting

### Service Won't Start

```bash
# Check systemd errors
systemctl status goat-autopilot
journalctl -u goat-autopilot -n 50

# Common issues:
# - .env missing → create from .env.example
# - GH_TOKEN invalid → test with `gh auth status`
# - PORT 8877 in use → `lsof -i :8877` and kill process
# - Docker not running → `docker ps` should work
```

### Agent Job Hung

```bash
# Check Docker containers
docker ps -a | grep goat

# Check job logs
cd /opt/goat/logs && ls -lt
cat job-<uuid>/session.jsonl | tail -20

# Force cancel (last resort)
curl -X POST http://100.111.3.59:8877/api/jobs/cancel/<job_uuid> \
  -H "x-api-key: YOUR_API_KEY"
```

### Agent Oracle Not Validating

```bash
# Check Oracle process
ps aux | grep oracle

# Check validation logs
tail -20 /opt/goat/state/scrape-log.jsonl

# Restart if needed
systemctl restart goat-autopilot
```

---

## 8. Scaling to More Dealerships

**Create a new fork for each dealership:**
```bash
# Fork goat-autopilot to goat-autopilot-dealer2
# Update GH_OWNER and GH_REPO in .env
# Each dealership runs independently, Agent Oracle monitors all
```

**Master control (COO view):**
```bash
# Monitor all dealerships in Mission Control
# All activity streams merge into single dashboard
# Central escalation queue for all oracles
```

---

## 9. Next: Full Documentation

See `config/GOAT-Oracle-SOUL.md` for:
- Complete autonomous workflows
- Escalation decision tree
- State machine diagrams
- Success metrics

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `npm install` | Install dependencies |
| `npm start` | Start event handler locally |
| `npm run db:generate` | Generate database migration |
| `npm test` | Run tests (stub) |
| `thepopebot setup` | Interactive setup wizard |
| `thepopebot diff` | Show changes vs. package defaults |

---

**Status:** ✅ Ready for Johnny to build
**Next:** SSH to VPS, fill in `.env`, kick off first scrape test job
