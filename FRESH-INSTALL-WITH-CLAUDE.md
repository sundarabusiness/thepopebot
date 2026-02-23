# Fresh Install: Local Claude Code + Everything (Bobby Edition)

**Goal:** Install Claude Code locally, then use Claude to help install GOAT Autopilot
**Total Time:** 45-60 minutes
**Difficulty:** Easy (Claude does most of the work)

---

## The Strategy

```
Step 1: Install Claude locally (bootstrap)
  ↓
Step 2: Use Claude to help with next steps
  ↓
Step 3: Claude walks you through Node, Git, Ollama, LiteLLM setup
  ↓
Step 4: Claude helps clone fork, fill .env, configure GOAT
  ↓
Done: GOAT Autopilot production-ready + Claude assistant
```

---

## Stage 1: Bootstrap — Get Claude Code Running (15 min)

### Step 1: Install Node.js (5 min)

1. Download: https://nodejs.org/en/download/ (LTS version)
2. Run installer
3. Accept defaults
4. Restart computer (optional but recommended)

**Verify:**
```powershell
node --version
npm --version
```

Should show versions like `v22.x.x`

### Step 2: Install Claude Code Globally (5 min)

**PowerShell:**
```powershell
npm install -g @anthropic-ai/claude
```

**Verify:**
```powershell
claude --version
```

Should show version number

### Step 3: Configure Local LiteLLM Proxy (5 min)

**Install LiteLLM:**
```powershell
pip install litellm
```

**Create config directory:**
```powershell
mkdir $env:USERPROFILE\.litellm
```

**Create config file** (`$env:USERPROFILE\.litellm\config.yaml`):

Using PowerShell:
```powershell
$configPath = "$env:USERPROFILE\.litellm\config.yaml"
@"
model_list:
  - model_name: claude-opus-4-6
    litellm_params:
      model: ollama/qwen2.5-coder
      api_base: http://localhost:11434

  - model_name: claude-sonnet-4-6
    litellm_params:
      model: ollama/qwen2.5-coder
      api_base: http://localhost:11434

  - model_name: claude-haiku-4-5-20251001
    litellm_params:
      model: ollama/qwen2.5-coder
      api_base: http://localhost:11434
"@ | Out-File -FilePath $configPath -Encoding UTF8
```

---

## Stage 2: Get Ollama Running (10 min)

### Step 4: Install Ollama

1. Download: https://ollama.com/download/windows
2. Run installer
3. Click "Install"
4. Ollama will start automatically (check system tray)

**Verify:**
```powershell
# Ollama should be in system tray (look for llama icon)
```

### Step 5: Pull Qwen Model

**PowerShell:**
```powershell
ollama pull qwen2.5-coder:7b
```

**This will:**
- Download ~4.7GB
- Take 2-5 minutes
- Show progress bar

**After complete:**
```powershell
ollama list
```

Should show:
```
NAME                     ID              SIZE
qwen2.5-coder:7b         3b3c2d8f5e9a    4.7GB
```

---

## Stage 3: Launch Everything (3 terminals)

### Step 6: Terminal 1 — Ollama (Already Running)

Ollama is already in your system tray. Just verify it's responsive:

```powershell
# Test Ollama
curl http://localhost:11434/api/tags
```

Should show your model list.

### Step 7: Terminal 2 — Start LiteLLM Proxy

**New PowerShell window:**
```powershell
litellm --config $env:USERPROFILE\.litellm\config.yaml --port 3456
```

**Expected output:**
```
✓ LiteLLM proxy server is running on http://localhost:3456
✓ Models loaded: claude-opus-4-6, claude-sonnet-4-6, claude-haiku-4-5-20251001
```

**Keep this window open!**

### Step 8: Terminal 3 — Launch Claude Code

**Another new PowerShell window:**
```powershell
$env:ANTHROPIC_BASE_URL = "http://localhost:3456"
claude
```

**You should see Claude Code ready:**
```
>
```

**Type a test:**
```
claude> Hello! Can you help me install GOAT Autopilot?
```

Claude should respond immediately (using local Ollama).

---

## Stage 4: Use Claude to Help Build GOAT (30-45 min)

### Step 9: Now Ask Claude for Help

**In Claude Code terminal, ask:**

```
Help me set up GOAT Autopilot from the GitHub fork. Here's what I need to do:

1. Clone: https://github.com/sundarabusiness/thepopebot.git
2. Create .env file
3. Fill in: GH_TOKEN (GitHub PAT) and ANTHROPIC_API_KEY (Anthropic)
4. Configure config/CRONS.json for scrape jobs
5. Configure config/TRIGGERS.json for webhooks
6. Connect to VPS at 100.111.3.59

What's the first step? Walk me through each command.
```

**Claude will provide:**
- Exact commands to copy-paste
- Explanations of what each step does
- Troubleshooting if anything fails
- Help filling in configuration files

### Step 10: Follow Claude's Instructions

Claude will guide you through:

```
✓ Create working directory
✓ Clone the fork
✓ Check directory structure
✓ Generate .env from template
✓ Get GitHub PAT
✓ Get Anthropic API key
✓ Fill .env
✓ Verify VPS connectivity
✓ Edit CRONS.json
✓ Edit TRIGGERS.json
✓ Commit and push to GitHub
✓ Launch first test job
✓ Monitor on Mission Control dashboard
```

### Step 11: Use Claude Throughout

**For any step:**
```
I'm stuck on [thing]. Here's the error: [paste error]
```

Claude will:
- Debug the issue
- Provide fixes
- Explain what went wrong
- Prevent it next time

---

## What You'll Have After This

