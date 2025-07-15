#!/usr/bin/env zsh

# Load test helper
source "${0:A:h}/test_helper.zsh"

# Load required modules
source "$PLUGIN_DIR/lib/config.zsh"
source "$PLUGIN_DIR/lib/context.zsh"
source "$PLUGIN_DIR/lib/providers/anthropic.zsh"
source "$PLUGIN_DIR/lib/providers/ollama.zsh"
source "$PLUGIN_DIR/lib/utils.zsh"

@setup {
    setup_test_env
}

@teardown {
    teardown_test_env
}

# _zsh_ai_query routing tests

@test "Routes to Anthropic provider when configured" {
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Mock Anthropic query function
    _zsh_ai_query_anthropic() {
        echo "anthropic:$1"
    }
    
    run _zsh_ai_query "test query"
    assert $state equals 0
    assert "$output" equals "anthropic:test query"
}

@test "Routes to Ollama provider when configured" {
    export ZSH_AI_PROVIDER="ollama"
    
    # Mock Ollama check and query functions
    _zsh_ai_check_ollama() {
        return 0
    }
    
    _zsh_ai_query_ollama() {
        echo "ollama:$1"
    }
    
    run _zsh_ai_query "test query"
    assert $state equals 0
    assert "$output" equals "ollama:test query"
}

@test "Checks Ollama availability before querying" {
    export ZSH_AI_PROVIDER="ollama"
    export ZSH_AI_OLLAMA_URL="http://localhost:11434"
    
    # Mock Ollama check to fail
    _zsh_ai_check_ollama() {
        return 1
    }
    
    run _zsh_ai_query "test query"
    assert $state equals 1
    assert "$output" contains "Ollama is not running"
    assert "$output" contains "http://localhost:11434"
    assert "$output" contains "ollama serve"
}

# zsh-ai command tests

@test "Shows usage when called without arguments" {
    export ZSH_AI_PROVIDER="anthropic"
    
    run zsh-ai
    assert $state equals 1
    assert "$output" contains "Usage: zsh-ai"
    assert "$output" contains "Example:"
    assert "$output" contains "Current provider: anthropic"
}

@test "Shows Ollama model in usage for Ollama provider" {
    export ZSH_AI_PROVIDER="ollama"
    export ZSH_AI_OLLAMA_MODEL="llama3.2"
    
    run zsh-ai
    assert $state equals 1
    assert "$output" contains "Current provider: ollama"
    assert "$output" contains "Ollama model: llama3.2"
}

@test "Executes command when user confirms" {
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Mock query function
    _zsh_ai_query() {
        echo "echo 'Hello World'"
    }
    
    # Mock read to simulate user input
    read() {
        response="y"
    }
    
    # Track eval execution
    local eval_called=0
    local eval_command=""
    eval() {
        eval_called=1
        eval_command="$1"
    }
    
    run zsh-ai "say hello"
    assert $state equals 0
    assert $eval_called equals 1
    assert "$eval_command" equals "echo 'Hello World'"
}

@test "Does not execute command when user declines" {
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Mock query function
    _zsh_ai_query() {
        echo "rm -rf /"
    }
    
    # Mock read to simulate user input
    read() {
        response="n"
    }
    
    # Track eval execution
    local eval_called=0
    eval() {
        eval_called=1
    }
    
    run zsh-ai "dangerous command"
    assert $state equals 0
    assert $eval_called equals 0
}

@test "Handles API errors in zsh-ai command" {
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Mock query function to return error
    _zsh_ai_query() {
        echo "Error: API connection failed"
    }
    
    # Mock print to capture output
    local printed_output=""
    print() {
        printed_output="$printed_output$@\n"
    }
    
    run zsh-ai "test query"
    assert $state equals 1
    assert "$printed_output" contains "Failed to generate command"
    assert "$output" contains "API connection failed"
}

@test "Handles empty response in zsh-ai command" {
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Mock query function to return empty
    _zsh_ai_query() {
        echo ""
    }
    
    # Mock print to capture output
    local printed_output=""
    print() {
        printed_output="$printed_output$@\n"
    }
    
    run zsh-ai "test query"
    assert $state equals 1
    assert "$printed_output" contains "Failed to generate command"
}

@test "Combines multiple arguments in zsh-ai command" {
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Mock query function to echo the query
    _zsh_ai_query() {
        echo "query:$1"
    }
    
    # Mock read to decline execution
    read() {
        response="n"
    }
    
    run zsh-ai find all python files
    assert "$output" contains "query:find all python files"
}

@test "Shows generated command before execution prompt" {
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Mock query function
    _zsh_ai_query() {
        echo "ls -la"
    }
    
    # Mock read to decline execution
    read() {
        response="n"
    }
    
    run zsh-ai "list files"
    assert "$output" contains "ls -la"
    assert "$output" contains "Execute? [y/N]"
}

@test "Case insensitive confirmation acceptance" {
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Mock query function
    _zsh_ai_query() {
        echo "pwd"
    }
    
    # Test with uppercase Y
    read() {
        response="Y"
    }
    
    local eval_called=0
    eval() {
        eval_called=1
    }
    
    run zsh-ai "show directory"
    assert $eval_called equals 1
}