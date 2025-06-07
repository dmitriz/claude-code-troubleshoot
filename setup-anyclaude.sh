#!/bin/bash

# Simple script to run anyclaude with API keys from .env file

# Load environment variables from .env file
if [ -f ".env" ]; then
    echo "Loading API keys from .env file..."
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    echo "Please edit the .env file and add your API keys."
    exit 1
fi

echo "Choose your LLM provider:"
echo "1. OpenAI (ChatGPT models)"
echo "2. Google (Gemini models)"
echo "3. List available Google models"
read -p "Enter your choice (1, 2, or 3): " provider_choice

if [ "$provider_choice" == "1" ]; then
    if [ -z "$OPENAI_API_KEY" ]; then
        echo "❌ OPENAI_API_KEY not found in .env file"
        echo "Please edit .env and uncomment/add your OpenAI API key"
        exit 1
    fi
    
    echo "🚀 Starting anyclaude with OpenAI..."
    echo "Using GPT-4o model with proper token limits..."
    anyclaude --model openai/gpt-4.1


elif [ "$provider_choice" == "2" ]; then
    if [ -z "$GOOGLE_API_KEY" ]; then
        echo "❌ GOOGLE_API_KEY not found in .env file"
        echo "Please edit .env and uncomment/add your Google API key"
        exit 1
    fi
    
    echo "🚀 Starting anyclaude with Google Gemini..."
    echo "Using verified working model: gemini-2.5-pro-latest"
    anyclaude --model google/gemini-2.5-pro-preview-06-05

elif [ "$provider_choice" == "3" ]; then
    if [ -z "$GOOGLE_API_KEY" ]; then
        echo "❌ GOOGLE_API_KEY not found in .env file"
        exit 1
    fi
    
    echo "📋 Calling Google API to list available models..."
    MODEL_LIST=$(curl -s -H "Authorization: Bearer $GOOGLE_API_KEY" https://generativelanguage.googleapis.com/v1/models)
    
    echo
    echo "Available Google models:"
    echo "$MODEL_LIST" | grep -o '"name": "[^"]*"' | sort | uniq
    echo
    
    # Extract usable model names for anyclaude
    AVAILABLE_MODELS=$(echo "$MODEL_LIST" | grep -o '"name": "[^"]*"' | grep -o '[^"]*$' | sed 's/models\///g' | grep "gemini")
    
    echo "Usable model names with anyclaude:"
    echo "$AVAILABLE_MODELS" | while read -r model; do
        echo "  - google/$model"
    done
    echo
    
    # Ask user to select a model
    read -p "Enter model name to test (e.g., google/gemini-2.5-pro): " model_name
    anyclaude --model "$model_name"
    
else
    echo "❌ Invalid choice. Please select 1, 2, or 3."
    exit 1
fi
