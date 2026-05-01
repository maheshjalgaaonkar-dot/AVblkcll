# VPS Deployment Guide - OutboundAI

## 🚨 IMPORTANT: VPS Environment Variables are SINGLE SOURCE OF TRUTH

This deployment configuration ensures that **ONLY VPS environment variables** are used for configuration. The Supabase settings table is used only for display purposes and will never override VPS environment variables.

## 📋 Required Environment Variables

### Core Services (REQUIRED for deployment)
```bash
# LiveKit Cloud - Get from cloud.livekit.io → Project → Keys
LIVEKIT_URL=wss://your-project.livekit.cloud
LIVEKIT_API_KEY=APIxxxxxxxxxxxxxxxxx
LIVEKIT_API_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Google Gemini - Get from aistudio.google.com/app/apikey
GOOGLE_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Supabase - Get from supabase.com → Project Settings → API
SUPABASE_URL=https://xxxxxxxxxxxxxxxx.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Telephony (REQUIRED for calling)
```bash
# Vobiz SIP - Get from vobiz.ai
VOBIZ_SIP_DOMAIN=xxxxxxxx.sip.vobiz.ai
VOBIZ_USERNAME=your_username
VOBIZ_PASSWORD=your_password
VOBIZ_OUTBOUND_NUMBER=+919876543210
DEFAULT_TRANSFER_NUMBER=+919876543210

# SIP Trunk ID (auto-created after first deployment)
OUTBOUND_TRUNK_ID=ST_xxxxxxxxxxxxxxxx
```

### AI Configuration (Optional - has defaults)
```bash
# Gemini Model Configuration
GEMINI_MODEL=gemini-3.1-flash-live-preview
GEMINI_TTS_VOICE=Aoede
USE_GEMINI_REALTIME=true
```

### Optional Services
```bash
# Twilio SMS (for confirmations)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_FROM_NUMBER=+1234567890

# S3 Storage (for call recordings)
S3_ACCESS_KEY_ID=
S3_SECRET_ACCESS_KEY=
S3_ENDPOINT_URL=https://xxxxxxxxxxxxxxxx.supabase.co/storage/v1/s3
S3_REGION=ap-northeast-1
S3_BUCKET=call-recordings

# Cal.com Integration
CALCOM_API_KEY=cal_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
CALCOM_EVENT_TYPE_ID=123456
CALCOM_TIMEZONE=Asia/Kolkata

# Deepgram STT (fallback pipeline)
DEEPGRAM_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Agent Tools Configuration
ENABLED_TOOLS=["check_availability","book_appointment","end_call","transfer_to_human","send_sms_confirmation","lookup_contact","remember_details","book_calcom","cancel_calcom"]
```

## 🐳 Docker Deployment

### Build and Run
```bash
# Build the image
docker build -t outboundai .

# Run with environment variables
docker run -d \
  --name outboundai \
  -p 8000:8000 \
  -e LIVEKIT_URL="wss://your-project.livekit.cloud" \
  -e LIVEKIT_API_KEY="APIxxxxxxxxxxxxxxxxx" \
  -e LIVEKIT_API_SECRET="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  -e GOOGLE_API_KEY="AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  -e SUPABASE_URL="https://xxxxxxxxxxxxxxxx.supabase.co" \
  -e SUPABASE_SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -e VOBIZ_SIP_DOMAIN="xxxxxxxx.sip.vobiz.ai" \
  -e VOBIZ_USERNAME="your_username" \
  -e VOBIZ_PASSWORD="your_password" \
  -e VOBIZ_OUTBOUND_NUMBER="+919876543210" \
  outboundai
```

### Docker Compose (Recommended)
```yaml
version: '3.8'
services:
  outboundai:
    build: .
    ports:
      - "8000:8000"
    environment:
      # LiveKit
      - LIVEKIT_URL=wss://your-project.livekit.cloud
      - LIVEKIT_API_KEY=APIxxxxxxxxxxxxxxxxx
      - LIVEKIT_API_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      
      # Google Gemini
      - GOOGLE_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      - GEMINI_MODEL=gemini-3.1-flash-live-preview
      - GEMINI_TTS_VOICE=Aoede
      
      # Supabase
      - SUPABASE_URL=https://xxxxxxxxxxxxxxxx.supabase.co
      - SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
      
      # Vobiz SIP
      - VOBIZ_SIP_DOMAIN=xxxxxxxx.sip.vobiz.ai
      - VOBIZ_USERNAME=your_username
      - VOBIZ_PASSWORD=your_password
      - VOBIZ_OUTBOUND_NUMBER=+919876543210
      - DEFAULT_TRANSFER_NUMBER=+919876543210
      
      # Optional: Twilio SMS
      - TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      - TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      - TWILIO_FROM_NUMBER=+1234567890
      
    restart: unless-stopped
