#!/bin/bash
set -e

echo "🚀 Starting OutboundAI..."

# Ensure we're in the correct directory
cd /app

# Make start.sh executable
chmod +x start.sh

# Execute the main script
exec sh start.sh
