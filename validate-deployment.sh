#!/bin/bash
set -e

echo "🔍 OutboundAI VPS Deployment Validation"
echo "======================================"

# Function to check environment variable
check_env() {
    local var_name=$1
    local var_value=${!var_name}
    if [ -z "$var_value" ]; then
        echo "❌ MISSING: $var_name"
        return 1
    else
        echo "✅ SET: $var_name"
        return 0
    fi
}

# Function to check if service is reachable
check_service() {
    local service_name=$1
    local url=$2
    local api_key_var=$3
    
    echo "🔍 Checking $service_name..."
    
    if [ -z "$url" ]; then
        echo "❌ $service_name URL not configured"
        return 1
    fi
    
    case $service_name in
        "LiveKit")
            # Basic connectivity check
            if curl -s --connect-timeout 5 "$url" > /dev/null 2>&1; then
                echo "✅ $service_name reachable"
                return 0
            else
                echo "❌ $service_name not reachable"
                return 1
            fi
            ;;
        "Supabase")
            # Check if we can connect to Supabase
            if curl -s --connect-timeout 5 "$url/rest/v1/" > /dev/null 2>&1; then
                echo "✅ $service_name reachable"
                return 0
            else
                echo "❌ $service_name not reachable"
                return 1
            fi
            ;;
        "Google Gemini")
            # Validate API key format
            if [[ ${!api_key_var} =~ ^AIzaSy[A-Za-z0-9_-]{33}$ ]]; then
                echo "✅ $service_name API key format valid"
                return 0
            else
                echo "❌ $service_name API key format invalid"
                return 1
            fi
            ;;
    esac
}

echo ""
echo "📋 Required Environment Variables Check:"
echo "========================================"

# Track overall status
overall_status=0

# Check required variables
echo ""
echo "🔐 Core Services:"
check_env "LIVEKIT_URL" || overall_status=1
check_env "LIVEKIT_API_KEY" || overall_status=1
check_env "LIVEKIT_API_SECRET" || overall_status=1
check_env "GOOGLE_API_KEY" || overall_status=1
check_env "SUPABASE_URL" || overall_status=1
check_env "SUPABASE_SERVICE_KEY" || overall_status=1

echo ""
echo "📞 Telephony Services:"
check_env "VOBIZ_SIP_DOMAIN" || overall_status=1
check_env "VOBIZ_USERNAME" || overall_status=1
check_env "VOBIZ_PASSWORD" || overall_status=1
check_env "VOBIZ_OUTBOUND_NUMBER" || overall_status=1

echo ""
echo "🤖 AI Configuration (Optional - will use defaults if not set):"
check_env "GEMINI_MODEL" || echo "ℹ️  Using default: gemini-3.1-flash-live-preview"
check_env "GEMINI_TTS_VOICE" || echo "ℹ️  Using default: Aoede"
check_env "USE_GEMINI_REALTIME" || echo "ℹ️  Using default: true"

echo ""
echo "🔗 Service Connectivity Check:"
echo "=============================="

check_service "LiveKit" "$LIVEKIT_URL" || overall_status=1
check_service "Supabase" "$SUPABASE_URL" || overall_status=1
check_service "Google Gemini" "" "GOOGLE_API_KEY" || overall_status=1

echo ""
echo "📁 File System Check:"
echo "====================="

# Check if required files exist
required_files=("start.sh" "server.py" "agent.py" "db.py" "tools.py" "prompts.py" "requirements.txt" "Dockerfile" "ui/index.html" "supabase_schema.sql")

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        overall_status=1
    fi
done

echo ""
echo "🐳 Docker Configuration Check:"
echo "=============================="

if command -v docker &> /dev/null; then
    echo "✅ Docker installed"
    
    # Check if Dockerfile exists and is valid
    if [ -f "Dockerfile" ]; then
        echo "✅ Dockerfile exists"
        
        # Basic Dockerfile syntax check
        if docker build --dry-run -f Dockerfile . > /dev/null 2>&1; then
            echo "✅ Dockerfile syntax valid"
        else
            echo "❌ Dockerfile syntax error"
            overall_status=1
        fi
    else
        echo "❌ Dockerfile missing"
        overall_status=1
    fi
else
    echo "❌ Docker not installed"
    overall_status=1
fi

echo ""
echo "🔍 Python Dependencies Check:"
echo "=============================="

if [ -f "requirements.txt" ]; then
    echo "✅ requirements.txt exists"
    
    # Check if Python is available
    if command -v python3 &> /dev/null; then
        echo "✅ Python3 available"
        
        # Check syntax of Python files
        python_files=("server.py" "agent.py" "db.py" "tools.py" "prompts.py")
        for file in "${python_files[@]}"; do
            if python3 -m py_compile "$file" 2>/dev/null; then
                echo "✅ $file syntax valid"
            else
                echo "❌ $file syntax error"
                overall_status=1
            fi
        done
    else
        echo "❌ Python3 not available"
        overall_status=1
    fi
else
    echo "❌ requirements.txt missing"
    overall_status=1
fi

echo ""
echo "🌐 UI Check:"
echo "============="

if [ -f "ui/index.html" ]; then
    echo "✅ UI file exists"
    
    # Basic HTML syntax check
    if grep -q "<!DOCTYPE html>" "ui/index.html"; then
        echo "✅ HTML document structure valid"
    else
        echo "❌ HTML document structure invalid"
        overall_status=1
    fi
    
    # Check for required JavaScript
    if grep -q "switchTab\|api\|fetch" "ui/index.html"; then
        echo "✅ JavaScript functionality present"
    else
        echo "❌ JavaScript functionality missing"
        overall_status=1
    fi
else
    echo "❌ UI file missing"
    overall_status=1
fi

echo ""
echo "📊 Database Schema Check:"
echo "=========================="

if [ -f "supabase_schema.sql" ]; then
    echo "✅ Schema file exists"
    
    # Check for required tables
    required_tables=("appointments" "call_logs" "settings" "error_logs" "campaigns" "contact_memory" "agent_profiles")
    for table in "${required_tables[@]}"; do
        if grep -qi "CREATE TABLE.*$table" "supabase_schema.sql"; then
            echo "✅ Table $table defined"
        else
            echo "❌ Table $table missing"
            overall_status=1
        fi
    done
else
    echo "❌ Schema file missing"
    overall_status=1
fi

echo ""
echo "🚀 Deployment Readiness Summary:"
echo "================================="

if [ $overall_status -eq 0 ]; then
    echo "🎉 ALL CHECKS PASSED - Ready for VPS deployment!"
    echo ""
    echo "📝 Next Steps:"
    echo "1. Set all environment variables in your VPS/Coolify"
    echo "2. Run: docker build -t outboundai ."
    echo "3. Run: docker run -p 8000:8000 [environment variables...] outboundai"
    echo "4. Open: http://your-vps-ip:8000"
    echo "5. Run supabase_schema.sql in Supabase Dashboard"
    echo "6. Create SIP trunk in dashboard Settings"
else
    echo "❌ ISSUES FOUND - Please fix before deployment"
    echo ""
    echo "🔧 Review the errors above and address them:"
    echo "- Set missing environment variables"
    echo "- Fix file syntax errors"
    echo "- Install missing dependencies"
    exit 1
fi

echo ""
echo "✅ Validation complete!"