```

## ☁️ Coolify Deployment

### Step 1: Push to GitHub
```bash
git add .
git commit -m "Ready for VPS deployment"
git push origin main
```

### Step 2: Create Coolify Resource
1. In Coolify: **New Resource** → **GitHub** → Select your repository
2. **Build Options**: Dockerfile will be auto-detected
3. **Environment Variables**: Add all required variables from above
4. **Port**: Set to **8000**
5. **Deploy**

### Step 3: Configure Environment Variables in Coolify
In Coolify → Your Resource → Environment:
```bash
LIVEKIT_URL=wss://your-project.livekit.cloud
LIVEKIT_API_KEY=APIxxxxxxxxxxxxxxxxx
LIVEKIT_API_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GOOGLE_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SUPABASE_URL=https://xxxxxxxxxxxxxxxx.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VOBIZ_SIP_DOMAIN=xxxxxxxx.sip.vobiz.ai
VOBIZ_USERNAME=your_username
VOBIZ_PASSWORD=your_password
VOBIZ_OUTBOUND_NUMBER=+919876543210
DEFAULT_TRANSFER_NUMBER=+919876543210
```

## 🔧 One-Time Setup After Deployment

### 1. Database Setup
Run this SQL in Supabase Dashboard → SQL Editor:
```sql
-- Copy contents of supabase_schema.sql and run it
```

### 2. Create SIP Trunk
After deployment, go to dashboard → Settings → LiveKit → **⚡ Create SIP Trunk**

### 3. Test Configuration
1. Open dashboard: `http://your-vps-ip:8000`
2. Go to **Stats** tab - should show green configuration chips
3. Go to **Single Call** tab - test with your phone number

## 🚨 Deployment Validation

The startup script validates required environment variables and will fail if:
- `LIVEKIT_URL`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET` are missing
- `GOOGLE_API_KEY` is missing  
- `SUPABASE_URL`, `SUPABASE_SERVICE_KEY` are missing

**Expected startup log:**
```
🚀 Starting OutboundAI on VPS...
📋 VPS Configuration Check:
   LiveKit: wss://your-project.livekit.cloud
   Gemini: gemini-3.1-flash-live-preview
   Supabase: https://xxxxxxxxxxxxxxxx.supabase.co
   Vobiz SIP: xxxxxxxx.sip.vobiz.ai
✅ All required environment variables are set
🌐 Starting FastAPI server on port 8000...
🤖 Starting LiveKit agent worker...
```

## 🔍 Troubleshooting

### Environment Variable Issues
```bash
# Check if variables are set in container
docker exec -it outboundai env | grep -E "(LIVEKIT|GOOGLE|SUPABASE|VOBIZ)"

# View startup logs
docker logs outboundai
```

### Common Errors
**"LiveKit credentials not set"** → Set LIVEKIT_URL, LIVEKIT_API_KEY, LIVEKIT_API_SECRET in VPS environment

**"Google API key not set"** → Set GOOGLE_API_KEY in VPS environment

**"Supabase credentials not set"** → Set SUPABASE_URL, SUPABASE_SERVICE_KEY in VPS environment

### Port Issues
Ensure port 8000 is accessible:
```bash
# Check if port is listening
netstat -tlnp | grep :8000

# If using firewall, allow port 8000
sudo ufw allow 8000
```

## 📊 Monitoring

### Health Check Endpoint
```bash
curl http://your-vps-ip:8000/
```

### System Logs
View logs in dashboard: **Logs** tab or via Docker:
```bash
docker logs -f outboundai
```

## 🔄 Updating Configuration

To update any configuration:
1. Update environment variables in Coolify/Docker
2. Redeploy the container
3. The new values will be used immediately

**Note**: Settings changes in the dashboard UI are for display only and will NOT affect the actual running configuration.

## 🛡️ Security Notes

- Never commit real API keys to Git
- Use Coolify's encrypted environment variables
- Regularly rotate API keys
- Monitor usage in respective service dashboards
- The .env file is ignored by Git and not used in VPS deployment

## 📞 Support

If deployment fails:
1. Check this guide first
2. Verify all required environment variables are set
3. Check container logs for specific error messages
4. Ensure Supabase schema is properly installed

---

**Deployment is now fully configured to use VPS environment variables as the single source of truth!** 🎉
