#!/bin/bash

PLUGINS_PATH="$HOME/Library/Application Support/xbar/plugins"
CURRENT_DIR=$(pwd)

cp "${CURRENT_DIR}/gitbar.1m.rb" "${PLUGINS_PATH}/gitbar.1m.rb"
mkdir -p "${PLUGINS_PATH}/gitbar_app"
cp -r "${CURRENT_DIR}/gitbar_app/." "${PLUGINS_PATH}/gitbar_app"
chmod +x "${PLUGINS_PATH}/gitbar.1m.rb"