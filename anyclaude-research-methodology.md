# anyclaude Model Integration Research Methodology

This document outlines the systematic methodology for verifying model compatibility with anyclaude.

## Research Questions

1. Which models are officially supported by anyclaude?
2. Which Google models are available in the free tier?
3. What are the correct model name formats for each provider?
4. What command line options are supported by anyclaude?

## Evidence Collection Framework

### 1. Official Documentation Sources

**anyclaude Documentation:**
- GitHub Repository: https://github.com/coder/anyclaude
- Documentation sections to review:
  - README.md
  - Installation instructions
  - Command-line arguments
  - Supported model formats

**Google AI Documentation:**
- API Reference: https://ai.google.dev/api/rest
- Models documentation: https://ai.google.dev/models
- Pricing information: https://ai.google.dev/pricing
- Key sections to review:
  - Free tier models
  - Model naming conventions
  - API version requirements
  - Authentication methods

**OpenAI Documentation:**
- API Reference: https://platform.openai.com/docs/api-reference
- Models documentation: https://platform.openai.com/docs/models
- Key sections to review:
  - Token limit specifications
  - Model capabilities
  - Parameter requirements

### 2. API Response Analysis

**Google Models API:**
- Endpoint: `https://generativelanguage.googleapis.com/v1/models`
- Authentication: Bearer token with API key
- Expected response format:
  - Model name pattern
  - Supported methods
  - Version requirements

**anyclaude Command Reference:**
- Model naming pattern: `[provider]/[model-name]`
- Common parameters:
  - `--model`: Select model to use
  - `--max-tokens`: Limit response size
  - `--non-interactive`: For non-blocking operation

## Data Organization Structure

When collected, evidence will be organized in:

1. `api-responses/`: Directory for raw API responses
2. `test-results/`: Directory for test outcomes
3. `model-compatibility.md`: Final verified documentation

## Verification Criteria

Before considering a model compatible:

1. Must be listed in official provider documentation
2. Must use correct naming pattern required by anyclaude
3. Must be accessible through standard API endpoints
4. Must work with appropriate command parameters

## Documentation Standards

All findings will be documented with:
1. Direct link to source documentation
2. API version reference
3. Date of verification
4. Complete command format example