# SariSafe
A GCash Transaction Recording and Verification System for Sari-Sari Stores in Brgy. Sumilihon, Butuan City
CSC 106 – Software Engineering 1 · SariSafe Navigators (Ardita, Dumanillo, Lagare, Tabita)

Offline-first web app in plain HTML/CSS/JavaScript. No build step, no server, no external API.
Data is stored in the browser's IndexedDB (`SariSafeDB`) on the device.

## Files
| File | Purpose |
|---|---|
| `index.html` | The whole app (UI, logic, IndexedDB) |
| `sw.js` | Service worker: lets the app open with no internet after the first visit |
| `manifest.json`, `icon.svg` | "Install app" / add-to-home-screen support |
| `vercel.json` | Vercel headers (service worker is never cached) |

## Run locally
Use a local server (IndexedDB and the service worker need `http://localhost`, not `file://`):
```
python -m http.server 8000
```
Then open http://localhost:8000

## Deploy to Vercel
**Option A – GitHub (recommended, matches the GitHub Desktop workflow)**
1. Push this folder to a GitHub repository.
2. Go to vercel.com → Add New → Project → import the repo.
3. Framework Preset: **Other**. Leave Build Command and Output Directory empty. Click Deploy.
4. Every push to `main` redeploys automatically.

**Option B – Vercel CLI**
```
npm i -g vercel
vercel        # follow the prompts, then
vercel --prod
```

After deploying, open the live URL once on each store device while online, then use "Add to Home screen" / "Install". After that it opens offline.

## Important
- Data lives only on the device/browser it was entered on. Each device has its own separate records.
- Owner: export the JSON backup regularly (Backup tab) before clearing browser data.
- Default owner PIN is `1234`. Change it in Fees & PIN on first use.
- When you edit any file, bump `CACHE` in `sw.js` (e.g. `sarisafe-v2`) so devices get the update.

## Requirements covered (LW4)
FR-01 to FR-12 and NFR-01 to NFR-06. Fee tiers are placeholders; set Fuentez Store's real patong in Fees & PIN.
