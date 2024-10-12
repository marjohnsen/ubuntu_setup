#!/bin/bash

# Load dependencies from the app script
load_dependencies() {
  local second_line
  second_line=$(sed -n '2p' "$1")
  [[ $(basename "$1" .sh) == "packages" ]] && echo "" || echo "packages ${second_line:2}"
}

# Recursively resolve dependencies for a given app
resolve_app() {
  local app="$1"
  local resolved_apps=("${!2}")   # Copy the resolved apps array
  local processing_apps=("${!3}") # Copy the processing apps array

  if [[ " ${processing_apps[*]} " =~ $app ]]; then
    echo "Error: Circular dependency for $app" >&2
    exit 1
  fi

  if [[ " ${resolved_apps[*]} " =~ $app ]]; then
    echo "${resolved_apps[@]}"
    return
  fi

  processing_apps+=("$app")

  local dep_array
  IFS=' ' read -r -a dep_array <<<"$(load_dependencies "./apps/$app.sh")"
  for dep in "${dep_array[@]}"; do
    read -r -a resolved_apps <<<"$(resolve_app "$dep" resolved_apps[@] processing_apps[@])"
  done
  resolved_apps+=("$app")

  echo "${resolved_apps[@]}"
}

# Resolve dependencies for selected apps
resolve_dependencies() {
  local selected_apps=("${@}")
  local resolved_apps=() processing_apps=()

  for app in "${selected_apps[@]}"; do
    read -r -a resolved_apps <<<"$(resolve_app "$app" resolved_apps[@] processing_apps[@])"
  done
  echo "${resolved_apps[@]}"
}

# Find missing dependencies that aren't in selected apps
find_missing_dependencies() {
  local selected_apps=("${!1}")
  local resolved_apps=("${!2}")
  local missing_deps=()

  for app in "${resolved_apps[@]}"; do
    [[ ! " ${selected_apps[*]} " =~ " $app " ]] && missing_deps+=("$app")
  done
  echo "${missing_deps[@]}"
}

# Prompt user to handle missing dependencies
prompt_for_missing_dependencies() {
  local resolved_apps=("${!1}")
  local selected_apps=("${!2}")
  local missing_deps=("${!3}")

  [[ ${#missing_deps[@]} -eq 0 ]] && echo "Final installation order: ${resolved_apps[*]}" && return 0

  echo -e "\nThe following dependencies are required but were not explicitly selected:"
  for dep in "${missing_deps[@]}"; do echo "- $dep"; done

  while true; do
    echo -e "\nY) Add missing dependencies and install\nN) Install selected apps only\nA) Abort"
    read -r -p "Choice: " choice
    case "$choice" in
    y | Y) return 0 ;;
    n | N) return 1 ;;
    a | A) echo "Aborting." && exit 1 ;;
    *) echo "Invalid choice. Please enter Y, N, or A." ;;
    esac
  done
}

dependency_wizard() {
  local -n selected_apps_ref=$1

  local selected_apps=("${selected_apps_ref[@]}")
  local resolved_apps=()
  local missing_deps=()

  read -r -a resolved_apps <<<"$(resolve_dependencies "${selected_apps[@]}")"

  read -r -a missing_deps <<<"$(find_missing_dependencies selected_apps[@] resolved_apps[@])"

  if prompt_for_missing_dependencies resolved_apps[@] selected_apps[@] missing_deps[@]; then
    selected_apps_ref=("${resolved_apps[@]}")
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  SELECTED_APPS=("$@")
  dependency_wizard SELECTED_APPS
fi
