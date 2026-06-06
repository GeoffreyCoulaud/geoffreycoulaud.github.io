# geoffreycoulaud.github.io

Blog personnel généré avec [Hugo](https://gohugo.io/) (extended) et le thème [Stack](https://github.com/CaiJimmy/hugo-theme-stack) v4.

## Configuration après clone

```bash
git config core.hooksPath .githooks   # active le hook pre-commit
```

## Editer le contenu

<details>
<summary><strong>Edition avec Sveltia CMS</strong></summary>

Le site est configuré pour [Sveltia CMS](https://sveltiacms.app/en/docs/intro/), un CMS headless qui lit et écrit directement dans le dépôt Git.

### Utilisation

**En local (test)**

```bash
hugo serve
```

Ouvrir `http://localhost:1313/admin/index.html` dans un navigateur Chromium (Chrome, Edge, Brave). Cliquer **"Work with Local Repository"**, sélectionner la racine du projet. Les modifications sont écrites directement dans les fichiers locaux — pas besoin d'authentification. Committer ensuite manuellement.

**En production**

Une fois le site déployé, le CMS est accessible à l'adresse `/admin/`. Se connecter avec le bouton **"Sign In with Token"** :

1. Suivre le lien affiché pour générer un [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) GitHub (scopes pré-remplis)
2. Copier le token et le coller dans la boîte de dialogue

Le CMS lit et commit directement sur le dépôt (`main`).

### Articles

Créer une entrée dans la collection **Articles**, remplir le contenu en français (langue par défaut) puis basculer sur l'anglais. Les champs `Date` et `Brouillon` sont automatiquement dupliqués entre les deux langues. Les médias uploadés dans l'éditeur sont placés dans le page bundle.

### Partages

Créer une entrée dans la collection **Shares**.

</details>

<details>
<summary><strong>Edition manuelle</strong></summary>

### Articles

Chaque article est un **page bundle** : un dossier nommé `YYYY-MM-DD-slug` contenant les fichiers de contenu pour chaque langue, plus les médias attachés.

```
content/posts/2026-06-02-bonjour-le-monde/
  index.fr.md     # version française (langue par défaut)
  index.en.md     # traduction anglaise
  capture.png     # image référencée dans l'article
```

1. Créer le dossier :

   ```bash
   mkdir content/posts/YYYY-MM-DD-slug
   ```

2. Version française `index.fr.md` :

   ```toml
   +++
   title = "Titre de l'article"
   date = 2026-06-02
   description = "Résumé pour le SEO et les feeds"
   aliases = []
   +++

   Contenu en markdown...
   ```

3. Version anglaise `index.en.md` :

   ```toml
   +++
   title = "Article Title"
   date = 2026-06-02
   description = "SEO description"
   aliases = []
   +++

   Markdown content...
   ```

Les deux fichiers **doivent partager la même `date`** pour que Hugo les associe comme traductions.

| Champ | Requis | Type | Description |
|---|---|---|---|
| `title` | oui | string | Titre de l'article |
| `date` | oui | date | Date de publication (`YYYY-MM-DD`) |
| `description` | non | string | Meta description |
| `aliases` | non | []string | URLs de redirection |
| `draft` | non | bool | Si `true`, l'article n'est pas publié |

Les médias (images, vidéos) se placent dans le dossier de l'article et se référencent en chemin relatif :

```markdown
![Texte alternatif](capture.png)
```

### Partages

Les partages sont des liens commentés, en anglais uniquement, au format **fichier plat** nommé `YYYY-MM-DD-slug.md`.

```
content/shares/2026-06-03-duckduckgo.md
```

```toml
+++
title = "DuckDuckGo"
link = "https://duckduckgo.com/"
tags = ["privacy", "search"]
date = 2026-06-03
+++

A search engine that respects privacy. No tracking, no filter bubble.
```

| Champ | Requis | Type | Description |
|---|---|---|---|
| `title` | oui | string | Titre du partage |
| `link` | oui | string | URL cible |
| `date` | oui | date | Date (`YYYY-MM-DD`) |
| `tags` | non | []string | Tags pour le filtrage |
| `body` | non | markdown | Commentaire avant le lien |

Le nom du fichier doit commencer par la date, et le champ `date` du frontmatter doit correspondre.

</details>

## Lancer localement

Prérequis : [Hugo](https://gohugo.io/installation/) (extended, >= 0.157.0)

```bash
hugo serve    # dev server avec hot reload
hugo          # build de production dans public/
```

Le site est bilingue français/anglais.  
Le français est la langue par défaut (racine du site), l'anglais est en `/en/`.

## Déployer

Push sur `main` — GitHub Actions build avec `hugo --gc --minify` et déploie sur GitHub Pages.
