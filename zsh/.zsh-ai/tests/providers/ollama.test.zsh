#!/usr/bin/env zsh

# Load test helper
source "${0:A:h:h}/test_helper.zsh"

# Load the context and ollama provider modules
source "$PLUGIN_DIR/lib/context.zsh"
source "$PLUGIN_DIR/lib/config.zsh"
source "$PLUGIN_DIR/lib/providers/ollama.zsh"

@setup {
    setup_test_env
    export ZSH_AI_OLLAMA_MODEL="llama3.2"
    export ZSH_AI_OLLAMA_URL="http://localhost:11434"
}

@teardown {
    teardown_test_env
}

@test "Check if Ollama is running - success" {
    # Mock successful curl response
    mock_curl_response '{"models":[]}' 0
    
    run _zsh_ai_check_ollama
    assert $state equals 0
    assert_called "curl" 1
}

@test "Check if Ollama is running - failure" {
    # Mock curl failure
    mock_command "curl" "" 1
    
    run _zsh_ai_check_ollama
    assert $state equals 1
}

@test "Successful API call with jq available" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock successful curl response
    local mock_response='{"response":"git status"}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "show git status"
    assert $state equals 0
    assert "$output" equals "git status"
    assert_called "curl" 1
}

@test "Successful API call without jq" {
    # Mock jq as unavailable
    mock_jq "false"
    
    # Mock successful curl response
    local mock_response='{"response":"docker ps -a"}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "list all docker containers"
    assert $state equals 0
    assert "$output" equals "docker ps -a"
}

@test "Handles API error response with jq" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock error response
    local mock_response='{"error":"Model not found"}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "test query"
    assert $state equals 1
    assert "$output" contains "Ollama Error: Model not found"
}

@test "Handles curl connection failure" {
    # Mock curl failure
    mock_command "curl" "" 1
    
    run _zsh_ai_query_ollama "test query"
    assert $state equals 1
    assert "$output" contains "Failed to connect to Ollama"
    assert "$output" contains "Is it running?"
}

@test "Handles empty response with jq" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock empty response
    local mock_response='{}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "test query"
    assert $state equals 1
    assert "$output" contains "Unable to parse Ollama response"
}

@test "Handles malformed response without jq" {
    # Mock jq as unavailable
    mock_jq "false"
    
    # Mock malformed response
    local mock_response='{"malformed": "data"}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "test query"
    assert $state equals 1
    assert "$output" contains "Unable to parse response"
    assert "$output" contains "install jq"
}

@test "Uses correct model from config" {
    export ZSH_AI_OLLAMA_MODEL="codellama"
    
    # Mock jq as available
    mock_jq "true"
    
    # Mock successful response
    local mock_response='{"response":"npm test"}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "run tests"
    assert $state equals 0
    assert "$output" equals "npm test"
}

@test "Uses correct URL from config" {
    export ZSH_AI_OLLAMA_URL="http://remote:11434"
    
    # Mock jq as available
    mock_jq "true"
    
    # Mock successful response
    local mock_response='{"response":"ls -la"}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "list files"
    assert $state equals 0
    assert "$output" equals "ls -la"
}

@test "Removes trailing newlines from response" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock response with newlines
    local mock_response='{"response":"cd /home\n\n"}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "go home"
    assert $state equals 0
    assert "$output" equals "cd /home"
}

@test "Escapes quotes in query" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock successful response
    local mock_response='{"response":"echo \"test\""}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama 'print "test"'
    assert $state equals 0
    assert "$output" equals 'echo "test"'
}

@test "Includes context in API call" {
    # Mock jq as available
    mock_jq "true"
    
    # Create a test environment with specific context
    touch Dockerfile
    
    # Mock successful response
    local mock_response='{"response":"docker build ."}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "build docker image"
    assert $state equals 0
    assert "$output" equals "docker build ."
}

@test "Sets correct temperature option" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock successful response
    local mock_response='{"response":"python script.py"}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_ollama "run python script"
    assert $state equals 0
    assert "$output" equals "python script.py"
}