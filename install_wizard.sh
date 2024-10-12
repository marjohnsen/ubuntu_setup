#!/bin/bash

source ./src/select_wizard.sh
source ./src/dependency_wizard.sh
source ./src/install_apps.sh

APPS=()
select_wizard APPS

if [[ "${#APPS[@]}" -eq 0 ]]; then
  echo "No applications were selected. Exiting..."
  exit 1
fi

dependency_wizard APPS

install_apps "${APPS[@]}"
