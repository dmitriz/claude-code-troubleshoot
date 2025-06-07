# Model Compatibility Evidence Collection

This document contains systematic research findings about model compatibility with anyclaude, based on official documentation, community feedback, and direct testing.

## Google Gemini Models

### Official Documentation
- **Official API Documentation**: [Google Generative AI API](https://ai.google.dev/api/rest)
- **Available Models Endpoint**: `https://generativelanguage.googleapis.com/v1/models`
- **Free vs. Paid Tiers**: [Google AI Pricing](https://ai.google.dev/pricing)

### Naming Convention
Based on Google's official documentation:
- Models are accessible in the format: `gemini-[version]-[variant]`
- When used with anyclaude: `google/gemini-[version]-[variant]`

### Free Tier Models
- `gemini-pro` - The primary free tier model
- `gemini-1.0-pro` - The original 1.0 version
- `gemini-1.0-pro-vision` - Vision-capable model

### Paid Tier Models
- `gemini-1.5-pro` - Requires payment
- `gemini-1.5-flash` - Requires payment
- `gemini-2.5-pro` - Requires payment, no free quota
- `gemini-2.5-flash` - Requires payment, no free quota

### Confirmed Working Models in Tests
- `google/gemini-pro` - Confirmed working (2024-06-07)
  - Source: Direct testing via test-google-models.sh

## OpenAI Models

### Official Documentation
- **Models Documentation**: [OpenAI Models](https://platform.openai.com/docs/models)
- **API Reference**: [OpenAI API](https://platform.openai.com/docs/api-reference/chat)

### Token Limits Evidence
- **GPT-4o**: Max context length of 128K tokens, max output tokens: 4096
  - Source: [OpenAI Model Documentation](https://platform.openai.com/docs/models/gpt-4o)
- **Max Tokens Parameter**: Required to limit response size
  - Usage: `--max-tokens 4000` keeps within safe limits

### Confirmed Working Models in Tests
- `openai/gpt-4o` with `--max-tokens 4000` - Confirmed working (2024-06-07)
  - Source: Direct testing via test script

## anyclaude Tool

### Official Documentation
- **GitHub Repository**: [anyclaude](https://github.com/coder/anyclaude)
- **Model Format Requirements**: Provider prefix required (e.g., `google/`, `openai/`)
- **Command Line Options**:
  - `--model [provider]/[model]` - Select model
  - `--max-tokens [number]` - Limit output tokens
  - `--non-interactive` - Prevent blocking terminal

### Error Patterns
- **"models/gemini-pro is not found"**: Indicates incorrect model name format
- **"max_tokens is too large"**: Token limit exceeds model capability