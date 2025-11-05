# URL Content Monitor - n8n Workflow

Simple n8n workflow to monitor URL content changes and send Telegram notifications.

## 🎯 What It Does

- ✅ Checks `https://www.tiwall.com/p/kaa` every minute
- ✅ Bypasses ArvanCloud cookie protection (using curl)
- ✅ Detects content changes using hash comparison
- ✅ Sends Telegram notifications (changed or unchanged)
- ✅ Uses workflow static data (persists across executions)
- ✅ Simple 6-node workflow

## 🚀 Quick Start

### 1. Build and Start Services

```bash
docker-compose down
docker-compose up -d --build
```

This will build a custom n8n image with curl installed.

### 2. Configure Telegram

Edit `.env` file:

```bash
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here
```

Then restart n8n:

```bash
docker-compose restart n8n
```

### 3. Setup n8n Credentials

1. Open http://localhost:5678
2. Go to **Credentials** → **Add Credential**
3. Select **Telegram API**
4. Name: `Telegram account`
5. Add your bot token
6. Save

### 4. Activate Workflow

1. Open the workflow in n8n
2. Click **Active** toggle (IMPORTANT!)
3. Wait for the cron to trigger (every minute)
4. You'll get a Telegram notification!

## 📊 Workflow Structure

**6 Nodes:**

1. **Every Minute** (Cron) - Triggers every minute
2. **Fetch URL** (Execute Command) - Runs curl with cookie handling
3. **Compare Hash** (Code) - Compares content hash using `$getWorkflowStaticData()`
4. **Check If Changed** (IF) - Routes based on status
5. **Send Changed Alert** (Telegram)
6. **Send Unchanged Alert** (Telegram)

## 🔧 How It Works

The workflow uses curl with cookie handling:

```bash
curl -sL -c /tmp/cookies.txt -b /tmp/cookies.txt \
  -A "Mozilla/5.0..." \
  "https://www.tiwall.com/p/kaa"
```

This bypasses ArvanCloud's cookie-based bot protection perfectly.

## ⚠️ Important Notes

1. **Workflow must be ACTIVE** - `$getWorkflowStaticData()` only works when workflow is active (not in test mode)
2. **Custom n8n image** - We build a custom image with curl installed
3. **Hash storage** - Stored in workflow static data (persists even after n8n restarts)
4. **First run** - Will show "FIRST_CHECK" status and store the hash

## 🔧 Useful Commands

```bash
# Build and start services
docker-compose up -d --build

# View logs
docker-compose logs -f n8n

# Stop services
docker-compose down

# Restart n8n
docker-compose restart n8n

# Test curl in container
docker-compose exec n8n curl --version
```

## 🎨 Customization

### Change Check Frequency

Edit the Cron node:
- `* * * * *` = Every minute (current)
- `*/5 * * * *` = Every 5 minutes
- `0 * * * *` = Every hour

### Monitor Different URL

Edit the "Fetch URL" node command - change the URL in the curl command.

### Customize Messages

Edit the two Telegram nodes.

## 🐛 Troubleshooting

### Execute Command not working?

The docker-compose is configured with:
```yaml
- EXECUTIONS_PROCESS=main
- N8N_DISABLE_PRODUCTION_MAIN_PROCESS=true
```

These settings enable Execute Command node.

### curl not found?

Make sure you built the image:
```bash
docker-compose down
docker-compose up -d --build
```

Check if curl is installed:
```bash
docker-compose exec n8n curl --version
```

### Not receiving messages?

1. Check `TELEGRAM_CHAT_ID` is set in `.env`
2. Verify Telegram credentials in n8n
3. **Make sure workflow is ACTIVE** (not just tested)
4. Check n8n logs: `docker-compose logs n8n`

### Getting errors about `$getWorkflowStaticData`?

This function only works when:
- Workflow is **ACTIVE** (toggle it on)
- Triggered by cron (not manual test)

Don't use "Test workflow" or "Execute node" buttons for testing.

## 📝 Files

```
.
├── Dockerfile                  # Custom n8n image with curl
├── docker-compose.yml          # Docker services (n8n + postgres)
├── workflows/
│   └── url-content-monitor.json  # n8n workflow
└── README.md                   # This file
```

## 📈 Status Messages

### Changed
```
🔄 CONTENT CHANGED!

📍 URL: https://www.tiwall.com/p/kaa
⏰ Time: 2025-11-05T00:30:00.000Z
📊 Content Length: 162160 chars
🔍 Hash: a1b2c3d4e5f6...
📝 Previous: f6e5d4c3b2a1...
```

### Unchanged
```
✅ No Changes

📍 URL: https://www.tiwall.com/p/kaa
⏰ Time: 2025-11-05T00:30:00.000Z
📊 Content Length: 162160 chars
🔍 Hash: a1b2c3d4e5f6...
```

## 💡 Why This Approach?

After testing multiple approaches, this solution uses Execute Command with curl because:

1. ✅ **n8n's HTTP Request node cannot handle cookie-based redirects** - The underlying library doesn't preserve manually-set Cookie headers across redirects
2. ✅ **curl handles cookies perfectly** - Native support for cookie jars
3. ✅ **Simple and reliable** - Just 6 nodes
4. ✅ **No external services** - Everything runs in the n8n container
5. ✅ **Fast** - Direct curl execution

---

**Ready!** Run `docker-compose up -d --build` to build the image, then activate the workflow in n8n. 🚀
