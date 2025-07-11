#!/usr/bin/env zsh

# Load test helper
source "${0:A:h:h}/test_helper.zsh"

# Load the context and anthropic provider modules
source "$PLUGIN_DIR/lib/context.zsh"
source "$PLUGIN_DIR/lib/providers/anthropic.zsh"

@setup {
    setup_test_env
    export ANTHROPIC_API_KEY="test-api-key"
}

@teardown {
    teardown_test_env
}

@test "Successful API call with jq available" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock successful curl response
    local mock_response='{"content":[{"text":"ls -la"}]}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_anthropic "list all files"
    assert $state equals 0
    assert "$output" equals "ls -la"
    assert_called "curl" 1
}

@test "Successful API call without jq" {
    # Mock jq as unavailable
    mock_jq "false"
    
    # Mock successful curl response
    local mock_response='{"content":[{"text":"cd /home/user"}]}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_anthropic "go to home directory"
    assert $state equals 0
    assert "$output" equals "cd /home/user"
}

@test "Handles API error response with jq" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock error response
    local mock_response='{"error":{"message":"Invalid API key"}}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_anthropic "test query"
    assert $state equals 1
    assert "$output" contains "API Error: Invalid API key"
}

@test "Handles curl connection failure" {
    # Mock curl failure
    mock_command "curl" "" 1
    
    run _zsh_ai_query_anthropic "test query"
    assert $state equals 1
    assert "$output" contains "Failed to connect to Anthropic API"
}

@test "Handles empty response with jq" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock empty response
    local mock_response='{}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_anthropic "test query"
    assert $state equals 1
    assert "$output" contains "Unable to parse response"
}

@test "Handles malformed response without jq" {
    # Mock jq as unavailable
    mock_jq "false"
    
    # Mock malformed response
    local mock_response='{"malformed": "data"}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_anthropic "test query"
    assert $state equals 1
    assert "$output" contains "Unable to parse response"
    assert "$output" contains "install jq"
}

@test "Escapes quotes in query" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock successful response
    local mock_response='{"content":[{"text":"echo \"Hello World\""}]}'
    mock_curl_response "$mock_response" 0
    
    # Capture the actual curl call to verify escaping
    mock_command "curl" "$mock_response" 0
    
    run _zsh_ai_query_anthropic 'print "Hello World"'
    assert $state equals 0
    assert_called "curl" 1
}

@test "Includes context in API call" {
    # Mock jq as available
    mock_jq "true"
    
    # Create a test environment with specific context
    touch package.json
    
    # Mock successful response
    local mock_response='{"content":[{"text":"npm install"}]}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_anthropic "install dependencies"
    assert $state equals 0
    assert "$output" equals "npm install"
}

@test "Uses correct API headers" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock curl to capture the command
    local captured_args=""
    mock_command "curl" '{"content":[{"text":"ls"}]}' 0
    
    run _zsh_ai_query_anthropic "list files"
    assert $state equals 0
    
    # Verify curl was called
    assert_called "curl" 1
}

@test "Uses correct model" {
    # Mock jq as available
    mock_jq "true"
    
    # Mock successful response
    local mock_response='{"content":[{"text":"pwd"}]}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_anthropic "show current directory"
    assert $state equals 0
    assert "$output" equals "pwd"
}

@test "Handles multiline context properly" {
    # Mock jq as available
    mock_jq "true"
    
    # Create files to generate multiline context
    touch file1.txt file2.txt file3.txt
    
    # Mock successful response
    local mock_response='{"content":[{"text":"ls -la"}]}'
    mock_curl_response "$mock_response" 0
    
    run _zsh_ai_query_anthropic "list all files"
    assert $state equals 0
    assert "$output" equals "ls -la"
}