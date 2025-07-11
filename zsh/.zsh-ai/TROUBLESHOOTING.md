# Troubleshooting

## Common Issues

### API Key not found
```bash
zsh-ai: Warning: ANTHROPIC_API_KEY not set. Plugin will not function.
```
**Solution:** Either set your API key or switch to Ollama:
```bash
# Option 1: Set Anthropic API key
export ANTHROPIC_API_KEY="your-key"

# Option 2: Use Ollama instead
export ZSH_AI_PROVIDER="ollama"
```

### Ollama not running
```bash
Error: Ollama is not running at http://localhost:11434
```
**Solution:** Start Ollama with `ollama serve`

### JSON parsing errors
Install `jq` for better reliability:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq
```

## Need More Help?

If you're still experiencing issues:
1. Check that you have the latest version of zsh-ai
2. Verify your API keys are correct
3. [Open an issue](https://github.com/matheusml/zsh-ai/issues) with details about your setup