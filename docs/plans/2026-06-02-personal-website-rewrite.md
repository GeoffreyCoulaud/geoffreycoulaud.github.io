# Personal Website Rewrite Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the existing single-page freelancer portfolio into a warm personal website with a vanilla bilingual landing page and a Hugo-powered blog with multilingual article support.

**Architecture:** Hybrid — Hugo generates the `/blog` section from markdown with full multilingual mode (FR + EN). Article translations are linked via page bundles. The blog listing uses `hugo.Sites` to show all articles regardless of language, grouped by translation key. Landing page lives as vanilla HTML/CSS/JS in Hugo's `static/` directory. Hugo's home page generation is disabled. A single GitHub Actions workflow installs Hugo, builds, and deploys to GitHub Pages.

**Tech Stack:** Hugo (Go binary), vanilla HTML/CSS/JS (CSS baseline MDN), GitHub Actions, GitHub Pages

---

## Pre-flight: Cleanup and scaffolding

### Task 1: Remove old site files

**Files:**
- Delete: `assets/`, `src/`, `dist/`, `node_modules/`
- Delete: `package.json`, `package-lock.json`
- Keep: `favicon.ico`, content from `assets/images/logo.png`
- Keep: `.github/workflows/github-pages.yml` (will rewrite)
- Keep: `.gitignore`

**Step 1: Back up logo and favicon**

```bash
cp assets/images/logo.png /tmp/logo.png 2>/dev/null
cp favicon.ico /tmp/favicon.ico 2>/dev/null
```

**Step 2: Delete old files**

```bash
rm -rf assets/ src/ dist/ node_modules/ package.json package-lock.json
```

**Step 3: Create new directory structure**

```bash
mkdir -p content/blog layouts/_default layouts/blog static i18n
```

**Step 4: Restore favicon and logo to static/**

```bash
cp /tmp/logo.png static/logo.png
cp /tmp/favicon.ico static/favicon.ico
```

**Step 5: Commit**

```bash
git add -A && git commit -m "chore: remove old site, scaffold new hugo+vanilla structure"
```

---

### Task 2: Initialize Hugo and configure multilingual mode

**Files:**
- Create: `hugo.toml`

**Step 1: Write hugo.toml**

```toml
baseURL = "https://geoffrey-coulaud.fr/"
title = "Geoffrey Coulaud"
enableGitInfo = true
disableKinds = ["home"]

defaultContentLanguage = "fr"
defaultContentLanguageInSubdir = false

[languages.fr]
  languageName = "Français"
  contentDir = "content"
  weight = 1

[languages.en]
  languageName = "English"
  contentDir = "content"
  weight = 2

[markup]
  [markup.highlight]
    style = "monokai"
    noClasses = false

[outputs]
  section = ["HTML", "RSS"]

[taxonomies]
  tag = "tags"

[related]
  includeNewer = true
  threshold = 80
  toLower = true
[[related.indices]]
  name = "tags"
  weight = 80
[[related.indices]]
  name = "date"
  weight = 10
```

Key points:
- `defaultContentLanguageInSubdir = false` — French content has no URL prefix (e.g., `/blog/mon-article/`)
- English content gets `/en/` prefix (e.g., `/en/blog/my-post/`)
- Same `contentDir` for both languages — translation by filename suffix
- `disableKinds = ["home"]` — landing is vanilla static HTML

**Step 2: Install Hugo locally and verify**

```bash
hugo version
```

Expected: Hugo v0.162+ installed.

**Step 3: Update .gitignore**

Add to `.gitignore`:
```
public/
.hugo_build.lock
```

**Step 4: Commit**

```bash
git add hugo.toml .gitignore && git commit -m "feat: initialize hugo with multilingual config"
```

---

## Blog templates

### Task 3: Create base template

**Files:**
- Create: `layouts/_default/baseof.html`

**Step 1: Write base template**

```html
<!DOCTYPE html>
<html lang="{{ .Language.Lang }}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{{ if .IsHome }}{{ site.Title }}{{ else }}{{ .Title }} — {{ site.Title }}{{ end }}</title>
  <meta name="description" content="{{ with .Description }}{{ . }}{{ else }}{{ with .Summary }}{{ . }}{{ end }}{{ end }}">
  <link rel="alternate" type="application/rss+xml" title="{{ site.Title }} Blog" href="{{ "blog/index.xml" | relLangURL }}">
  <link rel="icon" href="/favicon.ico">
  <link rel="stylesheet" href="/style.css">
</head>
<body>
  <header>
    <a href="/">Geoffrey Coulaud</a>
  </header>
  <main>
    {{ block "main" . }}{{ end }}
  </main>
</body>
</html>
```

**Step 2: Commit**

```bash
git add layouts/_default/baseof.html && git commit -m "feat: add base hugo template"
```

---

### Task 4: Create blog list template (cross-language)

**Files:**
- Create: `layouts/blog/list.html`

**Step 1: Write list template with cross-language grouping**

```html
{{ define "main" }}
<h1>{{ .Title }}</h1>
{{ .Content }}

{{/* Collect all blog pages across all languages, grouped by TranslationKey */}}
{{ $articlesByKey := dict }}
{{ range hugo.Sites }}
  {{ range where .RegularPages "Section" "blog" }}
    {{ $key := .TranslationKey }}
    {{ $existing := index $articlesByKey $key | default slice }}
    {{ $articlesByKey = merge $articlesByKey (dict $key ($existing | append .)) }}
  {{ end }}
{{ end }}

