#!/bin/bash

EXPORT_DIR="./data-emulator"
sudo firebase emulators:start --import "$EXPORT_DIR" --export-on-exit "$EXPORT_DIR"
