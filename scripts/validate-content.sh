#!/usr/bin/env bash
set -euo pipefail

check_post() {
    local dir="$1"
    local fr="$dir/index.fr.md"
    local en="$dir/index.en.md"

    if [ ! -f "$fr" ] || [ ! -f "$en" ]; then
        echo "ERROR: $dir is missing a translation"
        [ -f "$fr" ] && echo "  Found: index.fr.md (missing index.en.md)"
        [ -f "$en" ] && echo "  Found: index.en.md (missing index.fr.md)"
        return 1
    fi

    local fr_date=$(grep -m1 '^date\s*=' "$fr" | sed -n 's/.*=\s*\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')
    local en_date=$(grep -m1 '^date\s*=' "$en" | sed -n 's/.*=\s*\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')

    if [ -z "$fr_date" ] || [ -z "$en_date" ]; then
        echo "ERROR: $dir has a missing or unparseable date field"
        [ -z "$fr_date" ] && echo "  index.fr.md: no date found"
        [ -z "$en_date" ] && echo "  index.en.md: no date found"
        return 1
    fi

    if [ "$fr_date" != "$en_date" ]; then
        echo "ERROR: $dir has mismatched dates: fr=$fr_date en=$en_date"
        return 1
    fi

    local dirname=$(basename "$dir")
    if [[ "$dirname" != "$fr_date"* ]]; then
        echo "ERROR: $dir folder name must start with $fr_date (got '$dirname')"
        return 1
    fi

    return 0
}

check_share() {
    local file="$1"
    local basename=$(basename "$file" .md)

    if [[ ! "$basename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}- ]]; then
        echo "ERROR: $file name must start with YYYY-MM-DD- (got '$basename')"
        return 1
    fi

    local file_date="${basename:0:10}"
    local fm_date=$(grep -m1 '^date\s*=' "$file" | sed -n 's/.*=\s*\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')
    if [ -z "$fm_date" ]; then
        echo "ERROR: $file has a missing or unparseable date field"
        return 1
    fi
    if [ "$fm_date" != "$file_date" ]; then
        echo "ERROR: $file date mismatch: filename=$file_date frontmatter=$fm_date"
        return 1
    fi
    if ! grep -q '^link\s*=' "$file"; then
        echo "ERROR: $file is missing the 'link' field"
        return 1
    fi

    return 0
}

errors=0

if [ $# -gt 0 ]; then
    # Pre-commit mode: check only the post dirs / share files referenced by staged changes
    post_dirs=$(printf '%s\n' "$@" | sed -n 's|^\(content/posts/[^/]*\)/.*|\1|p' | sort -u)
    share_files=$(printf '%s\n' "$@" | grep '^content/shares/.*\.md$' | grep -v '_index' | sort -u)

    for dir in $post_dirs; do
        check_post "$dir" || errors=$((errors + 1))
    done
    for file in $share_files; do
        check_share "$file" || errors=$((errors + 1))
    done
else
    # CI mode: check all content
    echo "Validating content..."

    for dir in content/posts/*/; do
        dir="${dir%/}"
        [ -d "$dir" ] || continue
        check_post "$dir" || errors=$((errors + 1))
    done

    for file in content/shares/*.md; do
        [ -f "$file" ] || continue
        [[ "$(basename "$file")" == _index* ]] && continue
        check_share "$file" || errors=$((errors + 1))
    done
fi

if [ "$errors" -gt 0 ]; then
    echo ""
    echo "Validation failed: $errors issue(s)"
    exit 1
fi

echo "All content validates."
