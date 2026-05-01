#!/bin/bash
set -e

echo "🔨 Building OutboundAI Docker image..."

# Build the Docker image
docker build -t outboundai .

echo "✅ Build complete"
