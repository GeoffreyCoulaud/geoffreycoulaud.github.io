# geoffreycoulaud.github.io

Blog personnel généré avec [Hugo](https://gohugo.io/) (v0.121+, extended) et le thème [Ed](https://github.com/sergeyklay/gohugo-theme-ed).

## Configuration après clone

```bash
git config core.hooksPath .githooks   # active le hook pre-commit
```

## Prérequis

- [Hugo](https://gohugo.io/installation/) (extended, >= 0.121.0)

## Démarrer

```bash
hugo serve    # dev server avec hot reload
hugo          # build de production dans public/
```

Le site est bilingue français/anglais. Le français est la langue par défaut (racine du site), l'anglais est en `/en/`.

## Créer un article

Chaque article est un **page bundle** : un dossier contenant les fichiers de contenu pour chaque langue, plus les médias attachés.

```
content/posts/mon-article/
  index.fr.md     # version française (langue par défaut)
  index.en.md     # traduction anglaise
  capture.png     # image référencée dans l'article
```

### 1. Créer le dossier

```bash
mkdir content/posts/<slug>
```

### 2. Version française : `index.fr.md`

```toml
+++
title = "Titre de l'article"
date = 2026-06-02
description = "Résumé pour le SEO et les feeds"
aliases = []
+++

Contenu en markdown...
```

### 3. Version anglaise : `index.en.md`

```toml
+++
title = "Article Title"
date = 2026-06-02
description = "SEO description"
aliases = []
+++

Markdown content...
```

Les deux fichiers **doivent partager la même `date`** pour que Hugo les associe correctement comme traductions l'une de l'autre.

### Frontmatter disponible

| Champ | Requis | Type | Description |
|-------|--------|------|-------------|
| `title` | oui | string | Titre de l'article |
| `date` | oui | date | Date de publication (`YYYY-MM-DD`) |
| `description` | non | string | Meta description |
| `aliases` | non | []string | URLs de redirection |
| `draft` | non | bool | Si `true`, l'article n'est pas publié |

## Ajouter des médias à un article

Placer les fichiers image/vidéo dans le dossier de l'article, puis les référencer en chemin relatif :

```markdown
![Texte alternatif](capture.png)
```

Tous les fichiers dans le dossier de l'article sont copiés tels quels dans `public/`.

## URLs

| Langue | Pattern |
|--------|---------|
| Français | `/posts/<slug>/` |
| Anglais | `/en/posts/<slug>/` |

## Déploiement

```bash
hugo
```

Le contenu de `public/` est déployé sur GitHub Pages.