{{/* Sort by newest date among translations */}}
{{ $sortedKeys := slice }}
{{ range $key, $translations := $articlesByKey }}
  {{ $newestDate := (index $translations 0).Date }}
  {{ range $translations }}
    {{ if gt .Date $newestDate }}
      {{ $newestDate = .Date }}
    {{ end }}
  {{ end }}
  {{ $sortedKeys = $sortedKeys | append (dict "key" $key "date" $newestDate "pages" $translations) }}
{{ end }}

<ul>
{{ range sort $sortedKeys "date" "desc" }}
  {{ $primary := index .pages 0 }}
  <li>
    <time datetime="{{ $primary.Date.Format "2006-01-02" }}">{{ $primary.Date.Format "2006-01-02" }}</time>
    <a href="{{ $primary.RelPermalink }}">{{ $primary.Title }}</a>
    {{ range .pages }}
    <span class="badge">{{ .Language.Lang | upper }}</span>
    {{ end }}
    {{ with $primary.Params.tags }}
    <ul class="tags">
      {{ range . }}
      <li>{{ . }}</li>
      {{ end }}
    </ul>
    {{ end }}
  </li>
{{ end }}
</ul>

<p><a href="{{ "blog/index.xml" | relLangURL }}">RSS Feed</a></p>
{{ end }}
```

**Step 2: Commit**

```bash
git add layouts/blog/list.html && git commit -m "feat: add cross-language blog list template"
```

---

### Task 5: Create blog post single template

**Files:**
- Create: `layouts/blog/single.html`

**Step 1: Write single post template with translation links**

```html
{{ define "main" }}
<article>
  <header>
    <h1>{{ .Title }}</h1>
    <span class="badge">{{ .Language.Lang | upper }}</span>
    {{ with .GitInfo }}
    <p>Créé le <time datetime="{{ .AuthorDate.Format "2006-01-02" }}">{{ .AuthorDate.Format "2006-01-02" }}</time></p>
    {{ end }}
    {{ if ne .Lastmod .Date }}
    <p>Dernière modification : <time datetime="{{ .Lastmod.Format "2006-01-02" }}">{{ .Lastmod.Format "2006-01-02" }}</time></p>
    {{ end }}
    {{ with .Params.tags }}
    <ul class="tags">
      {{ range . }}
      <li>{{ . }}</li>
      {{ end }}
    </ul>
    {{ end }}
    {{ with .Translations }}
    <p>
      Aussi disponible en :
      {{ range . }}
      <a href="{{ .RelPermalink }}">{{ .Language.LanguageName }}</a>
      {{ end }}
    </p>
    {{ end }}
  </header>
  <div class="content">
    {{ .Content }}
  </div>
