# OutboundAI — AI Voice Calling SaaS Platform

A production-grade AI outbound voice calling SaaS platform that dials phone numbers automatically via SIP telephony (Vobiz), connects each call to a Gemini Live real-time AI voice agent, and books appointments into Supabase and optionally Cal.com.

## 🚀 Features

- **Real-time AI Voice**: Gemini Live API with sub-100ms latency
- **SIP Telephony**: Vobiz SIP trunk integration for outbound calling
- **Appointment Booking**: Automatic booking into Supabase + Cal.com sync
- **Campaign Management**: Mass calling with scheduling (once/daily/weekdays)
- **CRM System**: Contact history, notes, and AI-extracted memory
- **Call Recording**: S3-compatible storage via LiveKit Egress
- **Agent Profiles**: Multiple AI personas with different voices and prompts
- **Single-Page Dashboard**: Complete management interface
- **BYOK Support**: Bring Your Own Keys for all services

## 📋 Tech Stack

- **Backend**: Python 3.11, FastAPI, Uvicorn
- **AI/Telephony**: LiveKit Agents, Google Gemini Live, Vobiz SIP
- **Database**: Supabase (PostgreSQL)
- **Scheduling**: APScheduler
- **Frontend**: Vanilla HTML/CSS/JS, Chart.js
- **Deployment**: Docker + Coolify

## 🛠️ Quick Start

### 1. Prerequisites

- Python 3.11+
- Supabase account
- LiveKit Cloud account
- Google AI Studio API key
- Vobiz SIP trunk account

### 2. Setup

```bash
# Clone the repository
git clone <your-repo>
cd outboundai

# Install dependencies
pip install -r requirements.txt

# Copy environment template
cp .env.example .env

# Edit .env with your API keys
nano .env
```

### 3. Database Setup

1. Create a new Supabase project
2. Run the SQL from `supabase_schema.sql` in Supabase SQL Editor
3. Update SUPABASE_URL and SUPABASE_SERVICE_KEY in .env

### 4. Configure Services

#### LiveKit Cloud
- Go to cloud.livekit.io → Project → Keys
- Copy URL, API Key, and API Secret to .env

#### Google Gemini
- Go to aistudio.google.com/app/apikey
- Create API key and add to .env
- Set model to `gemini-3.1-flash-live-preview`

#### Vobiz SIP
- Sign up at vobiz.ai
- Get SIP domain, username, password, and outbound number
- Add to .env

### 5. Run Locally

```bash
# Start the server
chmod +x start.sh
./start.sh
```

The dashboard will be available at `http://localhost:8000`

## 📊 Dashboard Features

### 📊 Stats
- Real-time KPIs (total calls, booked, booking rate)
- 3 interactive charts (outcomes, timeline, duration)
- Live configuration status

### 📞 Single Call
- Make individual outbound calls
- Agent profile selection
- Custom prompt override

### 📋 Batch Call
- CSV upload for bulk calling
- Configurable delay between calls
- Real-time progress tracking

### 🚀 Campaigns
- Scheduled calling campaigns
- Once/daily/weekdays scheduling
- CSV-based contact lists

### 🤖 Agents
- Multiple AI agent profiles
- Voice selection (30 Gemini voices)
- Custom prompts per agent
- Tool configuration

### ✏️ AI Prompt
- Global system prompt editor
- Character count
- Reset to default

### 📅 Appointments
- View all appointments
- Date filtering
- Cancel appointments

### 📝 Call Logs
- Paginated call history
- Recording links
- Inline notes editing

### 👥 CRM
- Contact aggregation by phone
- Full call history per contact
- Contact details drill-down

### ⚙️ Settings
- API key management
- SIP trunk creation
- Service configuration
- BYOK support

### 📋 System Logs
- Real-time log viewing
- Level and source filtering
- Auto-refresh capability

## 🔧 Deployment

### Docker Deployment

```bash
# Build image
docker build -t outboundai .

# Run container
docker run -p 8000:8000 --env-file .env outboundai
```

