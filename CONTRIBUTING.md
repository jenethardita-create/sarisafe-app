### File 2: `CONTRIBUTING.md`

```markdown
# Contributing to SariSafe
**Repository:** `https://github.com/xyllannel-bit/sarisafe-app.git`  
**Team:** SariSafe Navigators (Ardita, Dumanillo, Lagare, Tabita)  

---

## 1. Branching Strategy
We follow a **Feature Branch Workflow** with `main` protected as our stable, deployable release branch (automatically deployed to Vercel at `https://sarisafe.vercel.app/`):

* **`main`** — Always runnable, clean, and verified. Direct pushes of untested code are avoided; changes enter via reviewed Pull Requests.
* **`feature/<short-kebab-name>`** — New features or requirement implementations (e.g., `feature/offline-db-sync`, `feature/shift-reconciliation`, `feature/cashout-pending-queue`).
* **`fix/<defect-id-or-topic>`** — Bug fixes traced to test cases or defect reports (e.g., `fix/df-01-duplicate-tail-index`, `fix/csv-date-filter`).
* **`docs/<topic>`** — Documentation, style guide, README, and testing artifacts (e.g., `docs/style-guide-testing`, `docs/readme-privacy`).

### Creating a Branch
```bash
git checkout main
git pull origin main
git checkout -b feature/<short-kebab-name>