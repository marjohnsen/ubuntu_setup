#!/bin/bash

APPS_DIR="./apps"
PRIORITY_FILE="install_priority.txt"
mapfile -t PRIORITY_APPS < "$PRIORITY_FILE"

run_app() {
    local APP_SCRIPT="$1"
    local APP_NAME=$(basename "$APP_SCRIPT" .sh)

    echo "Installing $APP_NAME..."

    if bash "$APP_SCRIPT"; then
        echo "$APP_NAME was installed successfully."
    else
        echo "$APP_NAME installation failed."
        exit 1
    fi

    echo
}

run_all_apps() {
    for APP_NAME in "${PRIORITY_APPS[@]}"; do
        APP_SCRIPT="$APPS_DIR/$APP_NAME.sh"
        [[ -f "$APP_SCRIPT" ]] && run_app "$APP_SCRIPT" || echo "Warning: Priority app script '$APP_SCRIPT' not found."
    done

    for APP_SCRIPT in "$APPS_DIR"/*.sh; do
        APP_NAME=$(basename "$APP_SCRIPT" .sh)
        [[ " ${PRIORITY_APPS[*]} " == *" $APP_NAME "* ]] && continue
        run_app "$APP_SCRIPT"
    done
}

run_all_apps