✅ **Claude Code running locally** (no API keys needed, unlimited free)
✅ **Ollama running** with Qwen2.5-Coder model
✅ **LiteLLM proxy** connecting Claude to Ollama
✅ **GOAT Autopilot** cloned and configured
✅ **VPS connected** to Agent Oracle
✅ **First job** tested and working
✅ **Claude assistant** ready to help with anything else

---

## Terminal Setup (Keep This Open)

**Permanently:**

Create a batch file `launch-claude.bat`:

```batch
@echo off
REM Launch all services for GOAT Autopilot development

REM Terminal 1: Ollama (already in system tray, just verify)
echo Starting LiteLLM proxy in Terminal 2...
start "LiteLLM Proxy" cmd /k "litellm --config %USERPROFILE%\.litellm\config.yaml --port 3456"

timeout /t 3 /nobreak

REM Terminal 2: Claude Code
echo Starting Claude Code in Terminal 3...
start "Claude Code" cmd /k "set ANTHROPIC_BASE_URL=http://localhost:3456 && claude"

echo.
echo ✓ All services started!
echo.
echo Terminal 1 (LiteLLM): Should show "server is running on http://localhost:3456"
echo Terminal 2 (Claude): Should show ">" prompt
echo.
echo Type in Terminal 2: Help me set up GOAT Autopilot from GitHub
echo.
```

**Next time:** Just double-click `launch-claude.bat` and you're ready to go.

---

## Troubleshooting

### "claude command not found"
```powershell
npm install -g @anthropic-ai/claude
```

### "LiteLLM proxy won't start"
```powershell
# Check if port 3456 is in use
netstat -ano | findstr :3456

# If in use, kill it:
taskkill /PID <process_id> /F

# Try again
litellm --config $env:USERPROFILE\.litellm\config.yaml --port 3456
```

### "Ollama not running"
1. Check system tray for Ollama icon
2. Or: `start ollama serve` in PowerShell
3. Or: Download and install from https://ollama.com/download/windows

### "Model not found"
```powershell
ollama pull qwen2.5-coder:7b
```

### "Claude responds very slowly (15-30 sec)"
- This is normal on CPU (no GPU)
- Ollama is processing on your CPU
- First response is slower (model loads)
- Subsequent responses are faster
- If unbearable, upgrade GPU or use VPS option

### "Out of memory"
- Qwen needs ~5GB RAM
- Close other apps
- Monitor RAM: `tasklist /v | findstr ollama`

---

## What Claude Can Help With

Once running, ask Claude:

```
"Help me [task]"

Examples:
  - "Help me configure CRONS.json for Toyota scrape every 4 hours"
  - "Help me debug this error: [paste error]"
  - "Walk me through filling in .env"
  - "Explain what Agent Oracle does"
  - "How do I test the first job?"
  - "What's a Git commit?"
  - "How does the workflow loop work?"
```

Claude will:
- Provide code snippets
- Explain concepts
- Debug errors
- Answer questions
- Guide you through setup
- Help with anything GOAT-related

---

## Next Steps After Fresh Install

1. **Use Claude to clone fork:**
   ```
   "Help me clone the GOAT Autopilot fork and set up the project"
   ```

2. **Use Claude to fill .env:**
   ```
   "I need to fill .env. Where do I get GH_TOKEN and ANTHROPIC_API_KEY?"
   ```

3. **Use Claude to configure jobs:**
   ```
   "Help me configure CRONS.json and TRIGGERS.json for GOAT"
   ```

4. **Use Claude to test first job:**
   ```
   "How do I kick off the first scrape job? Give me the exact curl command"
   ```

5. **Use Claude for anything else:**
   ```
   "Help me [anything]"
   ```

---

## Performance Notes

**CPU (Local):**
- Qwen2.5-Coder on CPU: 15-30 seconds per response
- First response slower (model initialization)
- Subsequent responses faster (~15s stable)
- Fine for configuration and setup work

**GPU (Optional Upgrade):**
- NVIDIA: Install CUDA + nvidia-python (auto-detected by Ollama)
- AMD: Install ROCm (auto-detected by Ollama)
- Response time: 2-5 seconds (3-6x faster)

**If Too Slow:**
- Option 1: Get GPU
- Option 2: Switch to VPS LiteLLM (5-10 sec, no install needed)
- Option 3: Use cloud API (1 sec, but costs money)

---

## Bobby's Recommended Path

1. **Install Node.js** (5 min)
2. **Install Claude Code** (`npm install -g @anthropic-ai/claude`)
3. **Install Ollama** (download + install)
4. **Pull model** (`ollama pull qwen2.5-coder:7b`)
5. **Set up LiteLLM** (create config file)
6. **Launch everything** (3 terminals)
7. **Ask Claude for help** ("Help me set up GOAT Autopilot")
8. **Follow Claude's step-by-step instructions**
9. **Done!** (GOAT Autopilot production-ready)

---

## Time Breakdown

| Phase | Time | What |
|-------|------|------|
| Node.js + Claude install | 5 min | Download + install |
| Ollama setup | 10 min | Download + model pull |
| LiteLLM config | 5 min | Create config file |
| Launch (3 terminals) | 3 min | Start services |
| Use Claude to build GOAT | 15-30 min | Follow Claude's steps |
| **TOTAL** | **38-53 min** | **Production ready** |

---

## Files to Save

After installing, save these:
- `$env:USERPROFILE\.litellm\config.yaml` — LiteLLM config
- `launch-claude.bat` — Quick launcher script
- GitHub fork: `C:\projects\goat-autopilot` — Your work directory

---

**Status:** ✅ Ready to start!

**First command to run:**
```powershell
npm install -g @anthropic-ai/claude
```

Then follow the 11 steps above. 🚀
