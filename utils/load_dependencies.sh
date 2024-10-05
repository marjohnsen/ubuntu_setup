#!/bin/bash

load_dependencies() {
    local APP_SCRIPT="$1"
    source "$APP_SCRIPT"
    echo "${dependencies[*]}"
}

