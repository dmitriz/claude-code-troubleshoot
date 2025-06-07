#!/bin/bash

# Non-blocking test for anyclaude setup

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

echo "🔍 Testing anyclaude installation and API keys..."
echo "=============================================="

# Check if anyclaude is installed
if command -v anyclaude &> /dev/null; then
    echo "✅ anyclaude is installed"
else
    echo "❌ anyclaude not found - install with: npm install -g anyclaude"
    exit 1
fi

# Test OpenAI setup (if key exists)
if [ ! -z "$OPENAI_API_KEY" ]; then
    echo "✅ OpenAI API key found in .env"
    echo "Ready to use: anyclaude --model openai/gpt-4o --max-tokens 4000"
else
    echo "❌ OpenAI API key not found"
fi

# Test Google setup (if key exists)
if [ ! -z "$GOOGLE_API_KEY" ]; then
    echo "✅ Google API key found in .env"
    echo "Ready to use: anyclaude --model google/gemini-2.5-pro-latest"
else
    echo "❌ Google API key not found"
fi

echo
echo "🚀 To start anyclaude, run:"
echo "   bash setup-anyclaude.sh"
echo
echo "💡 Tips:"
echo "   - Choose option 1 for OpenAI (GPT-4o)"
echo "   - Choose option 2 for Google (Gemini)"
echo "   - Choose option 3 to list available Google models"
