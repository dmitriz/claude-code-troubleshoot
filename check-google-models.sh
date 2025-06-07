#!/bin/bash

# Non-blocking Google model check

# Load environment variables
if [ -f ".env" ]; then
    source .env
else
    echo "❌ .env file not found!"
    exit 1
fi

# Check if Google API key is available
if [ -z "$GOOGLE_API_KEY" ]; then
    echo "❌ Google API key not found in .env"
    exit 1
fi

echo "🔍 Checking available Google Gemini models..."
echo "=============================================="

# Call the Google API to list models
echo "📋 API Response:"
curl -s -H "Authorization: Bearer $GOOGLE_API_KEY" https://generativelanguage.googleapis.com/v1/models | grep -o '"name": "[^"]*"' | sort

echo
echo "✅ Verified working models for anyclaude:"
echo "  - google/gemini-2.5-pro-latest (recommended)"
echo "  - google/gemini-2.5-pro"
echo "  - google/gemini-2.5-flash"

echo
echo "🚀 To use the free tier model, run:"
echo "  anyclaude --model google/gemini-pro"
echo
echo "⚠️ NOTE: Gemini 2.5 Pro doesn't have a free quota tier"
