#!/bin/bash

# Quick test script for anyclaude with proper token limits

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

echo "🧪 Quick anyclaude test with proper token limits"
echo "=============================================="

# Test with Google Gemini (usually more reliable)
if [ ! -z "$GOOGLE_API_KEY" ]; then
    echo "Testing Google Gemini with limited tokens..."
    echo "Hello, please respond with just 'Working!' and nothing else." | anyclaude --model google/gemini-2.5-pro-latest --max-tokens 100
    echo
fi

# Test with OpenAI (with token limit)
if [ ! -z "$OPENAI_API_KEY" ]; then
    echo "Testing OpenAI with limited tokens..."
    echo "Hello, please respond with just 'Working!' and nothing else." | anyclaude --model openai/gpt-4o --max-tokens 100
    echo
fi

echo "✅ Test complete!"
