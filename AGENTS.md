# AGENTS.md — geoffreycoulaud.github.io

Hugo blog, bilingual FR/EN, theme [Ed](https://github.com/sergeyklay/gohugo-theme-ed). Deployed to GitHub Pages.

## Setup after clone

```bash
git config core.hooksPath .githooks   # enables pre-commit hook
```

## Prerequisites

- Hugo **extended** >= 0.121.0 (required by theme)
- Go module for theme dependency resolution

## Commands

```bash
hugo serve          # Dev server with hot reload (drafts not shown unless hugo serve -D)
hugo                # Production build into public/
hugo --gc --minify  # CI command (same as GitHub Actions)
```

`public/` and `resources/` are build artifacts — gitignored.

## Bilingual content structure

French is the default language (served at `/`), English at `/en/`.

Each post is a **page bundle**: a folder under `content/posts/<slug>/` containing:

```
index.fr.md     # French version
index.en.md     # English version
capture.png     # Media referenced in the post
```

Use `index.fr.md` for French, `index.en.md` for English.

Both language files **must share the same `date`** in frontmatter, otherwise Hugo won't link them as translations of each other.

## Frontmatter

```toml
+++
title = "Title"
date = 2026-06-02
description = "SEO meta description"
aliases = []
draft = false
+++
```

Only `title` and `date` are required. Set `draft = true` to hide a post from production.

## Key configuration quirks

- **`enableGitInfo = true`**: Dates are derived from git history. CI uses `fetch-depth: 0` for this reason. When testing locally, make sure you have git history to get correct timestamps.
- **`disableKinds = ["taxonomy", "term"]`**: No tag or category pages are generated. Don't try to use taxonomies.
- **`defaultContentLanguageInSubdir = false`**: French pages at `/posts/<slug>/`, English pages at `/en/posts/<slug>/`.

## Custom layouts

Directory `layouts/` overrides theme templates. Non-obvious customizations:

- **`layouts/posts/list.html`**: Merges translations by `TranslationKey` so each post appears once in the list (showing the current language version). Don't simplistically iterate `.Pages` on the blog index.
- **`layouts/posts/single.html`**: Uses `GitInfo` for `created`/`updated` dates instead of frontmatter dates.
- **`layouts/partials/custom-head.html`**: Injects site-specific CSS. Comic Mono is used only for `code`/`pre` blocks, not the whole site. The font is loaded from jsDelivr CDN in `head.html`.
- **`layouts/partials/head.html`**: Overrides theme `<head>` and loads Comic Mono CSS.
- **`layouts/_default/rss.xml`**: Custom RSS template.


## Deployment

Push to `main` — GitHub Actions builds with `hugo --gc --minify` and deploys to GitHub Pages. No manual deploy step needed.

## i18n strings

Found in `i18n/fr.toml` and `i18n/en.toml`. Use `{{ i18n "key" }}` or `{{ T "key" }}` in templates. Check existing keys before adding new ones.
