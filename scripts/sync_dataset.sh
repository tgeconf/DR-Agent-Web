#!/usr/bin/env bash
set -euo pipefail

SOURCE_BASE="${SOURCE_DATASET_DIR:-/Users/tongge/Documents/GitHub/DR-Agent/dataset}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_BASE="${REPO_ROOT}/dataset"

echo "Syncing dataset directories from ${SOURCE_BASE} to ${TARGET_BASE}"

shopt -s nullglob
date_dirs=("${SOURCE_BASE}"/[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9])
if [[ ${#date_dirs[@]} -eq 0 ]]; then
  echo "No date-formatted directories found in ${SOURCE_BASE}"
else
  mkdir -p "${TARGET_BASE}"
  for src_dir in "${date_dirs[@]}"; do
    base_name="$(basename "${src_dir}")"
    dest_dir="${TARGET_BASE}/${base_name}"
    echo "Copying ${base_name}"
    rm -rf "${dest_dir}"
    cp -a "${src_dir}" "${dest_dir}"
  done
fi
shopt -u nullglob

pushd "${REPO_ROOT}/web" > /dev/null
npm run export:data
popd > /dev/null

cd "${REPO_ROOT}"
if [[ -n "$(git status --porcelain)" ]]; then
  git add dataset web
  git commit -m "chore: sync dataset export"
  git push
else
  echo "No changes to commit."
fi