</article>
<nav>
  <a href="{{ "blog/" | relLangURL }}">← Retour au blog</a>
</nav>
{{ end }}
```

**Step 2: Commit**

```bash
git add layouts/blog/single.html && git commit -m "feat: add blog post template with translation links and git dates"
```

---

### Task 6: Create blog section content and example posts

**Files:**
- Create: `content/blog/_index.md`
- Create: `content/blog/_index.en.md`
- Create: `content/blog/hello-world/index.fr.md`
- Create: `content/blog/hello-world/index.en.md`

**Step 1: Write FR blog section index**

`content/blog/_index.md`:
```markdown
+++
title = "Blog"
sort_by = "date"
+++
```

**Step 2: Write EN blog section index**

`content/blog/_index.en.md`:
```markdown
+++
title = "Blog"
sort_by = "date"
+++
```

**Step 3: Write example post (FR)**

`content/blog/hello-world/index.fr.md`:
```markdown
+++
title = "Bonjour, le monde !"
date = 2026-06-02
tags = ["meta"]
aliases = ["/bonjour"]
+++

Ceci est mon premier article de blog sur mon nouveau site personnel.

## Du code

```python
def saluer(nom: str) -> str:
    return f"Bonjour, {nom} !"
```
```

**Step 4: Write example post (EN) — translation of the same article**

`content/blog/hello-world/index.en.md`:
```markdown
+++
title = "Hello, World!"
date = 2026-06-02
tags = ["meta"]
aliases = ["/hello"]
+++

This is my first blog post on my new personal website.

## Code

```python
def greet(name: str) -> str:
    return f"Hello, {name}!"
```
```

Note: Same directory `hello-world/`, same base filename `index`, different language suffixes. Hugo links them as translations. Shared assets (images etc.) go in the same directory.

**Step 5: Build and verify locally**

```bash
hugo --gc --minify
ls public/blog/index.html                        # Blog listing (FR)
ls public/blog/index.xml                         # RSS feed (FR)
ls public/blog/hello-world/index.html            # FR article
ls public/en/blog/index.html                     # Blog listing (EN)
ls public/en/blog/hello-world/index.html         # EN article
```

**Step 6: Verify cross-language listing**

```bash
grep "Bonjour" public/blog/index.html         # FR article in listing
grep "Hello" public/blog/index.html           # EN article also in FR listing
grep "badge.*EN" public/blog/index.html       # EN badge on English article
```

**Step 7: Commit**

```bash
git add content/ && git commit -m "feat: add blog section and example bilingual posts"
```

---

### Task 7: Create article archetype

**Files:**
- Create: `archetypes/blog.md`

**Step 1: Write archetype**

```markdown
+++
title = "{{ replace .Name "-" " " | title }}"
date = {{ .Date }}
tags = []
+++
```

**Step 2: Commit**

```bash
git add archetypes/blog.md && git commit -m "feat: add blog post archetype"
```

---

## Landing page (vanilla HTML/CSS/JS)

### Task 8: Create landing page HTML

**Files:**
- Create: `static/index.html`

**Step 1: Write bilingual landing page**

```html
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Geoffrey Coulaud</title>
  <meta name="description" content="Développeur full stack. Blog, projets, collaborations.">
  <link rel="alternate" type="application/rss+xml" title="Geoffrey Coulaud Blog" href="/blog/index.xml">
  <link rel="icon" href="/favicon.ico">
  <link rel="stylesheet" href="/style.css">
