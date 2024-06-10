#!/bin/bash
set -euo pipefail

print_color() {
    tput bold || true
    tput setaf "$1" || true
    echo "$2" >&2
    tput sgr0 || true
}

log() {
    print_color 5 "------> $1"
}

die() {
    print_color 1 "$1"
    exit 1
}

if ! git filter-repo --version &>/dev/null; then
    die "Please install git-filter-repo"
fi

if [ "$#" -lt 2 ]; then
    die "Usage: dedeadname <path to config> <git remote url> [--push]"
fi

CONFIG_PATH="$1"
shift

REPO_URL="$1"
shift

DO_PUSH="0"
if [ "$#" -gt 0 ] && [[ "$1" == "--push" ]]; then
    DO_PUSH="1"
    shift
fi

WORK_DIR="/tmp/dedeadname-$$"
REPO_PATH="$WORK_DIR/repo"
MAILMAP_PATH="$WORK_DIR/mailmap"
REPLACE_TEXT_PATH="$WORK_DIR/text-replace"

mkdir "$WORK_DIR" || die "Failed to create working directory: $WORK_DIR"

# source config
source "$CONFIG_PATH"

# clone repo
log "Cloning $REPO_URL to $REPO_PATH"
git clone "$REPO_URL" "$REPO_PATH"

# set working dir to repo
cd "$REPO_PATH"

# set up mailmap
for email in "${OLD_EMAILS[@]}"; do
    echo "$NEW_NAME <$NEW_EMAIL> <$email>" >> "$MAILMAP_PATH"
done

# set up text replacements
for email in "${OLD_EMAILS[@]}"; do
    echo "literal:$email==>$NEW_EMAIL" >> "$REPLACE_TEXT_PATH"
done

for username in "${OLD_USERNAMES[@]}"; do
    echo "literal:$username==>$NEW_USERNAME" >> "$REPLACE_TEXT_PATH"
done

for replace in "${REPLACE_PATTERNS[@]}"; do
    echo "literal:$replace" >> "$REPLACE_TEXT_PATH"
done

replace_text_args=()
for pattern in "${REPLACE_FILES[@]}"; do
    replace_text_args+=("--path-glob" "$pattern")
done

# rewrite git history
log "Rewriting user info"
git filter-repo --mailmap "$MAILMAP_PATH"

if [ "${#replace_text_args[@]}" -gt 0 ]; then
    log "Rewriting files"
    git filter-repo "${replace_text_args[@]}" --replace-text "$REPLACE_TEXT_PATH"
fi

# push
if [[ "$DO_PUSH" == "1" ]]; then
    log "Force pushing"
    git remote add origin "$REPO_URL"
    git push --force --all
else
    log "Not pushing, re-run with --push at end of argument list to force push"
fi
