# Setting up your portfolio site

## 1. One-time setup (about 30 min)

1. **Check Quarto.** In RStudio, open the Terminal tab and run `quarto --version`. Newer RStudio versions bundle it. If you get an error, install it from quarto.org.
2. **Make a GitHub account** if you don't have one, and install **GitHub Desktop** (easiest on Windows).
3. **Unzip this folder** somewhere permanent, e.g. `C:\Users\torip\portfolio\`.
4. In RStudio: **File → New Project → Existing Directory** → pick that folder.

## 2. Make it yours (about 20 min)

- `_quarto.yml`: replace `YOUR-GITHUB-USERNAME`, `YOUR-LINKEDIN` and `YOUR-INSTAGRAM`.
- `files/resume.pdf`: add your resume.
- `projects/vegas-gp/thumbnail.png`: export a slide from your Vegas carousel.
- Fill in every `[ADD: ...]` placeholder as each project finishes.
- The F1 SQL page has `draft: true`, so it stays hidden until you remove that line.

## 3. Preview locally

In the RStudio Terminal:

```
quarto preview
```

A browser tab opens and refreshes every time you save a file.

## 4. Publish free on GitHub Pages

1. In GitHub Desktop: **File → Add local repository** → your portfolio folder → create the repository → **Publish repository**. Name it `YOUR-GITHUB-USERNAME.github.io` for the cleanest URL. Uncheck "Keep this code private".
2. In the RStudio Terminal, run:

   ```
   quarto publish gh-pages
   ```

   Answer "Y" when it asks. It builds the site and pushes it to a `gh-pages` branch.
3. Your site is live at `https://YOUR-GITHUB-USERNAME.github.io` within a few minutes.

**Every update after that:** edit, preview, then run `quarto publish gh-pages` again.

## Adding a new project

1. Copy one of the folders in `projects/` and rename it.
2. Edit the `index.qmd` inside: title, description, date, categories, image.
3. It shows up on the Projects page automatically.
