#!/usr/bin/env zsh

# Load test helper
source "${0:A:h}/test_helper.zsh"

# Load the context module
source "$PLUGIN_DIR/lib/context.zsh"

@setup {
    setup_test_env
    TEST_DIR=$(create_test_dir)
    cd "$TEST_DIR"
}

@teardown {
    cd - >/dev/null 2>&1
    cleanup_test_dir "$TEST_DIR"
    teardown_test_env
}

# Project type detection tests

@test "Detects Node.js project" {
    touch package.json
    run _zsh_ai_detect_project_type
    assert "$output" equals "node"
}

@test "Detects Rust project" {
    touch Cargo.toml
    run _zsh_ai_detect_project_type
    assert "$output" equals "rust"
}

@test "Detects Python project with requirements.txt" {
    touch requirements.txt
    run _zsh_ai_detect_project_type
    assert "$output" equals "python"
}

@test "Detects Python project with setup.py" {
    touch setup.py
    run _zsh_ai_detect_project_type
    assert "$output" equals "python"
}

@test "Detects Python project with pyproject.toml" {
    touch pyproject.toml
    run _zsh_ai_detect_project_type
    assert "$output" equals "python"
}

@test "Detects Ruby project" {
    touch Gemfile
    run _zsh_ai_detect_project_type
    assert "$output" equals "ruby"
}

@test "Detects Go project" {
    touch go.mod
    run _zsh_ai_detect_project_type
    assert "$output" equals "go"
}

@test "Detects PHP project" {
    touch composer.json
    run _zsh_ai_detect_project_type
    assert "$output" equals "php"
}

@test "Detects Java project with pom.xml" {
    touch pom.xml
    run _zsh_ai_detect_project_type
    assert "$output" equals "java"
}

@test "Detects Java project with build.gradle" {
    touch build.gradle
    run _zsh_ai_detect_project_type
    assert "$output" equals "java"
}

@test "Detects Docker project with docker-compose.yml" {
    touch docker-compose.yml
    run _zsh_ai_detect_project_type
    assert "$output" equals "docker"
}

@test "Detects Docker project with Dockerfile" {
    touch Dockerfile
    run _zsh_ai_detect_project_type
    assert "$output" equals "docker"
}

@test "Returns unknown for unrecognized project" {
    touch random.txt
    run _zsh_ai_detect_project_type
    assert "$output" equals "unknown"
}

# Git context tests

@test "Returns empty string for non-git directory" {
    run _zsh_ai_get_git_context
    assert "$output" equals ""
}

@test "Gets git context for git repository" {
    git init >/dev/null 2>&1
    git checkout -b test-branch >/dev/null 2>&1
    run _zsh_ai_get_git_context
    assert "$output" contains "Git: branch=test-branch"
    assert "$output" contains "status=clean"
}

@test "Detects dirty git status" {
    git init >/dev/null 2>&1
    touch test.txt
    git add test.txt
    run _zsh_ai_get_git_context
    assert "$output" contains "status=dirty"
}

# Directory context tests

@test "Shows current directory in context" {
    run _zsh_ai_get_directory_context
    assert "$output" contains "Current directory: $TEST_DIR"
}

@test "Lists files when less than 20" {
    touch file1.txt file2.txt file3.txt
    run _zsh_ai_get_directory_context
    assert "$output" contains "Files: file1.txt, file2.txt, file3.txt"
}

@test "Truncates file list at 10 files" {
    for i in {1..15}; do
        touch "file$i.txt"
    done
    run _zsh_ai_get_directory_context
    assert "$output" contains "Files:"
    assert "$output" contains "... and 5 more"
}

@test "Shows file count for directories with many files" {
    for i in {1..25}; do
        touch "file$i.txt"
    done
    run _zsh_ai_get_directory_context
    assert "$output" contains "Files: 25 files in directory"
}

# Context building tests

@test "Builds complete context" {
    touch package.json
    git init >/dev/null 2>&1
    run _zsh_ai_build_context
    assert "$output" contains "Current directory:"
    assert "$output" contains "Project type: node"
    assert "$output" contains "Git:"
    assert "$output" contains "OS:"
}

@test "Builds context without git" {
    touch requirements.txt
    run _zsh_ai_build_context
    assert "$output" contains "Current directory:"
    assert "$output" contains "Project type: python"
    assert "$output" contains "OS:"
    assert ! "$output" contains "Git:"
}

@test "Builds context for unknown project" {
    touch random.txt
    run _zsh_ai_build_context
    assert "$output" contains "Current directory:"
    assert ! "$output" contains "Project type:"
    assert "$output" contains "OS:"
}

@test "Includes OS information" {
    run _zsh_ai_build_context
    local os_name=$(uname -s)
    assert "$output" contains "OS: $os_name"
}