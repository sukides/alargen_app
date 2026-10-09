-- 1. Enum Category
CREATE TYPE fact_category AS ENUM ('gejala', 'paparan', 'aktivitas', 'waktu', 'turunan');

-- 2. Table: Facts (Single Source of Truth)
CREATE TABLE IF NOT EXISTS facts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) UNIQUE NOT NULL,
    label TEXT NOT NULL,
    category fact_category NOT NULL,
    is_red_flag BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Table: Rules (Forward Chaining Rules)
CREATE TABLE IF NOT EXISTS rules (
    id VARCHAR(20) PRIMARY KEY,
    title TEXT NOT NULL,
    conclusion TEXT NOT NULL,
    explanation TEXT NOT NULL,
    is_candidate BOOLEAN DEFAULT FALSE,
    required_facts TEXT[] DEFAULT '{}',
    supporting_facts TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Table: Consultations / Submissions
CREATE TABLE IF NOT EXISTS consultations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_name TEXT,
    selected_facts TEXT[] NOT NULL,
    food_description TEXT,
    product_description TEXT,
    notes TEXT,
    is_red_flag BOOLEAN DEFAULT FALSE,
    result_candidates JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE facts ENABLE ROW LEVEL SECURITY;
ALTER TABLE rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE consultations ENABLE ROW LEVEL SECURITY;

-- Allow public read/write for dev/backoffice
CREATE POLICY "Public facts access" ON facts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public rules access" ON rules FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public consultations access" ON consultations FOR ALL USING (true) WITH CHECK (true);
