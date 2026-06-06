# AGENTS.md — geoffreycoulaud.github.io

Hugo blog, bilingual FR/EN, theme [Stack](https://github.com/CaiJimmy/hugo-theme-stack) v4. Deployed to GitHub Pages.

## Pour les agents IA

- **Discuter avant d'implémenter.** Ne pas écrire de code avant d'avoir exploré les alternatives, posé les questions nécessaires et levé les ambiguïtés.
- **Ne pas supposer.** Si un comportement n'est pas documenté ou vérifié, demander. Mieux vaut une question qu'une correction.
- **Comparer les outils.** Un CMS, un format, une convention — il y a souvent plusieurs options. Prendre le temps d'évaluer laquelle correspond le mieux aux contraintes du projet avant de s'engager.

## Setup after clone

```bash
git config core.hooksPath .githooks   # enables pre-commit hook
```

## Prerequisites

- Hugo **extended** >= 0.157.0 (required by theme)
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

### Posts

Each post is a **page bundle**: a folder under `content/posts/YYYY-MM-DD-slug/` containing:

```
index.fr.md     # French version
index.en.md     # English version
capture.png     # Media referenced in the post
```

Both language files **must share the same `date`** in frontmatter, otherwise Hugo won't link them as translations of each other.

### Shares (English only)

Each share is a **flat file** under `content/shares/` named `YYYY-MM-DD-slug.en.md`. The `.en` suffix is mandatory — Hugo uses the filename suffix to determine the content language. Without it, the file is treated as French and won't appear under `/en/shares/`.

Shares are English-only. They appear at `/en/shares/` with their own RSS feed at `/en/shares/index.xml`. Clicking a share redirects directly to the external link.

## Frontmatter

### Posts

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

### Shares

```toml
+++
title = "DuckDuckGo"
link = "https://duckduckgo.com/"
tags = ["privacy", "search"]
date = 2026-06-03
+++

Optional comment (markdown).
```

`title`, `link`, and `date` are required. `tags` are optional but recommended.

## Key configuration

- **`enableGitInfo = true`**: `.Lastmod` derived from git history. CI uses `fetch-depth: 0`.
- **`defaultContentLanguageInSubdir = false`**: French pages at `/`, English pages at `/en/`.
- **Taxonomies are enabled** (`disableKinds` removed). Tags only apply to shares — blog posts don't use them.
- **Permalinks**: `posts = "/posts/:slug/"`, `shares = "/shares/:contentbasename/"`, `page = "/:slug/"`.

## Custom layouts

Directory `layouts/` overrides theme templates:

- **`layouts/partials/article/components/details.html`**: Uses `GitInfo.AuthorDate` for published dates instead of frontmatter dates.
- **`layouts/partials/head/custom.html`**: Loads Comic Mono font from jsDelivr CDN for code blocks.
- **`layouts/shares/list.html`**: Compact list of shares — each item links to the external URL, shows tags.
- **`layouts/shares/single.html`**: Meta-redirect to the external link.
- **`layouts/shares/rss.xml`**: RSS feed with external links and descriptions (comments).
- **`layouts/page/search.html`** / **`layouts/_default/search.json`**: Search page templates for the Stack theme.
- **`layouts/_default/search.json`**: JSON template for the search widget.

## CSS customization

`assets/scss/custom.scss` overrides Stack theme variables:
```scss
--menu-icon-separation: 12px;     // reduced icon-text gap
--heading-border-size: 0px;       // no border on headings
--blockquote-border-size: 0px;    // no border on blockquotes
--code-font-family: "Comic Mono"; // Comic Mono for code
--accent-color: #841212;          // dark red
--body-background: #eee6dd;       // warm white
```

## Sveltia CMS

Files: `static/admin/index.html` (CDN loader) + `static/admin/config.yml` (collections, i18n, backend).

**Collections:**
- `posts` — bilingual page bundles (`multiple_files` i18n, `path: "{{slug}}/index"`, `media_folder: ""` for inline media)
- `shares` — English-only flat files (no i18n, `.en` suffix via slug template: `"{{date}}-{{slug}}.en"`, no `extension` override needed)
- `pages` — file collection with `{{locale}}` in path for about page

**Using the CMS:**
- **Local**: `hugo serve`, open `/admin/index.html` in Chromium, click "Work with Local Repository"
- **Production**: `/admin/` → "Sign In with Token" → GitHub PAT → commits directly to `main`

**Backend**: `github` with `auth_methods: [token]`.

## Content validation

**Single source of truth:** `scripts/validate-content.sh`. Called with no arguments at CI, called with staged files from the pre-commit hook.

- **Pre-commit hook** (`.githooks/pre-commit`): thin wrapper — passes `git diff --cached` file list to `scripts/validate-content.sh`.
- **CI** (`.github/workflows/github-pages.yml`): runs `scripts/validate-content.sh` before `hugo --gc --minify`.

Rules enforced:
- **Posts**: both `index.fr.md` + `index.en.md`, matching dates, folder name starts with date
- **Shares**: filename starts with `YYYY-MM-DD-`, date in frontmatter matches filename, `link` field required. Parser strips quotes (`tr -d '"'`) because Sveltia CMS writes TOML dates as strings (`date = "2026-06-06"`)

## Deployment

Push to `main` — GitHub Actions builds with `hugo --gc --minify` and deploys to GitHub Pages.

## i18n

Stack theme provides i18n strings for FR and EN. No custom i18n files in the project — the theme's defaults are used.
