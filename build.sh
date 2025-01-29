#!/bin/bash

function echo_and_exit {
  echo "$1"
  exit 1
}


# check if we are in the expected directory
if [ ! -d assets/parts ]; then
  echo_and_exit "Not running in the expected directory, please run this script from frc_system_diagrams/"
fi


# require the argument "--roboto-is-installed" to be passed, or exit
if [ "$1" != "--roboto-is-installed" ]; then
  echo "Is the Roboto font installed on your system?"
  echo "It is needed to properly render the text in the SVGs."
  echo "Please install it from https://fonts.google.com/specimen/Roboto"
  echo "You may also simply push to GitHub, where GitHub Actions will run"
  echo "the build for you. Once it completes, simply pull the changes."
  echo "If you have installed the Roboto font, re-run this script as follows:"
  echo
  echo "build.sh --roboto-is-installed"

  exit 1
fi


mkdir -p output


function calculate_build_hash {
  find assets src output -type f -exec md5sum {} \; | sort | md5sum | cut -d ' ' -f 1
}

# check if CURRENT_HASH matches the contents of last_build_hash, stripping any newlines
CURRENT_HASH=$(calculate_build_hash)
if [ -f last_build_hash.txt ]; then
  LAST_HASH=$(tr -d '\n' < last_build_hash.txt)
  if [ "$CURRENT_HASH" == "$LAST_HASH" ]; then
    echo "No changes detected, skipping build"
    exit 0
  fi
fi


# check if inkscape (which we use to convert text to paths) is installed
echo "Checking for inkscape"
if ! command -v inkscape &> /dev/null
then
  echo "Inkscape could not be found. We need it to convert text to paths in the SVGs."
  echo "This step cannot be skipped, because they will render incorrectly on the website."
  echo "Please install inkscape and try again, or simply push to GitHub."
  echo "GitHub Actions will run the build for you. Once it completes, simply pull the changes."
  exit 1
fi


# check if svgo (a program to optimize svg files) is installed
echo "Checking for svgo"
USE_SVGO=1
if ! command -v svgo &> /dev/null
then
  echo "svgo could not be found, checking for npm"
  if ! command -v npm &> /dev/null
  then
    echo "npm could not be found, will not optimize svgs"
    USE_SVGO=0
  else
    echo "npm found, installing svgo"
    USE_SVGO=$( (npm install -g svgo && echo 1) || echo 0 )
    if [ "$USE_SVGO" -eq 0 ]; then
      echo "Failed to install svgo, will not optimize svgs"
    else
      echo "svgo installed"
    fi
  fi
fi


# create a virtual environment and install python dependencies
if [ -d .venv ]; then
  echo "Virtual environment already exists"
else
  echo "Creating virtual environment"
  python3 -m venv .venv
fi
source .venv/bin/activate

echo "Installing python dependencies"
pip install -r requirements.txt


echo "Building system diagrams"
rm -rf output/*
python3 src/assembler.py || echo_and_exit "Failed to build system diagrams"

echo "> Converting text to paths"
pushd output >/dev/null || echo_and_exit "Failed to change directory to output"

# run inkscape to convert each file
find . -name "*.svg" | while read -r file; do
  inkscape --export-text-to-path --export-plain-svg --vacuum-defs --export-filename="$file" "$file" || echo_and_exit "Failed to convert text to paths in $file"
done

# check if we should use svgo
if [ "$USE_SVGO" -eq 1 ]; then
  echo "> Optimizing SVGs"
  svgo -f . || echo_and_exit "Failed to optimize SVGs"
else
  echo "> Skipping optimization of SVGs"
fi

popd >/dev/null || echo_and_exit "Failed to change directory to project root"


# re-calculate the build hash and save it to last_build_hash.txt
calculate_build_hash > last_build_hash.txt


echo "Done building, system diagrams are available in output/"
echo "Please remember to commit and push your changes."