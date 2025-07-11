#!/usr/bin/env zsh

# Load test helper
source "${0:A:h}/test_helper.zsh"

# Load the config module
source "$PLUGIN_DIR/lib/config.zsh"

@setup {
    setup_test_env
}

@teardown {
    teardown_test_env
}

@test "Default provider is anthropic" {
    unset ZSH_AI_PROVIDER
    source "$PLUGIN_DIR/lib/config.zsh"
    assert_equals "$ZSH_AI_PROVIDER" "anthropic"
}

@test "Default Ollama model is llama3.2" {
    unset ZSH_AI_OLLAMA_MODEL
    source "$PLUGIN_DIR/lib/config.zsh"
    assert_equals "$ZSH_AI_OLLAMA_MODEL" "llama3.2"
}

@test "Default Ollama URL is localhost:11434" {
    unset ZSH_AI_OLLAMA_URL
    source "$PLUGIN_DIR/lib/config.zsh"
    assert_equals "$ZSH_AI_OLLAMA_URL" "http://localhost:11434"
}

@test "Validates anthropic provider" {
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    run _zsh_ai_validate_config
    assert $state equals 0
}

@test "Validates ollama provider" {
    export ZSH_AI_PROVIDER="ollama"
    run _zsh_ai_validate_config
    assert $state equals 0
}

@test "Rejects invalid provider" {
    export ZSH_AI_PROVIDER="invalid"
    run _zsh_ai_validate_config
    assert $state equals 1
    assert "$output" contains "Invalid provider 'invalid'"
}

@test "Requires API key for anthropic provider" {
    export ZSH_AI_PROVIDER="anthropic"
    unset ANTHROPIC_API_KEY
    run _zsh_ai_validate_config
    assert $state equals 1
    assert "$output" contains "ANTHROPIC_API_KEY not set"
}

@test "Does not require API key for ollama provider" {
    export ZSH_AI_PROVIDER="ollama"
    unset ANTHROPIC_API_KEY
    run _zsh_ai_validate_config
    assert $state equals 0
}

@test "Preserves existing provider setting" {
    export ZSH_AI_PROVIDER="ollama"
    source "$PLUGIN_DIR/lib/config.zsh"
    assert_equals "$ZSH_AI_PROVIDER" "ollama"
}

@test "Preserves existing Ollama model setting" {
    export ZSH_AI_OLLAMA_MODEL="codellama"
    source "$PLUGIN_DIR/lib/config.zsh"
    assert_equals "$ZSH_AI_OLLAMA_MODEL" "codellama"
}

@test "Preserves existing Ollama URL setting" {
    export ZSH_AI_OLLAMA_URL="http://remote:11434"
    source "$PLUGIN_DIR/lib/config.zsh"
    assert_equals "$ZSH_AI_OLLAMA_URL" "http://remote:11434"
}

@test "Error message suggests ollama for missing API key" {
    export ZSH_AI_PROVIDER="anthropic"
    unset ANTHROPIC_API_KEY
    run _zsh_ai_validate_config
    assert "$output" contains "use ZSH_AI_PROVIDER=ollama"
}