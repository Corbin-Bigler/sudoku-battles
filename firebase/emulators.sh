#!/bin/bash

EXPORT_DIR="./data-emulator"
firebase emulators:start --import "$EXPORT_DIR" --export-on-exit "$EXPORT_DIR"
# --debug