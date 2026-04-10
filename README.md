# FlowTrack — Petroleum Intelligence Platform

A comprehensive, enterprise-grade Fuel Management System for petroleum distributors, depot operators, and fuel retailers.

---

## 🚀 Features

| Module | Capabilities |
|---|---|
| **Stock Management** | Real-time stock levels at NOIC, Company Depots & Service Stations |
| **Supplier Releases** | Track purchase orders, delivery status & outstanding balances |
| **Release Orders** | Create, submit, approve & manage fuel release orders |
| **Drawdowns** | Record and track collections against approved releases |
| **Approval Workflow** | In-system authorisation for release orders with full audit |
| **Invoicing** | Tax invoice generation, payment tracking, aging reports |
| **Blending Calculator** | Ethanol/Petrol blend ratios (E5–E85), cost computation |
| **Service Stations** | Live tank balances, low-stock alerts per company site |
| **Reports** | Stock movement, release, invoice aging, supplier performance |
| **RBAC Users** | Role-based access: Super Admin, Manager, Operations, Accounts, Viewer |
| **Admin Panel** | Manage customers, products, transporters, provinces, sectors |
| **Audit Log** | Full tamper-proof trail of all system actions |

---

## 🗂 Project Structure

```
flowtrack/
├── index.html              # Complete single-file application (React-free, zero deps)
├── supabase_schema.sql     # Full database schema with seed data
├── netlify.toml            # Netlify deployment config
├── README.md               # This file
└── .env.example            # Environment variable template
```

---

## ⚙️ Setup Instructions

### Step 1 — Supabase Setup

1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Name: `flowtrack-petroleum` · Region: closest to Zimbabwe (e.g. `af-south-1`)
3. Once live, go to **SQL Editor** → **New Query**
4. Paste the contents of `supabase_schema.sql` and click **Run**
5. Go to **Settings → API** and copy:
   - `Project URL` → `SUPABASE_URL`
   - `anon/public key` → `SUPABASE_ANON_KEY`

### Step 2 — GitHub Setup

```bash
# Create a new repo on github.com named "flowtrack"
git init
git add .
git commit -m "Initial FlowTrack deployment"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/flowtrack.git
git push -u origin main
```

### Step 3 — Netlify Deployment

1. Go to [netlify.com](https://netlify.com) → **Add New Site → Import from Git**
2. Connect your GitHub account → Select the `flowtrack` repository
3. Build settings:
   - **Build command:** *(leave blank)*
   - **Publish directory:** `.`
4. Click **Deploy Site**
5. Go to **Site Settings → Environment Variables** and add:
   ```
   SUPABASE_URL = https://xxxx.supabase.co
   SUPABASE_ANON_KEY = eyJ...
   ```

### Step 4 — Update Environment Variables in index.html

In `index.html`, find and replace:
```javascript
const supabaseUrl = 'https://your-project.supabase.co';
const supabaseAnonKey = 'your-anon-key';
```
with your actual Supabase credentials.

> **Note:** For production, inject these via Netlify's environment variables using a build script or edge functions.

---

## 👤 Default Roles & Permissions

| Role | Can Do |
|---|---|
| Super Admin | Everything — full system control |
| Manager | Approve/reject releases, all reports, invoice view |
| Operations | Create releases, record drawdowns, view stock |
| Accounts | Create invoices, record payments, financial reports |
| Viewer | Read-only dashboard access only |

---

## 🗄 Key Database Tables

| Table | Purpose |
|---|---|
| `stock_levels` | Current stock per product per source depot |
| `site_stock` | Tank levels at company service stations |
| `release_orders` | All fuel release orders |
| `release_drawdowns` | Individual collection records |
| `supplier_purchases` | Supplier POs and delivery tracking |
| `invoices` | Tax invoices with payment tracking |
| `blending_records` | Ethanol blend batches |
| `stock_transactions` | Immutable stock movement log |
| `audit_logs` | Complete user action history |
| `user_profiles` | Users with RBAC roles |

---

## 📊 Supabase Realtime

Stock levels, release orders, drawdowns, and invoices are all enabled for **Supabase Realtime** — meaning the dashboard updates live without page refresh when connected to the database.

---

## 🖨 Document Generation

FlowTrack generates two printable documents:
- **Fuel Release Order Form** — for presenting at NOIC or company depot for collection
- **Fiscal Tax Invoice** — matching Zimbabwe ZIMRA format with HS codes and VAT

Both are generated in-browser and can be printed directly or saved as PDF.

---

## 🛠 Tech Stack

- **Frontend:** Vanilla HTML/CSS/JS (no framework dependencies)
- **Database:** Supabase (PostgreSQL with RLS and Realtime)
- **Hosting:** Netlify (static hosting with CI/CD from GitHub)
- **Fonts:** Syne + DM Sans (Google Fonts)
- **Print:** Native browser print API

---

## 📞 Support

System built with FlowTrack Petroleum Intelligence Platform.  
For customisation or integration support, contact your system administrator.
