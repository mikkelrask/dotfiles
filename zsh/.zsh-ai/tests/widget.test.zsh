#!/usr/bin/env zsh

# Load test helper
source "${0:A:h}/test_helper.zsh"

# Load required modules
source "$PLUGIN_DIR/lib/config.zsh"
source "$PLUGIN_DIR/lib/context.zsh"
source "$PLUGIN_DIR/lib/utils.zsh"
source "$PLUGIN_DIR/lib/widget.zsh"

# Mock ZLE functions
mock_zle() {
    # Mock zle functions
    zle() {
        case "$1" in
            "-N")
                # Widget creation
                MOCKED_WIDGETS["$2"]="$3"
                ;;
            ".accept-line")
                # Normal accept-line
                ACCEPT_LINE_CALLED=1
                ;;
            "redisplay"|"-R")
                # Display update
                REDISPLAY_COUNT=$((REDISPLAY_COUNT + 1))
                ;;
            "reset-prompt")
                # Prompt reset
                RESET_PROMPT_CALLED=1
                ;;
        esac
    }
}

@setup {
    setup_test_env
    export ZSH_AI_PROVIDER="anthropic"
    export ANTHROPIC_API_KEY="test-key"
    
    # Initialize test variables
    typeset -gA MOCKED_WIDGETS
    ACCEPT_LINE_CALLED=0
    REDISPLAY_COUNT=0
    RESET_PROMPT_CALLED=0
    
    # Mock ZLE
    mock_zle
    
    # Mock sleep to speed up tests
    mock_command "sleep" "" 0
}

@teardown {
    teardown_test_env
    unset MOCKED_WIDGETS
    unset ACCEPT_LINE_CALLED
    unset REDISPLAY_COUNT
    unset RESET_PROMPT_CALLED
}

@test "Widget initialization creates accept-line widget" {
    run _zsh_ai_init_widget
    assert $state equals 0
    assert "${MOCKED_WIDGETS[accept-line]}" equals "_zsh_ai_accept_line"
}

@test "Normal commands execute without AI processing" {
    BUFFER="ls -la"
    run _zsh_ai_accept_line
    assert $ACCEPT_LINE_CALLED equals 1
}

@test "Multiline AI commands execute without processing" {
    BUFFER="# list files
and show details"
    run _zsh_ai_accept_line
    assert $ACCEPT_LINE_CALLED equals 1
}

@test "AI commands starting with # are processed" {
    # Mock the query function
    _zsh_ai_query() {
        echo "ls -la"
    }
    
    # Mock kill to simulate process completion
    mock_command "kill" "" 1
    
    BUFFER="# list all files"
    CURSOR=0
    
    run _zsh_ai_accept_line
    
    # Buffer should be replaced with command
    assert "$BUFFER" equals "ls -la"
    assert $CURSOR equals 6
    assert $RESET_PROMPT_CALLED equals 1
}

@test "Handles API errors gracefully" {
    # Mock the query function to return error
    _zsh_ai_query() {
        echo "Error: API connection failed"
    }
    
    # Mock kill to simulate process completion
    mock_command "kill" "" 1
    
    # Mock print to capture output
    local printed_output=""
    print() {
        printed_output="$printed_output$@\n"
    }
    
    BUFFER="# invalid query"
    
    run _zsh_ai_accept_line
    
    # Buffer should be cleared on error
    assert "$BUFFER" equals ""
    assert "$printed_output" contains "Failed to generate command"
    assert "$printed_output" contains "API connection failed"
}

@test "Shows loading animation during API call" {
    # Mock the query function with delay simulation
    _zsh_ai_query() {
        echo "pwd"
    }
    
    # Mock kill to simulate running process then completion
    local kill_count=0
    kill() {
        kill_count=$((kill_count + 1))
        if [[ $kill_count -le 2 ]]; then
            return 0  # Process still running
        else
            return 1  # Process completed
        fi
    }
    
    BUFFER="# show current directory"
    
    run _zsh_ai_accept_line
    
    # Should have animated
    assert $REDISPLAY_COUNT -gt 0
}

@test "Preserves original buffer during animation" {
    # Mock the query function
    _zsh_ai_query() {
        echo "git status"
    }
    
    # Mock kill to simulate process completion
    mock_command "kill" "" 1
    
    local original_buffer="# check git status"
    BUFFER="$original_buffer"
    
    run _zsh_ai_accept_line
    
    # Final buffer should be the command
    assert "$BUFFER" equals "git status"
}

@test "Handles empty API response" {
    # Mock the query function to return empty
    _zsh_ai_query() {
        echo ""
    }
    
    # Mock kill to simulate process completion
    mock_command "kill" "" 1
    
    # Mock print to capture output
    local printed_output=""
    print() {
        printed_output="$printed_output$@\n"
    }
    
    BUFFER="# empty response"
    
    run _zsh_ai_accept_line
    
    # Buffer should be cleared
    assert "$BUFFER" equals ""
    assert "$printed_output" contains "Failed to generate command"
}

@test "Uses temporary file for API response" {
    # Track mktemp calls
    local mktemp_called=0
    local temp_file="/tmp/test.tmp"
    mktemp() {
        mktemp_called=1
        echo "$temp_file"
    }
    
    # Mock cat and rm
    mock_command "cat" "echo 'Hello World'" 0
    mock_command "rm" "" 0
    
    # Mock the query function
    _zsh_ai_query() {
        echo "echo 'Hello World'"
    }
    
    # Mock kill to simulate process completion
    mock_command "kill" "" 1
    
    BUFFER="# say hello"
    
    run _zsh_ai_accept_line
    
    assert $mktemp_called equals 1
    assert_called "rm" 1
}

@test "Handles commands with special characters" {
    # Mock the query function
    _zsh_ai_query() {
        echo "echo \"Hello, World!\""
    }
    
    # Mock kill to simulate process completion
    mock_command "kill" "" 1
    
    BUFFER="# print greeting"
    
    run _zsh_ai_accept_line
    
    assert "$BUFFER" equals "echo \"Hello, World!\""
}