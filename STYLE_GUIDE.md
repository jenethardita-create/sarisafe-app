# SariSafe Team Style Guide
**Project:** SariSafe – GCash Transaction Recording and Verification System for Sari-Sari Stores in Brgy. Sumilihon, Butuan City  
**Team:** SariSafe Navigators (Ardita, Dumanillo, Lagare, Tabita)  
**Course:** CSC 106 – Software Engineering 1 | Caraga State University – CCIS  

---

## 1. Purpose and Scope
This style guide establishes consistent coding, formatting, architectural, error-handling, and documentation conventions for the **SariSafe** Progressive Web Application (PWA). Following these rules ensures that every team member can read, maintain, audit, and test any part of the codebase without friction.

---

## 2. Technology Stack & Versions
* **Frontend Markup & Styling:** HTML5, CSS3 (`styles.css` with CSS Custom Properties)
* **Application Logic:** Vanilla ES6+ JavaScript (`"use strict"`), HTML5 `<canvas>` API, Web Crypto API (`SHA-256`)
* **Offline Storage & Caching:** IndexedDB (`SariSafeDB`, schema v2), Service Worker API (`sw.js`), Web App Manifest (`manifest.json`)
* **Cloud Backend & Security:** Supabase PostgreSQL, PL/pgSQL triggers & security-definer RPCs, Row-Level Security (`supabase-setup.sql`)
* **Deployment & Config:** Vercel Static Hosting (`vercel.json`), UTF-8 / LF line endings (`.gitattributes`)

---

## 3. Naming Conventions

| Construct | Convention | Project Examples |
| :--- | :--- | :--- |
| **JS Functions & Variables** | `camelCase` | `calcFee`, `findDup`, `renderRecent`, `scheduleAutoSync`, `ownerAuth` |
| **JS Constants & Configs** | `UPPER_SNAKE_CASE` | `REF_DIGITS`, `DEFAULT_TIERS`, `SUPABASE_URL`, `CACHE`, `SHELL`, `TBL` |
| **JS Boolean Flags & Validators** | Prefix with `is` or `valid` | `isNum`, `isDate`, `isLegacyDefault`, `validTx`, `validShift`, `validTiers` |
| **HTML IDs (JS Hooks)** | Short `camelCase` or `v-<tab>` | `#saveTx`, `#refInd`, `#custAck`, `#v-counter`, `#v-shift`, `#v-summary` |
| **CSS Classes** | `kebab-case` (or short state tags) | `.rcpt-head`, `.pend-card`, `.priv-doc`, `.pinbox`, `.st.OK`, `.st.Pending` |
| **CSS Custom Properties** | `--<short-name>` under `:root` | `--ink`, `--mut`, `--bg`, `--card`, `--blue`, `--blue2`, `--red`, `--grn`, `--amb` |
| **SQL Tables, Columns & Functions** | `snake_case` prefixed with `sarisafe_` | `sarisafe_transactions`, `sarisafe_shifts`, `sarisafe_tender_sync`, `sarisafe_touch` |
| **Repository Files** | `kebab-case` for assets; `UPPERCASE.md` for root docs | `supabase-setup.sql`, `styles.css`, `manifest.json`, `README.md`, `STYLE_GUIDE.md` |

---

## 4. Formatting & Layout Rules
* **Indentation & Line Endings:** Use **2 spaces** per indentation level across HTML, CSS, JavaScript, JSON, and SQL. Enforce UTF-8 encoding and LF (`\n`) line endings via `.gitattributes` (`* text=auto`).
* **Quotes & Semicolons:**
  * Use double quotes (`"..."`) in HTML attributes, JSON files, and standard JavaScript strings; use backticks (`` `...` ``) for template interpolation.
  * Use single quotes (`'...'`) for SQL string literals.
  * Terminate JavaScript and SQL statements with explicit semicolons (`;`).
* **CSS Design Tokens & Accessibility:**
  * Define palette and elevation variables once in `:root` (`styles.css`) rather than hardcoding repeated hex values.
  * Maintain touch-friendly tap targets (`min-height` / generous padding) for counter tablets/phones and preserve `@media (prefers-reduced-motion: reduce)` and `@media print` rules.

---

## 5. Architectural & Folder Structure
SariSafe uses an **Offline-First Modular Monolith** architecture designed for zero-build reliability on low-spec store devices:

```text
sarisafe-app/
├── index.html           # Main PWA shell, Counter/Shift/Owner views, IndexedDB & sync logic
├── styles.css           # GCash-inspired responsive theme, modals, print receipt & PIN styles
├── sw.js                # Network-first Service Worker for offline shell availability
├── manifest.json        # PWA installation metadata
├── icon.svg             # Vector app icon
├── supabase-setup.sql   # PostgreSQL schema, immutability triggers, write-only RPC, and RLS policies
├── vercel.json          # HTTP security headers (CSP/X-Frame-Options/nosniff) & SW cache rules
├── .gitignore           # Excludes .env, local files, and exported customer CSV/JSON backups
├── .gitattributes       # Enforces LF line normalization
├── README.md            # Project overview, setup, run instructions, and final commit metadata
├── STYLE_GUIDE.md       # Team coding and formatting standards
├── CONTRIBUTING.md      # Branching, commit message, and pull-request workflow
└── docs/
    └── testing/         # Lab Worksheet 11 test plan, test cases, and defect evidence