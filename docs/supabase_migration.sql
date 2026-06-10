-- ─────────────────────────────────────────────────────────
-- Price Pilot — Supabase Database Schema
-- ─────────────────────────────────────────────────────────
-- Run this in your Supabase SQL Editor to create all
-- required tables. Supabase Auth handles the auth.users
-- table; this creates the application-level tables.
-- ─────────────────────────────────────────────────────────

-- Users (profiles linked to Supabase Auth)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Bookings
CREATE TABLE IF NOT EXISTS bookings (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  pickup_lat DOUBLE PRECISION NOT NULL,
  pickup_lng DOUBLE PRECISION NOT NULL,
  pickup_address TEXT,
  dropoff_lat DOUBLE PRECISION NOT NULL,
  dropoff_lng DOUBLE PRECISION NOT NULL,
  dropoff_address TEXT,
  service TEXT NOT NULL,
  vehicle_type TEXT NOT NULL,
  price DOUBLE PRECISION NOT NULL,
  distance_km DOUBLE PRECISION,
  duration_minutes INTEGER,
  status TEXT NOT NULL DEFAULT 'pending',
  booked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ,
  driver_id TEXT
);

-- Saved locations
CREATE TABLE IF NOT EXISTS saved_locations (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  address TEXT,
  type TEXT NOT NULL DEFAULT 'other'
);

-- Search history
CREATE TABLE IF NOT EXISTS search_history (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  query TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  searched_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Preferences
CREATE TABLE IF NOT EXISTS preferences (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  UNIQUE (user_id, key)
);

-- Ride pricing options (replaces hardcoded/random pricing)
CREATE TABLE IF NOT EXISTS ride_options (
  id SERIAL PRIMARY KEY,
  service TEXT NOT NULL,
  vehicle_type TEXT NOT NULL,
  base_fare DOUBLE PRECISION NOT NULL,
  per_km_rate DOUBLE PRECISION NOT NULL,
  per_min_rate DOUBLE PRECISION NOT NULL,
  surge_multiplier DOUBLE PRECISION NOT NULL DEFAULT 1.0,
  seating_capacity INTEGER NOT NULL DEFAULT 4,
  eta_buffer_minutes INTEGER NOT NULL DEFAULT 5,
  UNIQUE (service, vehicle_type)
);

-- ─────────────────────────────────────────────────────────
-- Indices
-- ─────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings (status);
CREATE INDEX IF NOT EXISTS idx_saved_locations_user ON saved_locations (user_id);
CREATE INDEX IF NOT EXISTS idx_search_history_user ON search_history (user_id);

-- ─────────────────────────────────────────────────────────
-- Row Level Security (RLS)
-- ─────────────────────────────────────────────────────────
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE ride_options ENABLE ROW LEVEL SECURITY;

-- Users: users can read/update their own profile
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Bookings: users can CRUD their own bookings
CREATE POLICY "Users can view own bookings" ON bookings
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own bookings" ON bookings
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own bookings" ON bookings
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own bookings" ON bookings
  FOR DELETE USING (auth.uid() = user_id);

-- Saved locations: users can CRUD their own
CREATE POLICY "Users can view own locations" ON saved_locations
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own locations" ON saved_locations
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own locations" ON saved_locations
  FOR DELETE USING (auth.uid() = user_id);

-- Search history: users can CRUD their own
CREATE POLICY "Users can view own history" ON search_history
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own history" ON search_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own history" ON search_history
  FOR DELETE USING (auth.uid() = user_id);

-- Preferences: users can CRUD their own
CREATE POLICY "Users can view own prefs" ON preferences
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own prefs" ON preferences
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own prefs" ON preferences
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own prefs" ON preferences
  FOR DELETE USING (auth.uid() = user_id);

-- Ride options: readable by all authenticated users (prices are public)
CREATE POLICY "Authenticated users can view rides" ON ride_options
  FOR SELECT USING (auth.role() = 'authenticated');

-- ─────────────────────────────────────────────────────────
-- Seed ride pricing data
-- ─────────────────────────────────────────────────────────
INSERT INTO ride_options (service, vehicle_type, base_fare, per_km_rate, per_min_rate, surge_multiplier, seating_capacity, eta_buffer_minutes) VALUES
  -- Uber
  ('Uber', 'Bike',    25,  7.5, 1.0, 1.0, 1, 0),
  ('Uber', 'Auto',    30, 10.0, 1.5, 1.0, 3, 5),
  ('Uber', 'Mini',    50, 12.0, 2.0, 1.0, 4, 8),
  ('Uber', 'Sedan',   80, 15.0, 2.5, 1.0, 4, 10),
  -- Ola
  ('Ola', 'Bike',     20,  7.0, 1.0, 1.0, 1, 0),
  ('Ola', 'Auto',     28,  9.5, 1.5, 1.0, 3, 5),
  ('Ola', 'Mini',     45, 11.0, 1.8, 1.0, 4, 8),
  ('Ola', 'Sedan',    75, 14.0, 2.5, 1.0, 4, 10),
  -- Rapido
  ('Rapido', 'Bike',  15,  6.0, 0.8, 1.0, 1, 0),
  ('Rapido', 'Auto',  25,  8.5, 1.2, 1.0, 3, 5),
  -- Meru Cabs
  ('Meru', 'Sedan',  100, 16.0, 2.0, 1.0, 4, 12),
  ('Meru', 'SUV',    150, 20.0, 3.0, 1.0, 6, 15),
  -- BluSmart
  ('BluSmart', 'Sedan',    70, 13.0, 1.8, 1.0, 4, 10),
  ('BluSmart', 'Premium', 120, 18.0, 2.8, 1.0, 4, 12),
  -- InDrive
  ('InDrive', 'Mini',   35,  9.0, 1.4, 1.0, 4, 8),
  ('InDrive', 'Sedan',  55, 12.0, 2.0, 1.0, 4, 10),
  -- Namma Yatri
  ('Namma Yatri', 'Auto', 22, 8.0, 1.0, 1.0, 3, 5),
  ('Namma Yatri', 'Mini', 40, 10.0, 1.5, 1.0, 4, 8)
ON CONFLICT (service, vehicle_type) DO NOTHING;
