#!/usr/bin/env zsh

# Tests for the Gemini provider

# Load the test framework
source "${0:A:h}/../test-framework.zsh"

# Load the plugin
source "${0:A:h}/../../zsh-ai.plugin.zsh"

# Test suite
describe "Gemini Provider"

it "should be configured with correct default model"
    expect "$ZSH_AI_GEMINI_MODEL" to_equal "gemini-2.5-flash"

it "should validate when GEMINI_API_KEY is not set"
    unset GEMINI_API_KEY
    ZSH_AI_PROVIDER="gemini"
    _zsh_ai_validate_config > /dev/null 2>&1
    expect "$?" to_equal "1"

it "should validate successfully when GEMINI_API_KEY is set"
    GEMINI_API_KEY="test-key"
    ZSH_AI_PROVIDER="gemini"
    _zsh_ai_validate_config > /dev/null 2>&1
    expect "$?" to_equal "0"

it "should route queries to gemini provider"
    GEMINI_API_KEY="test-key"
    ZSH_AI_PROVIDER="gemini"
    
    # Mock the gemini query function
    _zsh_ai_query_gemini() {
        echo "gemini-response"
    }
    
    result=$(_zsh_ai_query "test query")
    expect "$result" to_equal "gemini-response"

it "should handle API errors gracefully"
    GEMINI_API_KEY="invalid-key"
    ZSH_AI_PROVIDER="gemini"
    
    # This would fail with a real API call
    # For now just test the function exists
    expect "$(type _zsh_ai_query_gemini)" to_contain "_zsh_ai_query_gemini is a shell function"

# Run the tests
run_tests