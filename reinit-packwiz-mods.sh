#!/usr/bin/env bash

for f in "$(dirname $0)"/packwiz/mods/*.pw.toml; do
  name="$(toml get --raw "$f" name)"
  packwiz --yes modrinth install "$name"
done
