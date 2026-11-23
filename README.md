# SariSafe
**GCash Transaction Recording and Verification System for Sari-Sari Stores in Brgy. Sumilihon, Butuan City**  
CSC 106 – Software Engineering 1 · Caraga State University – College of Computing and Information Sciences  
Pilot Store: **Fuentez Store**

---

## 1. Overview
SariSafe is an offline-first Progressive Web Application (PWA) developed for sari-sari store tenders and owners in Brgy. Sumilihon, Butuan City (piloted at Fuentez Store) to record and verify GCash Cash-In and Cash-Out transactions. Handwritten logbooks make it slow and error-prone to detect reused or fabricated GCash reference numbers, calculate bracketed service fees (*patong*), track expected physical cash against GCash wallet balances, and reconcile end-of-shift totals. SariSafe addresses these issues through instant local duplicate-reference checking, automated service-fee calculation, digital customer signature capture, Cash-Out pending confirmation queues, shift Z-reading reconciliation, and optional manual cloud synchronization across store devices.

---

## 2. Features (Implemented)
* **Real-Time Duplicate Reference Verification (`FR-01`, `FR-02`, `NFR-01`):** Checks entered GCash reference numbers (configured to the last 5 digits via `REF_DIGITS = 5`, or full 13 digits) against local IndexedDB indexes (`ref` and `tail`) in milliseconds, showing an inline status indicator and triggering a warning modal to cancel, log as a `Duplicate` attempt, or override if verified as a separate receipt.
* **GCash Transaction Recording & Input Validation (`FR-03`):** Records `Cash-In` and `Cash-Out` entries with quick-amount chips (`₱100`, `₱200`, `₱500`, `₱1,000`), customer name, optional address, 11-digit Philippine mobile number validation (`09XXXXXXXXX`), and a mandatory customer accuracy confirmation checkbox.
* **Offline-First Storage & Quota Health (`FR-04`, `NFR-04`, `NFR-05`, `NFR-06`):** Persists all transactions, shifts, and settings locally in IndexedDB (`SariSafeDB`) with a service worker (`sw.js`) for offline operation and a storage quota bar that warns the owner at 80% capacity.
* **Role-Based Access Control (`FR-05`, `FR-07`):** Separates the app into a **Store Tender** view (`Counter` and `Shift` tabs) and a **Store Owner** view (`Counter`, `Shift`, `Summary`, `Log`, `Fees`, and `Backup` tabs) secured with a SHA-256 hashed 4-digit PIN.
* **CSV Export & JSON Backup/Restore (`FR-06`, `FR-12`):** Exports comma-separated transaction logs (`.csv`, filterable by specific date or all dates, with confirmed `OK` summary totals for Excel/Google Sheets) and full system snapshots (`.json`, containing transactions, signatures, shifts, and fee tiers) with non-destructive merge restore.
* **Digital Customer Signatures & Printable Receipts (`FR-08`):** Captures touch/pointer signatures on an HTML5 Canvas pad, displays an automatic transaction receipt popup after saving, and stores signatures inside a searchable, printable transaction history log.
* **Automated Service Fee (*Patong*) Tiers (`FR-09`):** Includes 100 pre-configured brackets covering `₱1` to `₱50,000` (`₱10` per `₱500` bracket, up to `₱1,000`), with per-transaction manual overrides and owner tier editing/reset controls.
* **Transaction Status Rules & Offsetting Corrections (`FR-10`):** Automatically sets `Cash-In` entries to `OK` and locks `Cash-Out` entries to `Pending` until the tender verifies receipt of funds and taps **Mark OK**. Saved records cannot be edited or deleted; errors are reversed using offsetting `Correction` entries with a required explanation note.
* **Shift & Cash Float Reconciliation (`FR-11`):** Tracks starting physical cash and GCash wallet balances per shift, updates expected balances live (with a show/hide privacy toggle), warns if `Pending` transactions remain before closing, and produces a shift Z-reading summary (`Balanced`, `Over`, or `Short`).
* **Optional Manual Cloud Sync (Multi-Device Support):** Allows the store owner to manually sign in via Supabase Auth to upload local records and download records from other devices, signing out immediately afterward without saving credentials on the device.

---

## 3. Technologies and Versions
* **Frontend:** HTML5, CSS3 (`styles.css`), Vanilla JavaScript (`"use strict"`, HTML5 Canvas API, Web Crypto API `SHA-256`)
* **Local Storage & Offline PWA:** IndexedDB (`SariSafeDB`, schema v2), Service Worker API (`sw.js`, cache `sarisafe-v18`), Web App Manifest (`manifest.json`, `icon.svg`)
* **Optional Cloud Backend:** Supabase (PostgreSQL with Row-Level Security, Auth REST API v1, PostgREST v1 — schema in `supabase-setup.sql`)
* **Hosting & Development Tools:** Vercel Static Hosting (`vercel.json`), Python 3 (`http.server`) for local serving, Git & GitHub

---

## 4. Installation and Setup

### 4.1 Requirements
* A modern web browser supporting IndexedDB and Service Workers (Chrome, Edge, Firefox, or Safari).
* **For local testing:** Python 3.x (or another local HTTP server such as VS Code Live Server). *IndexedDB and Service Workers require `http://localhost` and will not work properly over `file://`.*

### 4.2 Download / Clone
```bash
git clone https://github.com/xyllannel-bit/sarisafe-app.git
cd sarisafe