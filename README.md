# The Public Service Desk — Website

The one-page website for [thepublicservicedesk.org](https://thepublicservicedesk.org), built with Astro, Tailwind CSS and Bun. It is meant to be hosted on Google Firebase Hosting. The full launch plan is in [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).

## Uploading this to GitHub (first time)

Create a new **private** repository under the PSD GitHub account, named e.g. `psd-web`. Leave "Add a README" **unchecked** so the repository starts empty.

**Option A: in the browser (no tools needed)**
1. Unzip `psd-web.zip`.
2. On the empty repository's page, click **uploading an existing file**.
3. Open the unzipped `psd-web` folder, select **everything inside it** and drag it into the browser. On a Mac, press `Cmd + Shift + .` in Finder first so hidden files like `.gitignore` show up and get selected too.
4. Click **Commit changes**.

**Option B: from the terminal**
```sh
cd psd-web
git init -b main
git add .
git commit -m "Initial commit: PSD website"
git remote add origin https://github.com/<PSD-ACCOUNT>/psd-web.git
git push -u origin main
```

## Running it locally

Requires [Bun](https://bun.sh).

```sh
bun install
bun run dev      # http://localhost:4321
bun run build    # outputs the static site to dist/
```

The scripts run Astro through Bun (`bunx --bun astro`), so a separate Node.js install isn't needed.

## Project layout

```text
src/pages/index.astro       the whole page (all sections)
src/components/             Header, Footer, Doodle (hand-drawn illustrations), Squiggle (underline)
src/layouts/Layout.astro    page shell, fonts, scroll animations
src/styles/global.css       colours, fonts, theme
public/images/              photos and logo
firebase.json               Firebase Hosting settings (incl. /beyond-the-build redirect)
docs/DEPLOYMENT.md          step-by-step launch plan
```

## Known to-do

The contact form posts to `/api/contact`, which doesn't exist yet. Until it does, visitors see "Something went wrong." Step 5 of `docs/DEPLOYMENT.md` covers connecting it to a Google Apps Script that emails the team inbox.
