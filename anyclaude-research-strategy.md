# anyclaude Model Integration Research Strategy

This document outlines the systematic approach to verify model compatibility with anyclaude.

## Research Questions

1. Which models are officially supported by anyclaude?
2. Which Google models are available in the free tier?
3. What are the correct model name formats for each provider?
4. What command line options are supported and required?

## Evidence Collection Methods

1. **Direct API Calls**
   - Call Google's model listing API to retrieve actual available models
   - Document the exact API response for reference

2. **Official Documentation Review**
   - Review anyclaude GitHub repository for supported model formats
   - Examine Google AI documentation for free vs. paid tier information
   - Check OpenAI documentation for correct parameter usage

3. **Non-Blocking Testing**
   - Create scripts that test models without blocking the terminal
   - Log all results to files for analysis
   - Use timeout mechanisms to prevent hanging

## Data Organization

Evidence will be organized in:
1. `api-responses/`: Raw API responses from model listing endpoints
2. `test-results/`: Logs from non-blocking model tests
3. `model-compatibility.md`: Final verified compatibility information

## Verification Standards

Before claiming a model works:
1. Must successfully complete a non-blocking test
2. Must be explicitly listed in provider documentation
3. Must be consistently accessible across multiple test runs

## Implementation Path

Only after evidence collection:
1. Update setup scripts with verified working models
2. Document proper command line arguments
3. Create user-friendly, non-blocking interfaces