#!/bin/bash

APPS_DIR="./apps"
UTILS_DIR="./utils"
INSTALLED_APPS=()

source "$UTILS_DIR/load_dependencies.sh"

build_dependency_chain() {
    local APP_SCRIPT="$1"
    local APP_NAME=$(basename "$APP_SCRIPT" .sh)
    local DEPENDENCIES=$(load_dependencies "$APP_SCRIPT")
    local ORDER=()

    [[ " ${INSTALLED_APPS[*]} " == *" $APP_NAME "* ]] && echo "${INSTALLED_APPS[@]}" && return

    for DEP in $DEPENDENCIES; do
        DEP_SCRIPT="$APPS_DIR/$DEP.sh"
        [[ -f "$DEP_SCRIPT" ]] || { echo "Warning: $DEP not found"; continue; }
        ORDER+=($(build_dependency_chain "$DEP_SCRIPT"))
    done

    ORDER+=("$APP_NAME")
    INSTALLED_APPS+=("$APP_NAME")
    echo "${ORDER[@]}"
}

install_app() {
    local APP_SCRIPT="$1"
    local APP_NAME=$(basename "$APP_SCRIPT" .sh)
    echo "Installing $APP_NAME..."
    bash "$APP_SCRIPT" || { echo "$APP_NAME installation failed." && exit 1; }
}

generate_installation_order() {
    local RESOLVED_ORDER=()
    for APP_SCRIPT in "$APPS_DIR"/*.sh; do
        RESOLVED_ORDER+=($(build_dependency_chain "$APP_SCRIPT"))
    done
    echo "${RESOLVED_ORDER[@]}" | tr ' ' '\n' | awk '!seen[$0]++'
}

main() {
    local RESOLVED_ORDER=($(generate_installation_order))
    for APP_NAME in "${RESOLVED_ORDER[@]}"; do
        APP_SCRIPT="$APPS_DIR/$APP_NAME.sh"
        install_app "$APP_SCRIPT"
    done
}

main

