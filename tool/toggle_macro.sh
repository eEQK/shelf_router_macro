#!/bin/bash

# sed command is different on macOS and Linux
sed_cmd=""
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed_cmd="sed -i '' -e"
else
  sed_cmd="sed -i"
fi


toggle_macro() {
  local action="$1"
  case "$action" in
    "on")
      find lib/ -type f -name "*.dart" -exec $sed_cmd -e 's/\/\*macro\*\/ class/macro class/g' {} \;
      ;;
    "off")
      find lib/ -type f -name "*.dart" -exec $sed_cmd -e 's/macro class/\/\*macro\*\/ class/g' {} \;
      ;;
    *)
      echo "Invalid argument. Usage: $0 (on|off)"
      exit 1
      ;;
  esac
}

if [[ $# -eq 0 ]]; then
  echo "Switch between macros enabled and disabled"
  echo "by (un)commenting 'macro' in library files."
  echo ""
  echo "This is a workaround for slow LSP analysis"
  echo "of libraries with macros during development."
  echo ""
  echo "Missing argument. Usage: $0 (on|off)"
  exit 1
fi

toggle_macro "$1"
