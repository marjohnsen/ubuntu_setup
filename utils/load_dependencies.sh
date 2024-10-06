#!/bin/bash

load_dependencies() {
    local APP_SCRIPT="$1"
    local dependencies=()
    source "$APP_SCRIPT"
    echo "${dependencies[*]}"
}

