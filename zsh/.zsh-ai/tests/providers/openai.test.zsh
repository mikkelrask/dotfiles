#!/usr/bin/env zsh

# Tests for OpenAI provider

# Source test helper and the files we're testing
source "${0:A:h}/../test_helper.zsh"
source "${PLUGIN_DIR}/lib/config.zsh"
source "${PLUGIN_DIR}/lib/context.zsh"
source "${PLUGIN_DIR}/lib/providers/openai.zsh"
source "${PLUGIN_DIR}/lib/utils.zsh"

# Mock curl to test API interactions
curl() {
    if [[ "$*" == *"https://api.openai.com/v1/chat/completions"* ]]; then
        # Simulate successful response
        cat <<EOF
{
    "choices": [
        {
            "message": {
                "content": "ls -la"
            }
        }
    ]
}
EOF
        return 0
    fi
    # Call real curl for other requests
    command curl "$@"
}

test_openai_query_success() {
    export OPENAI_API_KEY="test-key"
    export ZSH_AI_OPENAI_MODEL="gpt-4o"
    
    local result=$(_zsh_ai_query_openai "list files")
    assert_equals "ls -la" "$result"
}

test_openai_query_error_response() {
    export OPENAI_API_KEY="test-key"
    export ZSH_AI_OPENAI_MODEL="gpt-4o"
    
    # Override curl to return an error
    curl() {
        if [[ "$*" == *"https://api.openai.com/v1/chat/completions"* ]]; then
            cat <<EOF
{
    "error": {
        "message": "Invalid API key"
    }
}
EOF
            return 0
        fi
        command curl "$@"
    }
    
    local result=$(_zsh_ai_query_openai "list files")
    assert_contains "$result" "API Error:"
}

test_openai_json_escaping() {
    export OPENAI_API_KEY="test-key"
    export ZSH_AI_OPENAI_MODEL="gpt-4o"
    
    # Test with special characters
    local result=$(_zsh_ai_query_openai "test \"quotes\" and \$variables")
    # Should not fail due to JSON escaping issues
    assert_not_empty "$result"
}

# Run tests
run_tests