# Deployment Plan — Google (Firebase Hosting) + GitHub

Goal: push to GitHub → the website at `thepublicservicedesk.org` updates automatically.
Constraint: no Cloudflare. Everything runs on Google, under the organization's Google Workspace.

## Where everything lives

| Piece | Where | Owner account |
|---|---|---|
| Source code | GitHub repo (private) | org GitHub account |
| Build + deploy | GitHub Actions (created by Firebase) | runs automatically |
| Website hosting | **Firebase Hosting** in a Google Cloud project (`console.firebase.google.com`) | a shared Workspace admin account on `@thepublicservicedesk.org` — not a personal Gmail |
| Contact form email | Google Apps Script web app → sends to a Workspace inbox | same Workspace account |
| Domain registration | **stays at GoDaddy** (Google no longer sells domains) | current GoDaddy login |
| DNS | **stays at GoDaddy** — we only add/replace the website records | current GoDaddy login |
| Email | Google Workspace — **unchanged** | — |

## ⚠️ Before anything: domain expires 2026‑11‑01

The registry shows `Registry Expiry Date: 2026-11-01`. Renew in GoDaddy (or confirm auto‑renew) **now**. If it lapses, the website *and Workspace email* stop.

## DNS records — what changes and what must not

Current records (checked 2026‑10‑26):

| Record | Value | Action |
|---|---|---|
| MX `@` | `1 smtp.google.com` | **keep** (email) |
| TXT `@` | `v=spf1 include:_spf.google.com ~all` | **keep** |
| TXT `google._domainkey` | `v=DKIM1; k=rsa; p=…` | **keep** |
| TXT `_dmarc` | `v=DMARC1; p=none;` | **keep** |
| TXT `@` | `google-site-verification=…` | **keep** |
| TXT `@` | `NETORGFT14500806.onmicrosoft.com` | keep (old Microsoft 365 leftover; harmless) |
| CNAME `autodiscover` | `autodiscover.outlook.com` | keep (same) |
| A `@` | `160.153.0.103` (GoDaddy Website Builder) | **replace** with Firebase's A record(s) at cutover |
| `www` | points at GoDaddy site | **replace** with Firebase's record at cutover |
| TXT `@` | `WebsiteBuilder Site` | remove after cutover |

## Steps

### Phase 0 — Today (people, ~15 min)
1. Renew the domain in GoDaddy / turn on auto‑renew.
2. Decide the owner account: a shared Workspace account (e.g. an admin@ or web@ address). Every Google resource below gets created while signed in as that account.
3. Confirm who holds the GoDaddy login.

### Phase 1 — GitHub repo (dev)
4. `git init` in `psd-web/site`, add `.gitignore` (`node_modules`, `dist`, `.astro`), push to a new **private** GitHub repo.
5. Add `firebase.json`:
   ```json
   {
     "hosting": {
       "public": "dist",
       "cleanUrls": true,
       "trailingSlash": false,
       "redirects": [
         { "source": "/beyond-the-build", "destination": "/#beyond-the-build", "type": 301 }
       ]
     }
   }
   ```

### Phase 2 — Firebase project + auto‑deploy (dev + owner account, ~20 min)
6. Signed in as the owner account: `console.firebase.google.com` → **Add project** (e.g. `psd-web`). Analytics optional. Stays on the free **Spark** plan.
7. Locally: `bunx firebase-tools login` → `bunx firebase-tools init hosting:github` and point it at the GitHub repo. This:
   - creates a deploy service account and stores it as a GitHub secret,
   - writes two workflows: deploy‑on‑merge to `main`, and preview channel per pull request.
8. Edit both workflows so the build uses Bun:
   ```yaml
   - uses: oven-sh/setup-bun@v2
   - run: bun install --frozen-lockfile && bun run build
   ```
9. Push. The site appears at `https://psd-web.web.app` — review it there.

### Phase 3 — Connect the domain (owner account + GoDaddy, ~20 min + waiting)
10. Firebase console → Hosting → **Add custom domain** → `thepublicservicedesk.org`. Firebase shows a TXT record (ownership) and A record(s).
11. In GoDaddy DNS: add the TXT; **replace** the `A @ 160.153.0.103` record with Firebase's A record(s). Do not touch MX / SPF / DKIM / DMARC.
12. Add `www.thepublicservicedesk.org` in Firebase too, set to **redirect to the apex**; update the `www` record in GoDaddy as Firebase instructs.
13. Wait for Firebase to show **Connected** (SSL can take up to 24 h). Check: site loads on both hostnames with HTTPS, `/beyond-the-build` redirects, and send a test email in and out to confirm mail is unaffected.
14. Only after it's verified live: cancel the GoDaddy Website Builder/Airo subscription (**not** the domain).

### Phase 4 — Contact form (dev, ~1 h)
The form currently posts to `/api/contact`, which doesn't exist on static hosting.
15. Create a **Google Apps Script** web app (script.google.com, as the owner account) with a `doPost` that emails the submission to the team inbox via `MailApp`. Deploy as web app, access: *Anyone*.
16. Point the form's `fetch` at the Apps Script URL (send as `text/plain` to avoid CORS preflight). Free, no billing, stays in Workspace.
    - Alternative if volume/spam grows: Firebase Cloud Function (requires the pay‑as‑you‑go Blaze plan) or embed a Google Form.

## Day‑to‑day after setup
- Edit → open a PR → Firebase posts a **preview URL** on the PR → merge to `main` → live in ~1–2 minutes.
- Rollback: Firebase console → Hosting → release history → **Rollback**, one click.

## Who does what
| Step | Needs |
|---|---|
| 0, 3, 14 | GoDaddy login |
| 2, 3, 15 | Workspace owner account |
| 1, 2, 4, 5, 8, 16 | developer |
