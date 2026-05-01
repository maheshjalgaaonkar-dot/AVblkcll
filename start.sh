#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "🚀 Starting OutboundAI on VPS..."

# VPS Environment Variables are SINGLE SOURCE OF TRUTH
# No .env file loading - all config must come from VPS environment

echo "📋 VPS Configuration Check:"
echo "   LiveKit: ${LIVEKIT_URL:-NOT_SET}"
echo "   Gemini: ${GEMINI_MODEL:-gemini-3.1-flash-live-preview}"
echo "   Supabase: ${SUPABASE_URL:-NOT_SET}"
echo "   Vobiz SIP: ${VOBIZ_SIP_DOMAIN:-NOT_SET}"

# Validate required environment variables
if [ -z "$LIVEKIT_URL" ] || [ -z "$LIVEKIT_API_KEY" ] || [ -z "$LIVEKIT_API_SECRET" ]; then
    echo "❌ ERROR: LiveKit credentials not set in VPS environment"
    echo "   Required: LIVEKIT_URL, LIVEKIT_API_KEY, LIVEKIT_API_SECRET"
    exit 1
fi

if [ -z "$GOOGLE_API_KEY" ]; then
    echo "❌ ERROR: Google API key not set in VPS environment"
    echo "   Required: GOOGLE_API_KEY"
    exit 1
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_KEY" ]; then
    echo "❌ ERROR: Supabase credentials not set in VPS environment"
    echo "   Required: SUPABASE_URL, SUPABASE_SERVICE_KEY"
    exit 1
fi

echo "✅ All required environment variables are set"

echo "🌐 Starting FastAPI server on port 8000..."
uvicorn server:app --host 0.0.0.0 --port 8000 &
SERVER_PID=$!

sleep 2

echo "🤖 Starting LiveKit agent worker..."
python agent.py start

kill $SERVER_PID 2>/dev/null || true
