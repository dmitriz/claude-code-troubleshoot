#!/bin/bash

# Simple codebase analysis script using anyclaude with Google Gemini
# Alternative to Claude Code when credits are low

# Load environment variables
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

echo "🔍 Codebase Analysis Helper"
echo "=========================="
echo
echo "This script helps analyze your codebase using anyclaude with Google Gemini"
echo "Choose an analysis type:"
echo
echo "1. Analyze specific file"
echo "2. Get project overview"
echo "3. Review code patterns"
echo "4. Interactive analysis session"
echo

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        read -p "Enter file path to analyze: " file_path
        if [ -f "$file_path" ]; then
            echo "📁 Analyzing file: $file_path"
            echo "Starting anyclaude with file content..."
            {
                echo "Please analyze this code file and provide insights:"
                echo "File: $file_path"
                echo "Content:"
                cat "$file_path"
            } | anyclaude --model google/gemini-2.5-pro-latest
        else
            echo "❌ File not found: $file_path"
        fi
        ;;
    2)
        echo "📊 Generating project overview..."
        {
            echo "Please analyze this project structure and provide an overview:"
            echo "Project directories:"
            find . -type d -name ".*" -prune -o -type d -print | head -20
            echo
            echo "Key files:"
            find . -name "*.md" -o -name "*.js" -o -name "*.json" -o -name "*.sh" | head -15
            echo
            echo "Package.json files:"
            find . -name "package.json" -exec echo "=== {} ===" \; -exec cat {} \;
        } | anyclaude --model google/gemini-2.5-pro-latest
        ;;
    3)
        echo "🔍 Analyzing code patterns..."
        {
            echo "Please review these code files for patterns and best practices:"
            echo
            find . -name "*.js" -o -name "*.sh" | head -5 | while read file; do
                echo "=== $file ==="
                head -50 "$file"
                echo
            done
        } | anyclaude --model google/gemini-2.5-pro-latest
        ;;
    4)
        echo "💬 Starting interactive analysis session..."
        echo "You can now ask questions about your codebase!"
        anyclaude --model google/gemini-2.5-pro-latest
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac
