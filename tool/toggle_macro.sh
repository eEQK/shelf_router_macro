#!/bin/bash

toggle_macro() {
  local action="$1"
  case "$action" in
    "on")
      find lib/ -type f -exec sed -i 's/\/\*macro\*\/ class/macro class/g' {} \;
      ;;
    "off")
      find lib/ -type f -exec sed -i 's/macro class/\/\*macro\*\/ class/g' {} \;
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
