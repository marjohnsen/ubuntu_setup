#!/bin/bash

load_dependencies() {
  local app_script="$1"
  local app_name
  app_name=$(basename "$app_script" .sh)

  [[ $app_name == "packages" ]] && echo "" && return

  local second_line
  second_line=$(sed -n '2p' "$app_script")
  local dependencies="packages"

  if [[ $second_line =~ ^//.* ]]; then
    local additional_deps="${second_line:2}"
    if [[ -z $additional_deps ]]; then
      echo "Error: Dependencies indicated by '//' in $app_script, but none were specified." >&2
      exit 1
    fi
    dependencies="$dependencies $additional_deps"
  fi

  echo "$dependencies"
}

resolve_app() {
  local app="$1"
  local resolved_apps=("${!2}")
  local processing_apps=("${!3}")

  if [[ " ${processing_apps[*]} " =~ $app ]]; then
    echo "Error: Circular dependency detected for $app" >&2
    exit 1
  fi

  if [[ " ${resolved_apps[*]} " =~ $app ]]; then
    echo "${resolved_apps[@]}"
    return
  fi

  processing_apps+=("$app")

  local dependencies
  dependencies=$(load_dependencies "$APPS_DIR/$app.sh")

  read -r -a dep_array <<<"$dependencies"
  for dep in "${dep_array[@]}"; do
    read -r -a resolved_apps <<<"$(resolve_app "$dep" resolved_apps[@] processing_apps[@])"
  done

  resolved_apps+=("$app")

  echo "${resolved_apps[@]}"
}

resolve_dependencies() {
  local selected_apps=("$@")
  local resolved_apps=()
  local processing_apps=()

  for app in "${selected_apps[@]}"; do
    read -r -a resolved_apps <<<"$(resolve_app "$app" resolved_apps[@] processing_apps[@])"
  done

  echo "${resolved_apps[@]}"
}

wizard() {
  local selected_apps=("$@")
  local resolved_apps=()
  local missing_deps=()

  for app in "${selected_apps[@]}"; do
    read -r -a resolved_apps <<<"$(resolve_app "$app" resolved_apps[@] missing_deps[@])"
  done

  for app in "${resolved_apps[@]}"; do
    if [[ ! " ${selected_apps[*]} " =~ $app ]]; then
      read -r -a dep_array <<<"$app"
      for dep in "${dep_array[@]}"; do
        missing_deps+=("$dep")
      done
    fi
  done

  for app in "${selected_apps[@]}"; do
    missing_deps=("${missing_deps[@]/$app/}")
  done

  if [[ ${#missing_deps[@]} -eq 0 ]]; then
    echo "Final installation order: ${resolved_apps[*]}"
    return
  fi

  echo "The following dependencies are required but were not explicitly selected: "
  for dep in "${missing_deps[@]}"; do
    echo "- $dep"
  done

  while true; do
    read -r -p "Y) Add missing dependencies and install
N) Install selected apps only (without dependencies)
A) Abort
Choice: " choice

    case "$choice" in
    y | Y)
      echo "Final installation order: ${resolved_apps[*]}"
      return
      ;;
    n | N)
      echo "Final installation order: ${selected_apps[*]}"
      return
      ;;
    a | A)
      echo "Aborting."
      exit 1
      ;;
    *)
      echo "Invalid choice. Please enter Y, N, or A."
      ;;
    esac
  done
}

APPS_DIR="./apps"
selected_apps=("neovim" "zsh")

wizard "${selected_apps[@]}"
