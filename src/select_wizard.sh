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
      echo -e "\033[1;31m$((i + 1))) ${ref_available_apps[$i]}\033[0m"
    fi
  done

  echo -e "\nSelected apps:"
  for i in "${!ref_available_apps[@]}"; do
    if [[ " ${ref_selected_apps[*]} " =~ ${ref_available_apps[$i]} ]]; then
      echo -e "\033[1;32m$((i + 1))) ${ref_available_apps[$i]}\033[0m"
    fi
  done
}

select_wizard() {
  local -n selected_apps_ref=$1
  local available_apps=()

  mapfile -t available_apps < <(list_apps)

  while true; do
    clear
    display_apps available_apps selected_apps_ref

    echo -e "\ns) \033[1;32mSelect all\033[0m"
    echo -e "d) \033[1;31mDeselect all\033[0m"
    echo -e "c) Continue"
    read -r choice

    case "$choice" in
    [0-9]*)
      local index=$((choice - 1))
      if ((index >= 0 && index < ${#available_apps[@]})); then
        if [[ " ${selected_apps_ref[*]} " =~ ${available_apps[$index]} ]]; then
          deselect_app "${available_apps[$index]}" selected_apps_ref
        else
          select_app "${available_apps[$index]}" selected_apps_ref
        fi
      fi
      ;;
    [Ss])
      for app in "${available_apps[@]}"; do
        select_app "$app" selected_apps_ref
      done
      ;;
    [Dd]) selected_apps_ref=() ;;
    [Cc])
      if [[ ${#selected_apps_ref[@]} -eq 0 ]]; then
        echo -e "\033[1;31mNo applications selected. Exiting...\033[0m"
        return
      else
        break
      fi
      ;;
    esac
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  selected_apps=()
  select_wizard selected_apps
fi