</head>
<body>
  <nav class="lang-switcher">
    <button data-lang="fr" aria-current="true">FR</button>
    <button data-lang="en">EN</button>
  </nav>

  <main>
    <!-- Name -->
    <section>
      <img src="/logo.png" alt="" width="80" height="80">
      <h1>Geoffrey Coulaud</h1>
    </section>

    <!-- Short site presentation -->
    <section>
      <p lang="fr">Un espace personnel où je partage ce qui m'anime : développement, projets, conférences, et plus.</p>
      <p lang="en">A personal space where I share what drives me: development, projects, conferences, and more.</p>
      <a href="/blog/">
        <span lang="fr">Lire le blog</span>
        <span lang="en">Read the blog</span>
      </a>
    </section>

    <!-- Bio -->
    <section>
      <p lang="fr">Développeur full stack passionné, j'aime construire des choses qui comptent et partager ce que j'apprends.</p>
      <p lang="en">Passionate full stack developer. I love building things that matter and sharing what I learn.</p>
    </section>

    <!-- Showcase -->
    <section>
      <h2>Showcase</h2>
      <p lang="fr">Une sélection de projets, articles, conférences et collaborations dont je suis fier.</p>
      <p lang="en">A curated selection of projects, articles, talks, and collaborations I'm proud of.</p>
      <!-- Showcase items go here -->
    </section>

    <!-- Contact -->
    <section>
      <p lang="fr">Me contacter : <a href="mailto:geoffrey.coulaud@gmail.com">geoffrey.coulaud@gmail.com</a></p>
      <p lang="en">Get in touch: <a href="mailto:geoffrey.coulaud@gmail.com">geoffrey.coulaud@gmail.com</a></p>
    </section>
  </main>

  <script src="/script.js"></script>
</body>
</html>
```

**Step 2: Commit**

```bash
git add static/index.html && git commit -m "feat: add bilingual vanilla landing page"
```

---

### Task 9: Create landing page CSS

**Files:**
- Create: `static/style.css`

**Step 1: Write minimal responsive CSS**

```css
:root {
  --color-bg: #fafafa;
  --color-text: #1a1a1a;
  --color-accent: #3a73cc;
  --font-sans: system-ui, -apple-system, sans-serif;
  --font-mono: "Fira Code", "JetBrains Mono", monospace;
  --max-width: 48rem;
}

*, *::before, *::after {
  box-sizing: border-box;
}

body {
  margin: 0;
  padding: 1rem;
  font-family: var(--font-sans);
  background: var(--color-bg);
  color: var(--color-text);
  line-height: 1.6;
  max-width: var(--max-width);
  margin-inline: auto;
}

a { color: var(--color-accent); }

/* Language switcher */
.lang-switcher { display: flex; gap: 0.5rem; justify-content: flex-end; }
.lang-switcher button {
  background: none; border: 1px solid var(--color-accent);
  color: var(--color-accent); padding: 0.25rem 0.5rem;
  cursor: pointer; border-radius: 4px;
}
.lang-switcher button[aria-current="true"] {
  background: var(--color-accent); color: white;
}

/* Bilingual visibility */
html[lang="en"] [lang="fr"] { display: none; }
html[lang="fr"] [lang="en"] { display: none; }

/* Badges */
.badge {
  display: inline-block; background: #ddd; color: #333;
  padding: 0.125rem 0.375rem; border-radius: 4px;
  font-size: 0.75rem; font-weight: 700; margin-left: 0.25rem;
  vertical-align: middle;
}

/* Tags */
.tags { display: flex; gap: 0.25rem; list-style: none; padding: 0; }
.tags li {
  background: #eee; padding: 0.125rem 0.5rem;
  border-radius: 4px; font-size: 0.875rem;
}

/* Blog content */
.content pre {
  padding: 1rem; border-radius: 4px; overflow-x: auto;
  background: #f4f4f4;
}
.content code { font-family: var(--font-mono); font-size: 0.875rem; }
.content img { max-width: 100%; height: auto; }
```

**Step 2: Commit**

```bash
git add static/style.css && git commit -m "feat: add minimal responsive css"
```

---

### Task 10: Create language switcher JS

**Files:**
- Create: `static/script.js`

**Step 1: Write language switcher**

```js
const switcher = document.querySelector('.lang-switcher');

function setLang(lang) {
  document.documentElement.lang = lang;
  localStorage.setItem('lang', lang);
  switcher.querySelectorAll('button').forEach(btn => {
    btn.setAttribute('aria-current', btn.dataset.lang === lang ? 'true' : 'false');
  });
}

