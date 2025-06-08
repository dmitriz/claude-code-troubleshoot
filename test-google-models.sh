#!/bin/bash

# Test script to find working Google Gemini models with anyclaude

# Load API key
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

if [ -z "$GOOGLE_API_KEY" ]; then
    echo "❌ GOOGLE_API_KEY not found in .env file"
    exit 1
fi

echo "🔍 Fetching available Google models first..."
echo "=================================================="

# Get list of available models from Google API
echo "📋 Calling Google API to list available models..."
MODELS_JSON=$(curl -s -H "Authorization: Bearer $GOOGLE_API_KEY" https://generativelanguage.googleapis.com/v1/models)

echo
echo "📑 Available Google models:"
echo "$MODELS_JSON" | grep -o '"name": "[^"]*"' | sort | uniq

# Extract model names from the response
MODEL_NAMES=$(echo "$MODELS_JSON" | grep -o '"name": "[^"]*"' | grep -o '[^"]*$' | sed 's/models\///g')

# Build array of models to test
declare -a models

# Add models with google/ prefix for anyclaude
while IFS= read -r model; do
    if [[ "$model" == *"gemini"* ]]; then
        models+=("google/$model")
    fi
done <<< "$MODEL_NAMES"

# Add Gemini 2.5 models if available
if echo "$MODEL_NAMES" | grep -q "gemini-2.5"; then
    echo "✅ Found Gemini 2.5 models!"
else
    echo "⚠️ No Gemini 2.5 models found, adding manually to test..."
    models+=(
        "google/gemini-2.5-pro"
        "google/gemini-2.5-flash"
        "google/gemini-2.5-pro-latest"
    )
fi

echo
echo "🔍 Testing models with anyclaude..."
echo "=================================================="
echo "📋 Models to test: ${models[@]}"

for model in "${models[@]}"; do
    echo
    echo "🧪 Testing model: $model"
    echo "----------------------------------------"
    
    # Try the model with a simple test (anyclaude will prompt interactively)
    echo "Testing if model loads successfully..."
    timeout 5s anyclaude --model "$model" <<< "Hello from $model" 2>&1 | head -5
    
    if [ $? -eq 0 ]; then
        echo "✅ $model works!"
    else
        echo "❌ $model failed"
    fi
    
    echo "----------------------------------------"
done

echo
echo "🎯 Try running the script and test with the working model!"
