#!/usr/bin/env bash

get() {
    local key="$1"
    git config --global --get "$key" 
}
set_force() {
    local key="$1"
    local value="$2"
    if [ -z "$(get "$key" 2>/dev/null)" ]; then
    	echo "Setting $key = $value"
    else
        echo "Overwriting $key = $value (was: $(get "$key"))"
    fi
    git config --global "$key" "$value"
}
set_if_unset() {
    local key="$1"
    local value="$2"
    if [ -z "$(git config --global --get "$key" 2>/dev/null)" ]; then
        git config --global "$key" "$value"
        echo "Set $key = $value"
    else
        echo "Skipped $key (already set to: $(git config --global --get "$key"))"
    fi
}

# Set user
. ./user.env
set_if_unset user.email $USER_EMAIL
set_if_unset user.name $USER_FULL_NAME

# Disable warning about line-endings
set_force core.autocrlf false

# Auto rebase on pull
set_force pull.rebase true

# Credential manager
set_force credential.helper store
