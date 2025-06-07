#!/bin/bash
# Aider Installation and Configuration Script for Terminal-Native AI Tool Research
# Created: June 6, 2025
# Part of Claude Code Alternative Research

set -e # Exit immediately if a command exits with a non-zero status

# Color codes for better visibility
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}=======================================================${NC}"
echo -e "${BLUE}Aider Installation Script - Terminal-Native AI Research${NC}"
echo -e "${BLUE}=======================================================${NC}"

# Check Python version
echo -e "${YELLOW}Checking Python version...${NC}"
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo "Detected Python $PYTHON_VERSION"

# Validate Python version
if [[ $(echo $PYTHON_VERSION | cut -d'.' -f1) -lt 3 || ($(echo $PYTHON_VERSION | cut -d'.' -f1) -eq 3 && $(echo $PYTHON_VERSION | cut -d'.' -f2) -lt 8) ]]; then
    echo -e "${RED}Error: Aider requires Python 3.8 or newer.${NC}"
    exit 1
fi

# Create virtual environment
echo -e "${YELLOW}Creating Python virtual environment...${NC}"
VENV_DIR="$HOME/aider-env"
python3 -m venv $VENV_DIR
source $VENV_DIR/bin/activate

# Install Aider
echo -e "${YELLOW}Installing Aider via pip...${NC}"
pip install --upgrade pip
pip install aider-chat

# Verify installation
echo -e "${YELLOW}Verifying Aider installation...${NC}"
AIDER_VERSION=$(aider --version 2>/dev/null || echo "Not installed")
if [[ $AIDER_VERSION == "Not installed" ]]; then
    echo -e "${RED}Error: Aider installation failed.${NC}"
    exit 1
else
    echo -e "${GREEN}Successfully installed Aider $AIDER_VERSION${NC}"
fi

# Create API key configuration
echo -e "${YELLOW}Setting up API key configuration...${NC}"
mkdir -p $HOME/.aider
CONFIG_FILE=$HOME/.aider/config.yml

# Check if config already exists
if [ -f "$CONFIG_FILE" ]; then
    echo "Config file already exists at $CONFIG_FILE"
else
    # Create basic config
    cat > $CONFIG_FILE << EOL
# Aider configuration file
# Created for Claude Code Alternative Research

# Model configuration
main_model: claude-3-5-sonnet  # Default model
edit_format: diff  # Similar to Claude Code's format

# Repository settings
auto_commits: true  # Enable automatic commits like Claude Code
commit_message_prefix: "ai: "  # Prefix for commit messages

# API Keys
# !! Replace placeholders with actual keys !!
api_keys:
  anthropic: "ANTHROPIC_API_KEY_PLACEHOLDER"
  openai: "OPENAI_API_KEY_PLACEHOLDER"
  deepseek: "DEEPSEEK_API_KEY_PLACEHOLDER"

# Model aliases for easy reference
model_aliases:
  sonnet: claude-3-5-sonnet
  haiku: claude-3-haiku
  opus: claude-3-opus
  gpt4: gpt-4o
  mini: gpt-3.5-turbo

# Git integration
git:
  auto_commit: true
EOL
    echo -e "${GREEN}Created config file at $CONFIG_FILE${NC}"
    echo -e "${YELLOW}Please edit this file and add your actual API keys.${NC}"
fi

# Create helper script for easy access
echo -e "${YELLOW}Creating helper script...${NC}"
cat > $HOME/aider-run.sh << EOL
#!/bin/bash
# Aider runner script with environment setup
# Part of Claude Code Alternative Research

# Activate virtual environment
source $VENV_DIR/bin/activate

# Set up environment variables if not already set
if [ -z "\$ANTHROPIC_API_KEY" ] && [ -f "\$HOME/.anthropic_key" ]; then
    export ANTHROPIC_API_KEY=\$(cat \$HOME/.anthropic_key)
fi

if [ -z "\$OPENAI_API_KEY" ] && [ -f "\$HOME/.openai_key" ]; then
    export OPENAI_API_KEY=\$(cat \$HOME/.openai_key)
fi

if [ -z "\$DEEPSEEK_API_KEY" ] && [ -f "\$HOME/.deepseek_key" ]; then
    export DEEPSEEK_API_KEY=\$(cat \$HOME/.deepseek_key)
fi

# Run aider with the provided arguments
aider \$@
EOL
chmod +x $HOME/aider-run.sh

# Create test file
echo -e "${YELLOW}Creating test file...${NC}"
mkdir -p $HOME/aider-test
cat > $HOME/aider-test/hello.py << EOL
# Simple test file for Aider
# Part of Claude Code Alternative Research

def main():
    print("Hello, Aider!")
    # TODO: Add more functionality here

if __name__ == "__main__":
    main()
EOL

# Create a tracking script for token usage
echo -e "${YELLOW}Creating token usage tracking script...${NC}"
cat > $HOME/aider-track.sh << EOL
#!/bin/bash
# Token usage tracking for cost analysis
# Part of Claude Code Alternative Research

MODEL=\$1
TASK=\$2
shift 2
FILES=\$@

