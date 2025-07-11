#!/usr/bin/env zsh

# Test suite for JSON escaping functionality
source "${0:A:h}/../lib/utils.zsh"

# Test helper function
test_json_escape() {
    local test_name="$1"
    local input="$2"
    local expected="$3"
    local result=$(_zsh_ai_escape_json "$input")
    
    if [[ "$result" == "$expected" ]]; then
        echo "✓ $test_name"
    else
        echo "✗ $test_name"
        printf "  Input:    %q\n" "$input"
        printf "  Expected: %q\n" "$expected"
        printf "  Got:      %q\n" "$result"
        return 1
    fi
}

echo "Testing JSON escaping function..."

# Basic escaping tests
test_json_escape "Simple string" "hello world" "hello world"
test_json_escape "Double quotes" 'hello "world"' 'hello \"world\"'
test_json_escape "Backslashes" 'hello\world' 'hello\\world'
test_json_escape "Backslash before quote" 'hello\"world' 'hello\\\"world'

# Control character tests
test_json_escape "Newline" $'hello\nworld' $'hello\\nworld'
test_json_escape "Tab" $'hello\tworld' $'hello\\tworld'
test_json_escape "Carriage return" $'hello\rworld' $'hello\\rworld'
test_json_escape "Backspace" $'hello\bworld' $'hello\\bworld'
test_json_escape "Form feed" $'hello\fworld' $'hello\\fworld'

# Complex combinations
test_json_escape "Multiple escapes" $'line1\n"quoted"\ttab' $'line1\\n\\"quoted\\"\\ttab'
test_json_escape "Path with spaces" '/Users/name/My Documents/file.txt' '/Users/name/My Documents/file.txt'
test_json_escape "JSON in string" '{"key": "value"}' '{\"key\": \"value\"}'

# Edge cases
test_json_escape "Empty string" "" ""
test_json_escape "Only quotes" '"""' '\"\"\"'
test_json_escape "Only backslashes" '\\\\' '\\\\\\\\'
test_json_escape "Mixed control chars" $'start\n\r\t\b\fend' $'start\\n\\r\\t\\b\\fend'

# Test with potential problematic characters from the issue
test_json_escape "Command with port" "kill process on port 3002" "kill process on port 3002"

# Test removal of other control characters
test_json_escape "Null character" $'hello\0world' 'helloworld'
test_json_escape "Bell character" $'hello\aworld' 'helloworld'
test_json_escape "Vertical tab" $'hello\vworld' 'helloworld'

# Real-world scenario from context building
test_json_escape "Directory listing" $'Current directory: /tmp\nFiles: test.txt, data.json' $'Current directory: /tmp\\nFiles: test.txt, data.json'
test_json_escape "Git status" $'Git: branch=main, status=dirty\nOS: Darwin' $'Git: branch=main, status=dirty\\nOS: Darwin'

echo ""
echo "All tests completed!"