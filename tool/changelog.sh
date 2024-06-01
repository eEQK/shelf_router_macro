#!/bin/bash

auto-changelog -V > /dev/null || npm install -g auto-changelog
latest_version=$(awk '/version/ { print $2 }' pubspec.yaml)

changelog() {
  local action="$1"
  local cmd="auto-changelog -v $latest_version"
  case "$action" in
    "amend")
      read -p "This will amend last commit. Are you sure? [y/n]: " -n 1 -r
      echo 
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        $cmd
        git add CHANGELOG.md
        git commit --amend --no-edit

        git tag -d $latest_version
        git tag $latest_version
      else
        exit 0
      fi
      ;;
    "generate")
      $cmd
      ;;
    *)
      echo "Invalid argument. Usage: $0 (amend|generate)"
      exit 1
      ;;
  esac

}

if [[ $# -eq 0 ]]; then
  echo "Generate project changelog"
  echo ""
  echo "Missing argument. Usage: $0 (amend|generate)"
  echo ""
  echo "Commands:"
  echo "       amend:  Set last commit as a new release. "
  echo "               Will amend sync changelog, amend last commit and add new tag"
  echo "               with version from pubspec.yaml."
  echo "    generate:  Sync changelog only"
  echo "               Will mark commits so far as a new release in the changelog"
  echo "               but will not modify git history or tags in any way."
  echo ""
  exit 1
fi

changelog "$@"