LOG_FILE="$HOME/aider-test/token_usage_\$(date +%Y%m%d_%H%M%S).log"
CSV_FILE="$HOME/aider-test/token_analysis.csv"

# Create CSV header if it doesn't exist
if [ ! -f "\$CSV_FILE" ]; then
    echo "timestamp,task,model,input_tokens,output_tokens,estimated_cost" > "\$CSV_FILE"
fi

# Run aider with verbose output to capture token usage
echo "Running \$TASK with model \$MODEL on files: \$FILES"
AIDER_OUTPUT=\$(TOKENIZERS_PARALLELISM=false $HOME/aider-run.sh --model \$MODEL --verbose \$FILES 2>&1)
echo "\$AIDER_OUTPUT" > "\$LOG_FILE"

# Extract token counts
INPUT_TOKENS=\$(grep "Input tokens:" "\$LOG_FILE" | tail -1 | awk '{print \$3}')
OUTPUT_TOKENS=\$(grep "Output tokens:" "\$LOG_FILE" | tail -1 | awk '{print \$3}')

# Calculate estimated cost based on model
if [[ "\$MODEL" == *"claude"* ]]; then
    # Claude pricing: $3/M input, $15/M output
    INPUT_COST=\$(echo "scale=6; \$INPUT_TOKENS * 3 / 1000000" | bc)
    OUTPUT_COST=\$(echo "scale=6; \$OUTPUT_TOKENS * 15 / 1000000" | bc)
    TOTAL_COST=\$(echo "scale=6; \$INPUT_COST + \$OUTPUT_COST" | bc)
elif [[ "\$MODEL" == *"gpt-4"* ]]; then
    # GPT-4 pricing: $10/M input, $30/M output (approximate)
    INPUT_COST=\$(echo "scale=6; \$INPUT_TOKENS * 10 / 1000000" | bc)
    OUTPUT_COST=\$(echo "scale=6; \$OUTPUT_TOKENS * 30 / 1000000" | bc)
    TOTAL_COST=\$(echo "scale=6; \$INPUT_COST + \$OUTPUT_COST" | bc)
else
    # Default pricing (approximate)
    INPUT_COST=\$(echo "scale=6; \$INPUT_TOKENS * 1 / 1000000" | bc)
    OUTPUT_COST=\$(echo "scale=6; \$OUTPUT_TOKENS * 5 / 1000000" | bc)
    TOTAL_COST=\$(echo "scale=6; \$INPUT_COST + \$OUTPUT_COST" | bc)
fi

# Record results
TIMESTAMP=\$(date +"%Y-%m-%d %H:%M:%S")
echo "\$TIMESTAMP,\$TASK,\$MODEL,\$INPUT_TOKENS,\$OUTPUT_TOKENS,\$TOTAL_COST" >> "\$CSV_FILE"

# Display results
echo ""
echo "========================================="
echo "Task: \$TASK"
echo "Model: \$MODEL"
echo "Input tokens: \$INPUT_TOKENS"
echo "Output tokens: \$OUTPUT_TOKENS"
echo "Estimated cost: \$\$TOTAL_COST"
echo "Log saved to: \$LOG_FILE"
echo "========================================="
EOL
chmod +x $HOME/aider-track.sh

# Create a simple test script
echo -e "${YELLOW}Creating test script...${NC}"
cat > $HOME/aider-test/run-tests.sh << EOL
#!/bin/bash
# Test script for Aider vs Claude Code comparison
# Part of Claude Code Alternative Research

# Create test directories
mkdir -p $HOME/aider-test/ssh-test
mkdir -p $HOME/aider-test/container-test
mkdir -p $HOME/aider-test/kubernetes-test

# Run basic functionality test with Claude
echo "Running basic test with Claude model..."
$HOME/aider-track.sh sonnet "basic_test" $HOME/aider-test/hello.py

# Run basic functionality test with OpenAI
echo "Running basic test with OpenAI model..."
$HOME/aider-track.sh gpt4 "basic_test" $HOME/aider-test/hello.py

# Generate test report
echo "Generating test report..."
cat $HOME/aider-test/token_analysis.csv
EOL
chmod +x $HOME/aider-test/run-tests.sh

# Print instructions
echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}Aider successfully installed and configured!${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Edit $CONFIG_FILE and add your API keys"
echo "2. Create API key files if you want to use environment variables:"
echo "   - Save your Anthropic API key to $HOME/.anthropic_key"
echo "   - Save your OpenAI API key to $HOME/.openai_key"
echo "   - Save your DeepSeek API key to $HOME/.deepseek_key"
echo "3. Run Aider with the helper script: $HOME/aider-run.sh"
echo "4. Track token usage with: $HOME/aider-track.sh [model] [task] [files]"
echo "5. Run the test script: $HOME/aider-test/run-tests.sh"
echo ""
echo "Example usage:"
echo "  $HOME/aider-run.sh --model sonnet $HOME/aider-test/hello.py"
echo ""
echo -e "${BLUE}For research purposes, all token usage is logged to:${NC}"
echo "  $HOME/aider-test/token_analysis.csv"
echo ""
echo -e "${GREEN}Happy researching!${NC}"
