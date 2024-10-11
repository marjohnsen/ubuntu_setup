#!/bin/bash

list_apps() {
  local apps=()
  for app in ./apps/*.sh; do
    apps+=("$(basename "$app" .sh)")
  done
  printf "%s\n" "${apps[@]}"
}

select_app() {
  local app="$1"
  local -n ref_selected_apps="$2"
  if [[ ! " ${ref_selected_apps[*]} " =~ $app ]]; then
    ref_selected_apps+=("$app")
  fi
}

deselect_app() {
  local app="$1"
  local -n ref_selected_apps="$2"
  for i in "${!ref_selected_apps[@]}"; do
    if [[ "${ref_selected_apps[$i]}" == "$app" ]]; then
      unset 'ref_selected_apps[i]'
      break
    fi
  done
  ref_selected_apps=("${ref_selected_apps[@]}")
}

display_apps() {
  local -n ref_available_apps="$1"
  local -n ref_selected_apps="$2"

  echo "Available apps:"
  for i in "${!ref_available_apps[@]}"; do
    if [[ ! " ${ref_selected_apps[*]} " =~ ${ref_available_apps[$i]} ]]; then
      echo "$((i + 1))) ${ref_available_apps[$i]}"
    fi
  done

  echo -e "\nSelected apps:"
  for i in "${!ref_available_apps[@]}"; do
    if [[ " ${ref_selected_apps[*]} " =~ ${ref_available_apps[$i]} ]]; then
      echo "$((i + 1))) ${ref_available_apps[$i]}"
    fi
  done
}

wizard() {
  local available_apps=()
  local selected_apps=()

  mapfile -t available_apps < <(list_apps)

  while true; do
    clear
    display_apps available_apps selected_apps

    echo -e "\ns) Select all"
    echo "d) Deselect all"
    echo "c) Continue"
    read -r choice

    case "$choice" in
    [0-9]*)
      local index=$((choice - 1))
      if ((index >= 0 && index < ${#available_apps[@]})); then
        if [[ " ${selected_apps[*]} " =~ ${available_apps[$index]} ]]; then
          deselect_app "${available_apps[$index]}" selected_apps
        else
          select_app "${available_apps[$index]}" selected_apps
        fi
      fi
      ;;
    [Ss])
      for app in "${available_apps[@]}"; do
        select_app "$app" selected_apps
      done
      ;;
    [Dd]) selected_apps=() ;;
    [Cc]) break ;;
    esac
  done

  echo "Selected apps: ${selected_apps[*]}"
}

wizard