switcher.addEventListener('click', (e) => {
  const btn = e.target.closest('button[data-lang]');
  if (btn) setLang(btn.dataset.lang);
});

setLang(localStorage.getItem('lang') || 'fr');
```

**Step 2: Commit**

```bash
git add static/script.js && git commit -m "feat: add language switcher js"
```

---

## CI/CD

### Task 11: Rewrite GitHub Actions workflow

**Files:**
- Modify: `.github/workflows/github-pages.yml`

**Step 1: Write new workflow**

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: "latest"
          extended: true

      - run: hugo --gc --minify

      - uses: actions/upload-pages-artifact@v3
        with:
          path: public/

  deploy:
    needs: build
    permissions:
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/deploy-pages@v4
```

Note: `fetch-depth: 0` required for `.GitInfo` to access git history.

**Step 2: Commit**

```bash
git add .github/workflows/github-pages.yml && git commit -m "ci: rewrite workflow for hugo build"
```

---

## Verification

### Task 12: Full local build verification

**Step 1: Build the site**

```bash
hugo --gc --minify
```

**Step 2: Verify output structure**

```bash
ls public/index.html                           # Landing page
ls public/style.css                            # Styles
ls public/script.js                            # Language switcher
ls public/favicon.ico                          # Favicon
ls public/logo.png                             # Logo
ls public/blog/index.html                      # Blog listing (FR)
ls public/blog/index.xml                       # RSS feed (FR)
ls public/blog/hello-world/index.html          # FR blog post
ls public/en/blog/index.html                   # Blog listing (EN)
ls public/en/blog/hello-world/index.html       # EN blog post
```

**Step 3: Verify cross-language blog listing**

```bash
grep "Bonjour" public/blog/index.html          # FR article visible
grep "Hello" public/blog/index.html            # EN article visible
grep "badge.*FR" public/blog/index.html        # FR badge
grep "badge.*EN" public/blog/index.html        # EN badge
```

**Step 4: Verify translation links on blog post**

```bash
grep "English" public/blog/hello-world/index.html      # Link to EN translation
grep "Français" public/en/blog/hello-world/index.html  # Link to FR translation
```

**Step 5: Verify RSS feed**

```bash
grep -c "<item>" public/blog/index.xml
```

Expected: at least 2 items (FR + EN versions of hello-world, each in their own language's feed).

**Step 6: Commit any fixes**

---

### Task 13: Deploy and verify live

**Step 1: Push to main**

```bash
git push origin main
```

**Step 2: Watch GitHub Actions run**

`https://github.com/GeoffreyCoulaud/geoffreycoulaud.github.io/actions`

**Step 3: Verify live URLs**

- `https://geoffrey-coulaud.fr/` — bilingual landing with switcher (canonical)
- `https://geoffrey-coulaud.fr/blog/` — blog listing with FR + EN articles
- `https://geoffrey-coulaud.fr/blog/hello-world/` — FR article with EN translation link
- `https://geoffrey-coulaud.fr/en/blog/hello-world/` — EN article with FR translation link
- `https://geoffrey-coulaud.fr/blog/index.xml` — RSS feed
- `https://geoffreycoulaud.github.io/` — also works (GitHub Pages default domain)

---

## Article creation guide (for user)

**Create a monolingual FR article:**
```
content/blog/mon-super-article/index.fr.md
```

**Create a monolingual EN article:**
```
content/blog/my-great-post/index.en.md
```

**Create a bilingual FR+EN article:**
```
content/blog/my-article/index.fr.md
content/blog/my-article/index.en.md       ← same folder, auto-linked as translation
content/blog/my-article/screenshot.png    ← shared media
```

**Frontmatter reference:**
```markdown
+++
title = "Titre de l'article"
date = 2026-06-02
lastmod = 2026-06-15        # optional, override git lastmod
tags = ["go", "devops"]
aliases = ["/old-url"]
+++
```

## Post-launch (not in this plan)

- Populate showcase section in landing with actual entries
- Write real blog posts
- Customize CSS styling (handled by user)
- Add Hugo shortcodes for embeds, videos, etc.
