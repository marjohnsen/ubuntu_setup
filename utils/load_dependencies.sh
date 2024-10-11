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
