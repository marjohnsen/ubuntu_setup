#!/bin/bash

set -euo pipefail

APPS_DIR="./apps"
UTILS_DIR="./utils"

# shellcheck source=./utils/load_dependencies.sh
source "$UTILS_DIR/load_dependencies.sh"

list_apps() {
  for app in "$APPS_DIR"/*.sh; do
    basename "$app" .sh
  done
}

select_app() {
  local app="$1"
  if [[ ! ${SELECTED_APPS[*]} =~ $app ]]; then # Removed quotes to allow regex matching
    SELECTED_APPS+=("$app")
  fi
}

deselect_app() {
  local app="$1"
  for i in "${!SELECTED_APPS[@]}"; do
    if [[ "${SELECTED_APPS[$i]}" == "$app" ]]; then
      unset 'SELECTED_APPS[i]'
      break
    fi
  done
  # Rebuild the array to remove gaps
  SELECTED_APPS=("${SELECTED_APPS[@]}")
}

display_available_apps() {
  echo "Available apps:"
  for i in "${!available_apps[@]}"; do
    [[ ! ${SELECTED_APPS[*]} =~ ${available_apps[$i]} ]] && echo "$((i + 1))) ${available_apps[$i]}"
  done
}

display_selected_apps() {
  echo -e "\nSelected apps:"
  for i in "${!available_apps[@]}"; do
    [[ ${SELECTED_APPS[*]} =~ ${available_apps[$i]} ]] && echo "$((i + 1))) ${available_apps[$i]}"
  done
}

wizard() {
  # Use readarray/mapfile for better handling of spaces in filenames
  mapfile -t available_apps < <(list_apps)

  while true; do
    clear
    display_available_apps
    display_selected_apps

    echo -e "\ns) Select all"
    echo "d) Deselect all"
    echo "c) Continue"
    read -r choice

    case "${choice,,}" in
    [0-9]*)
      local index=$((choice - 1))
      if [[ $index -ge 0 && $index -lt ${#available_apps[@]} ]]; then
        if [[ ${SELECTED_APPS[*]} =~ ${available_apps[$index]} ]]; then
          deselect_app "${available_apps[$index]}"
        else
          select_app "${available_apps[$index]}"
        fi
      fi
      ;;
    s)
      for app in "${available_apps[@]}"; do
        select_app "$app"
      done
      ;;
    d)
      SELECTED_APPS=()
      ;;
    c)
      return 0
      ;;
    *)
      echo "Invalid option."
      ;;
    esac
  done
}

dependencies_prompt() {
  local deps=("$@")
  echo "The selected apps require the following dependencies to be installed:" >&2
  echo "${deps[*]}" >&2
  echo "" >&2
  while true; do
    read -r -p "Y) Add dependencies and install
N) Do not add dependencies and install
A) Abort
Choice: " choice
    case "${choice,,}" in # Handle both upper and lowercase input
    y)
      SELECTED_APPS+=("${deps[@]}")
      break
      ;;
    n)
      break
      ;;
    a)
      echo "Aborting." >&2
      exit 1
      ;;
    *)
      echo "Invalid choice. Please enter Y, N, or A." >&2
      ;;
    esac
  done
}

build_dependency_chain() {
  local APP_SCRIPT="$1"
  local APP_NAME
  APP_NAME=$(basename "$APP_SCRIPT" .sh)
  local DEPENDENCIES
  DEPENDENCIES=$(load_dependencies "$APP_SCRIPT")

  if [[ ${RESOLVED_APPS[*]} =~ $APP_NAME ]]; then # Removed quotes
    return
  fi

  for DEP in $DEPENDENCIES; do
    local DEP_SCRIPT="$APPS_DIR/$DEP.sh"
    if [[ ! -f "$DEP_SCRIPT" ]]; then
      echo "Dependency script $DEP_SCRIPT not found!" >&2
      exit 1
    fi
    build_dependency_chain "$DEP_SCRIPT"
  done

  RESOLVED_APPS+=("$APP_NAME")
}

generate_installation_order() {
  local APPS_TO_INSTALL=("$@")
  RESOLVED_APPS=()
  for APP_NAME in "${APPS_TO_INSTALL[@]}"; do
    build_dependency_chain "$APPS_DIR/$APP_NAME.sh"
  done
  printf "%s\n" "${RESOLVED_APPS[@]}" | awk '!seen[$0]++'
}

resolve_dependencies() {
  local resolved_order
  mapfile -t resolved_order < <(generate_installation_order "${SELECTED_APPS[@]}") # Use mapfile for safer array handling

  local missing_deps=()
  for app in "${resolved_order[@]}"; do
    if [[ ! ${SELECTED_APPS[*]} =~ $app ]]; then # Removed quotes
      missing_deps+=("$app")
    fi
  done

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    dependencies_prompt "${missing_deps[@]}"
  fi

  mapfile -t final_order < <(generate_installation_order "${SELECTED_APPS[@]}") # Use mapfile for safer array handling
  echo "${final_order[@]}"
}

main() {
  wizard
  local final_order
  mapfile -t final_order < <(resolve_dependencies) # Use mapfile for safer array handling
  echo "Final order: ${final_order[*]}"
}

main