### Coolify Deployment

1. Push code to GitHub repository
2. In Coolify: New Resource → GitHub → Select repo
3. Set environment variables in Coolify
4. Deploy with port 8000

## 📡 API Endpoints

### Calls
- `POST /api/call` - Dispatch single call
- `GET /api/calls` - Get call logs
- `PATCH /api/calls/{id}/notes` - Update call notes

### Campaigns
- `POST /api/campaigns` - Create campaign
- `GET /api/campaigns` - List campaigns
- `POST /api/campaigns/{id}/run` - Run campaign now
- `PATCH /api/campaigns/{id}/status` - Update status
- `DELETE /api/campaigns/{id}` - Delete campaign

### Agent Profiles
- `POST /api/agent-profiles` - Create profile
- `GET /api/agent-profiles` - List profiles
- `PUT /api/agent-profiles/{id}` - Update profile
- `DELETE /api/agent-profiles/{id}` - Delete profile
- `POST /api/agent-profiles/{id}/set-default` - Set default

### Appointments
- `GET /api/appointments` - List appointments
- `DELETE /api/appointments/{id}` - Cancel appointment

### Settings
- `GET /api/settings` - Get all settings
- `POST /api/settings` - Save settings
- `POST /api/setup/trunk` - Create SIP trunk

## 🎯 Architecture Rules

### Dial-First Pattern
Always dial first, then start the AI session:
```python
await ctx.api.sip.create_sip_participant(..., wait_until_answered=True)
# Call answered ↑
session = _build_session(...)
await session.start(...)
```

### Silence Prevention
All 3 configs are mandatory for Gemini Live:
1. `SessionResumptionConfig(transparent=True)`
2. `ContextWindowCompressionConfig`
3. `RealtimeInputConfig` with `END_SENSITIVITY_LOW`

### Model Compatibility
- ✅ `gemini-3.1-flash-live-preview` (recommended)
- ✅ `gemini-2.5-flash-native-audio-preview-12-2025`
- ❌ `gemini-2.0-flash-live-001` (policy error)
- ❌ Any `-lite` models

## 💰 Cost Breakdown

| Service | Cost per minute | Notes |
|---------|----------------|-------|
| Vobiz SIP | ₹1.00 | Fixed telephony cost |
| LiveKit Cloud | ₹0.17 | Free tier: 100k participant-minutes/mo |
| Gemini Live | ₹0.03 | Free tier covers most usage |
| **Total** | **≈ ₹1.20/min** | Under ₹1.50 target |

A typical 2-minute call costs ≈ ₹2.40.

## 🛠️ Available Voices

### Female (14)
Aoede, Achernar, Autonoe, Callirrhoe, Despina, Erinome, Gacrux, Kore, Laomedeia, Leda, Pulcherrima, Sulafat, Vindemiatrix, Zephyr

### Male (16)
Achird, Algenib, Algieba, Alnilam, Charon, Enceladus, Fenrir, Iapetus, Orus, Perseus, Puck, Rasalgethi, Sadachbia, Sadaltager, Schedar, Umbriel, Zubenelgenubi

## 🔍 Troubleshooting

### Common Issues

**Call drops at 60s**
- Cause: `close_on_disconnect=True` with SIP
- Fix: Remove it, use `participant_disconnected` event

**Agent goes silent after 30-90s**
- Cause: Wrong `EndSensitivity` enum value
- Fix: Use `END_SENSITIVITY_LOW`

**No initial greeting**
- Cause: Using 3.1/2.5 model but calling `generate_reply()`
- Fix: These models speak autonomously

**1008 error on session start**
- Cause: Using unsupported model
- Fix: Switch to `gemini-3.1-flash-live-preview`

## 📞 Support

For issues and support:
1. Check the troubleshooting section
2. Review system logs in dashboard
3. Verify all API keys are correctly configured
4. Ensure Supabase schema is properly installed

## 📄 License

MIT License - see LICENSE file for details.

---

**Built with ❤️ using LiveKit, Google Gemini, and Supabase**
