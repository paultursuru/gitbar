#!/bin/bash

PLUGINS_PATH="$HOME/Library/Application Support/xbar/plugins"
CURRENT_DIR=$(pwd)

# Ensure the plugins directory exists before copying into it
mkdir -p "${PLUGINS_PATH}"
mkdir -p "${PLUGINS_PATH}/gitbar_app"

# Copy & make it executable
cp -r "${CURRENT_DIR}/gitbar_app/." "${PLUGINS_PATH}/gitbar_app"
chmod +x "${PLUGINS_PATH}/gitbar.1m.rb"
