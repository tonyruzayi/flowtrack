-- ================================================================
-- FLOWTRACK PETROLEUM INTELLIGENCE PLATFORM
-- Supabase Database Schema
-- Run this in your Supabase SQL Editor (Project > SQL Editor)
-- ================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── LOOKUP TABLES ────────────────────────────────────────────
CREATE TABLE provinces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE sectors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  hs_code TEXT,
  unit TEXT DEFAULT 'Litres',
  vat_rate NUMERIC(5,2) DEFAULT 0,
  is_blendable BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE sources (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT CHECK (type IN ('NOIC','Company Depot','Supplier')) NOT NULL,
  location TEXT,
  province_id UUID REFERENCES provinces(id),
  contact_person TEXT,
  phone TEXT,
  email TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE transporters (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  registration_number TEXT,
  contact_person TEXT,
  phone TEXT,
  email TEXT,
  fleet_size INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  tin TEXT,
  vat_reg TEXT,
  address TEXT,
  province_id UUID REFERENCES provinces(id),
  sector_id UUID REFERENCES sectors(id),
  phone TEXT,
  email TEXT,
  payment_terms INTEGER DEFAULT 14,
  credit_limit NUMERIC(15,2) DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE sites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT CHECK (type IN ('Service Station','Company Depot','NOIC')) NOT NULL,
  address TEXT,
  province_id UUID REFERENCES provinces(id),
  manager_name TEXT,
  phone TEXT,
  email TEXT,
  tank_capacity NUMERIC(15,2) DEFAULT 0,
  reorder_level NUMERIC(15,2) DEFAULT 0,
  is_company_owned BOOLEAN DEFAULT TRUE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── RBAC ────────────────────────────────────────────────────
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  permissions JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  email TEXT,
  phone TEXT,
  role_id UUID REFERENCES roles(id),
  department TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── STOCK MANAGEMENT ────────────────────────────────────────
CREATE TABLE stock_levels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_id UUID REFERENCES sources(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  opening_balance NUMERIC(15,2) DEFAULT 0,
  current_balance NUMERIC(15,2) DEFAULT 0,
  reserved_quantity NUMERIC(15,2) DEFAULT 0,
  reorder_level NUMERIC(15,2) DEFAULT 0,
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(source_id, product_id)
);

CREATE TABLE site_stock (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id UUID REFERENCES sites(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  current_balance NUMERIC(15,2) DEFAULT 0,
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(site_id, product_id)
);

-- ─── SUPPLIER PURCHASES ──────────────────────────────────────
CREATE TABLE supplier_purchases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reference_no TEXT NOT NULL UNIQUE,
  supplier_name TEXT,
  source_id UUID REFERENCES sources(id),
  product_id UUID REFERENCES products(id),
  invoice_number TEXT,
  invoice_date DATE,
  quantity_ordered NUMERIC(15,2) DEFAULT 0,
  quantity_received NUMERIC(15,2) DEFAULT 0,
  quantity_drawn NUMERIC(15,2) DEFAULT 0,
  unit_price NUMERIC(10,4),
  total_amount NUMERIC(15,2),
  status TEXT CHECK (status IN ('Pending','Partial','Received','Cancelled')) DEFAULT 'Pending',
  expected_date DATE,
  notes TEXT,
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── RELEASE ORDERS ──────────────────────────────────────────
CREATE TABLE release_orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  release_no TEXT NOT NULL UNIQUE,
  release_date DATE NOT NULL DEFAULT CURRENT_DATE,
  customer_id UUID REFERENCES customers(id),
  source_id UUID REFERENCES sources(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  quantity_requested NUMERIC(15,2) NOT NULL,
  quantity_released NUMERIC(15,2) DEFAULT 0,
  unit_price NUMERIC(10,4),
  total_amount NUMERIC(15,2),
  transporter_id UUID REFERENCES transporters(id),
  truck_registration TEXT,
  driver_name TEXT,
  driver_id_no TEXT,
  destination_site_id UUID REFERENCES sites(id),
  status TEXT CHECK (status IN ('Draft','Pending Approval','Approved','Partial','Completed','Cancelled','Rejected')) DEFAULT 'Draft',
  approved_by UUID REFERENCES user_profiles(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  notes TEXT,
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── DRAWDOWNS ───────────────────────────────────────────────
CREATE TABLE release_drawdowns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  release_order_id UUID REFERENCES release_orders(id) NOT NULL,
  drawdown_date DATE NOT NULL DEFAULT CURRENT_DATE,
  quantity NUMERIC(15,2) NOT NULL,
  truck_registration TEXT,
  driver_name TEXT,
  collection_ref TEXT,
  collected_by TEXT,
  notes TEXT,
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── INVOICES ────────────────────────────────────────────────
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  invoice_no TEXT NOT NULL UNIQUE,
  invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
  due_date DATE,
  customer_id UUID REFERENCES customers(id),
  release_order_id UUID REFERENCES release_orders(id),
  product_id UUID REFERENCES products(id),
  quantity NUMERIC(15,2),
  unit_price NUMERIC(10,4),
  subtotal NUMERIC(15,2),
  vat_rate NUMERIC(5,2) DEFAULT 0,
  vat_amount NUMERIC(15,2) DEFAULT 0,
  total_amount NUMERIC(15,2),
  amount_paid NUMERIC(15,2) DEFAULT 0,
  balance_due NUMERIC(15,2),
  hs_code TEXT,
  status TEXT CHECK (status IN ('Draft','Sent','Partial','Paid','Overdue','Cancelled')) DEFAULT 'Draft',
  notes TEXT,
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── BLENDING ────────────────────────────────────────────────
CREATE TABLE blending_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  blend_ref TEXT NOT NULL UNIQUE,
  blend_date DATE NOT NULL DEFAULT CURRENT_DATE,
  source_id UUID REFERENCES sources(id),
  base_product_id UUID REFERENCES products(id),
  additive_product_id UUID REFERENCES products(id),
  base_quantity NUMERIC(15,2),
  additive_quantity NUMERIC(15,2),
  blend_ratio NUMERIC(5,2),
  output_quantity NUMERIC(15,2),
  cost_per_litre NUMERIC(10,4),
  total_cost NUMERIC(15,2),
  notes TEXT,
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── STOCK TRANSACTIONS LOG ──────────────────────────────────
CREATE TABLE stock_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_id UUID REFERENCES sources(id),
  site_id UUID REFERENCES sites(id),
  product_id UUID REFERENCES products(id) NOT NULL,
  transaction_type TEXT CHECK (transaction_type IN ('Stock In','Release','Drawdown','Adjustment','Transfer','Blend','Write-off')) NOT NULL,
  reference_no TEXT,
  quantity NUMERIC(15,2) NOT NULL,
  balance_before NUMERIC(15,2),
  balance_after NUMERIC(15,2),
  notes TEXT,
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── AUDIT LOG ───────────────────────────────────────────────
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_profiles(id),
  user_name TEXT,
  action TEXT NOT NULL,
  entity_type TEXT,
  entity_id UUID,
  entity_ref TEXT,
  old_values JSONB,
  new_values JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── SEED DATA ───────────────────────────────────────────────
INSERT INTO provinces (name) VALUES
('Harare'),('Bulawayo'),('Manicaland'),('Mashonaland Central'),
('Mashonaland East'),('Mashonaland West'),('Masvingo'),
('Matabeleland North'),('Matabeleland South'),('Midlands');

INSERT INTO sectors (name) VALUES
('Mining'),('Agriculture'),('Transport'),('Construction'),
('Manufacturing'),('Government'),('NGO'),('Retail'),('Energy'),
('Telecoms'),('Banking'),('Hospitality');

INSERT INTO products (name, hs_code, unit, vat_rate, is_blendable) VALUES
('Diesel','27101929','Litres',0,false),
('Petrol (ULP 93)','27101245','Litres',0,true),
('Petrol (ULP 95)','27101245','Litres',0,true),
('Blended Petrol (E10)','27101245','Litres',0,false),
('Ethanol (E85)','22071000','Litres',0,true),
('Jet A1','27101921','Litres',0,false),
('Paraffin','27101910','Litres',0,false);

INSERT INTO roles (name, description, permissions) VALUES
('Super Admin','Full system access','{"all":true}'),
('Manager','Approve releases, all reports','{"approve":true,"reports":true,"releases":true,"invoices":true,"stock":true,"customers":true}'),
('Operations','Create releases, manage stock','{"releases":true,"stock":true,"drawdowns":true,"view_reports":true}'),
('Accounts','Invoicing and financial reports','{"invoices":true,"reports":true,"customers":true,"view_stock":true}'),
('Viewer','Read-only dashboard access','{"view":true}');

-- ─── ROW LEVEL SECURITY ──────────────────────────────────────
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE release_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Users can see their own profile
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

-- Super Admins can manage all profiles
CREATE POLICY "Super Admins manage all profiles"
  ON user_profiles FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles up
      JOIN roles r ON up.role_id = r.id
      WHERE up.id = auth.uid() AND (r.permissions->>'all')::boolean = true
    )
  );

-- ─── REALTIME ────────────────────────────────────────────────
-- Enable realtime on key tables for live dashboard updates
ALTER PUBLICATION supabase_realtime ADD TABLE stock_levels;
ALTER PUBLICATION supabase_realtime ADD TABLE release_orders;
ALTER PUBLICATION supabase_realtime ADD TABLE release_drawdowns;
ALTER PUBLICATION supabase_realtime ADD TABLE invoices;
ALTER PUBLICATION supabase_realtime ADD TABLE stock_transactions;
