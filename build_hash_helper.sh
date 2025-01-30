#!/bin/bash

function _sorted_files {
  find assets src output -type f ! -path '*/__pycache__/*' -exec md5sum {} \; | sort
}

function calculate_build_hash {
  _sorted_files | md5sum | cut -d ' ' -f 1
}

function needs_build {
  if [ -f last_build_hash.txt ]; then
    LAST_BUILD_HASH=$(tr -d '\n' < last_build_hash.txt)
    CURRENT_BUILD_HASH=$(calculate_build_hash)
    echo "Last build hash:    $LAST_BUILD_HASH" >&2
    echo "Current build hash: $CURRENT_BUILD_HASH" >&2

    if [ "$#" -eq 1 ] && [ "$1" == "--debug" ]; then
      echo "Files:" >&2
      _sorted_files >&2
    fi

    if [ "$LAST_BUILD_HASH" == "$CURRENT_BUILD_HASH" ]; then
      echo "skip"
    fi
  fi
}

if [ "$1" == "--do-check" ]; then
  needs_build --debug
fi