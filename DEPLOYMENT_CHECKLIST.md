# VPS Deployment Checklist - OutboundAI

## ✅ Pre-Deployment Validation PASSED

The validation script confirms:
- ✅ All Python files syntax valid
- ✅ All required files present
- ✅ UI functionality complete
- ✅ Database schema complete
- ✅ Dockerfile ready

## 🚀 VPS Deployment Steps

### 1. VPS Preparation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose (optional)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Environment Variables Setup

**REQUIRED - Set these in your VPS/Coolify:**
```bash
# LiveKit Cloud
LIVEKIT_URL=wss://your-project.livekit.cloud
LIVEKIT_API_KEY=APIxxxxxxxxxxxxxxxxx
LIVEKIT_API_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Google Gemini
GOOGLE_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Supabase
SUPABASE_URL=https://xxxxxxxxxxxxxxxx.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Vobiz SIP
VOBIZ_SIP_DOMAIN=xxxxxxxx.sip.vobiz.ai
VOBIZ_USERNAME=your_username
VOBIZ_PASSWORD=your_password
VOBIZ_OUTBOUND_NUMBER=+919876543210
DEFAULT_TRANSFER_NUMBER=+919876543210
```

### 3. Deployment Options

#### Option A: Direct Docker (Testing)
```bash
# Clone repository
git clone <your-repo-url>
cd outboundai

# Build image
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
  -e DEFAULT_TRANSFER_NUMBER="+919876543210" \
  outboundai
```

#### Option B: Coolify (Production)
1. Push code to GitHub
2. Create Coolify resource from GitHub repo
3. Set all environment variables in Coolify
4. Deploy

#### Option C: Docker Compose (Production)
```bash
# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  outboundai:
    build: .
    ports:
      - "8000:8000"
    environment:
      - LIVEKIT_URL=wss://your-project.livekit.cloud
      - LIVEKIT_API_KEY=APIxxxxxxxxxxxxxxxxx
      - LIVEKIT_API_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      - GOOGLE_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      - SUPABASE_URL=https://xxxxxxxxxxxxxxxx.supabase.co
      - SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
      - VOBIZ_SIP_DOMAIN=xxxxxxxx.sip.vobiz.ai
      - VOBIZ_USERNAME=your_username
      - VOBIZ_PASSWORD=your_password
      - VOBIZ_OUTBOUND_NUMBER=+919876543210
      - DEFAULT_TRANSFER_NUMBER=+919876543210
    restart: unless-stopped
EOF

# Deploy
docker-compose up -d
```

### 4. Post-Deployment Setup

#### Database Setup
1. Go to Supabase Dashboard → SQL Editor
2. Run the contents of `supabase_schema.sql`
3. Verify all tables are created

#### SIP Trunk Creation
1. Open dashboard: `http://your-vps-ip:8000`
2. Go to **Settings** tab
3. Click **⚡ Create SIP Trunk**
4. Verify trunk ID is saved

#### Test Single Call
1. Go to **Single Call** tab
2. Enter your phone number
3. Click **🚀 Start Call**
4. Verify AI agent connects and speaks

## 🔍 Verification Commands

### Check Container Status
```bash
# View running containers
docker ps

# View logs
docker logs outboundai

# Follow logs in real-time
docker logs -f outboundai
```

### Check Service Health
```bash
# Check if dashboard is accessible
curl -I http://localhost:8000/

# Check API endpoints
curl http://localhost:8000/api/stats
curl http://localhost:8000/api/settings
```

### Validate Environment Variables
```bash
# Check environment variables in container
docker exec outboundai env | grep -E "(LIVEKIT|GOOGLE|SUPABASE|VOBIZ)"
```

## 🚨 Troubleshooting

### Container Won't Start
```bash
# Check logs for specific error
docker logs outboundai

# Common issues:
# - Missing environment variables
# - Invalid API keys
# - Port conflicts
```

### Dashboard Not Accessible
```bash
# Check if port 8000 is listening
netstat -tlnp | grep :8000

# Check firewall
sudo ufw status
sudo ufw allow 8000
```

### Calls Not Working
1. Verify LiveKit credentials
2. Check SIP trunk is created
3. Verify Vobiz SIP credentials
4. Check agent worker logs

### Database Issues
1. Verify Supabase credentials
2. Check if schema was installed
3. Test connection in dashboard

## 📊 Monitoring

### Health Checks
```bash
# Create health check script
cat > health-check.sh << 'EOF'
#!/bin/bash
echo "🔍 OutboundAI Health Check"
echo "========================"

# Check if container is running
if docker ps | grep -q outboundai; then
    echo "✅ Container running"
else
    echo "❌ Container not running"
    exit 1
fi

# Check if dashboard responds
if curl -s http://localhost:8000/ > /dev/null; then
    echo "✅ Dashboard responding"
else
    echo "❌ Dashboard not responding"
    exit 1
fi

# Check API endpoints
if curl -s http://localhost:8000/api/stats > /dev/null; then
    echo "✅ API responding"
else
    echo "❌ API not responding"
    exit 1
fi

echo "✅ All checks passed"
EOF

chmod +x health-check.sh
./health-check.sh
```

### Log Monitoring
```bash
# View real-time logs
docker logs -f outboundai

# Filter for errors
docker logs outboundai | grep -i error

# Filter for API calls
docker logs outboundai | grep -i "dispatched\|call"
```

## 🔄 Updates

### Updating the Application
```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d

# Or with direct Docker
docker stop outboundai
docker rm outboundai
docker build -t outboundai .
docker run -d [same environment variables...] outboundai
```

### Updating Environment Variables
1. Update variables in Coolify/Docker
2. Restart container
3. New variables take effect immediately

## 🎯 Success Indicators

✅ **Container starts without errors**  
✅ **Dashboard accessible at port 8000**  
✅ **All configuration chips show green in Stats tab**  
✅ **SIP trunk created successfully**  
✅ **Test call connects and AI speaks**  
✅ **Call logs appear in dashboard**  

## 📞 Support

If issues occur:
1. Check this checklist first
2. Review container logs
3. Verify environment variables
4. Consult VPS_DEPLOYMENT.md
5. Check individual service dashboards

---

**🎉 Your OutboundAI system is ready for VPS deployment!**
