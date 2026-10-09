-- Seed Initial Facts
INSERT INTO facts (code, label, category, is_red_flag) VALUES
-- Gejala
('G01', 'Bersin berulang', 'gejala', false),
('G02', 'Hidung berair atau tersumbat', 'gejala', false),
('G03', 'Mata gatal atau berair', 'gejala', false),
('G04', 'Kulit gatal atau kemerahan', 'gejala', false),
('G05', 'Bentol atau biduran', 'gejala', false),
('G06', 'Mual, muntah, atau nyeri perut', 'gejala', false),
('G07', 'Bengkak pada bibir atau wajah', 'gejala', true),
('G08', 'Sulit bernapas / tenggorokan menyempit', 'gejala', true),
('G09', 'Pusing berat / lemas / hampir pingsan', 'gejala', true),

-- Paparan Lingkungan
('P01', 'Terpapar debu atau tungau', 'paparan', false),
('P02', 'Berada dekat kucing, anjing, atau hewan lain', 'paparan', false),
('P03', 'Terpapar tanaman atau serbuk sari', 'paparan', false),
('P04', 'Berada di ruangan lembap atau berjamur', 'paparan', false),
('P05', 'Mengonsumsi makanan tertentu sebelum gejala', 'paparan', false),
('P06', 'Menggunakan sabun, kosmetik, parfum, atau losion', 'paparan', false),

-- Aktivitas
('A01', 'Membersihkan kamar atau ruangan', 'aktivitas', false),
('A02', 'Berkebun atau beraktivitas di luar', 'aktivitas', false),
('A03', 'Berinteraksi dengan hewan', 'aktivitas', false),

-- Waktu & Pola
('W01', 'Gejala muncul saat atau setelah paparan', 'waktu', false),
('W02', 'Gejala berulang pada paparan serupa', 'waktu', false),
('W03', 'Lokasi gejala sesuai area paparan/kontak', 'waktu', false)
ON CONFLICT (code) DO UPDATE 
SET label = EXCLUDED.label, category = EXCLUDED.category, is_red_flag = EXCLUDED.is_red_flag;

-- Seed Initial Rules
INSERT INTO rules (id, title, conclusion, explanation, is_candidate, required_facts, supporting_facts) VALUES
-- Stage 1: Fakta Turunan (Derived Facts)
('L1-01', 'Gejala Pernapasan', 'GEJALA_PERNAPASAN_ATAS', 'Pasien mengalami gejala pernapasan atas.', false, '{}', ARRAY['G01', 'G02', 'G03']),
('L1-02', 'Gejala Kulit', 'GEJALA_KULIT', 'Pasien mengalami keluhan pada kulit.', false, '{}', ARRAY['G04', 'G05']),
('L1-03', 'Gejala Pencernaan', 'GEJALA_PENCERNAAN', 'Pasien mengalami keluhan pencernaan.', false, '{}', ARRAY['G06']),

-- Stage 2: Kandidat Pemicu
('R01', 'Debu atau Tungau', 'KANDIDAT_DEBU_TUNGAU', 'Paparan debu/tungau memicu gejala pernapasan atas. Aktivitas membersihkan ruangan dan waktu kemunculan gejala mendukung temuan ini.', true, ARRAY['GEJALA_PERNAPASAN_ATAS', 'P01'], ARRAY['A01', 'W01', 'W02']),
('R02', 'Alergen Hewan (Bulu/Saliva)', 'KANDIDAT_ALERGEN_HEWAN', 'Berada dekat hewan terindikasi memicu gejala pernapasan. Interaksi langsung memperkuat hal ini.', true, ARRAY['GEJALA_PERNAPASAN_ATAS', 'P02'], ARRAY['A03', 'W01', 'W02']),
('R03', 'Serbuk Sari / Tanaman', 'KANDIDAT_SERBUK_SARI', 'Beraktivitas di luar ruangan dengan paparan tanaman memicu gejala pernapasan.', true, ARRAY['GEJALA_PERNAPASAN_ATAS', 'P03'], ARRAY['A02', 'W01']),
('R04', 'Jamur Lingkungan', 'KANDIDAT_JAMUR_LINGKUNGAN', 'Berada di ruangan lembap atau berjamur memunculkan gejala pernapasan.', true, ARRAY['GEJALA_PERNAPASAN_ATAS', 'P04'], ARRAY['W01', 'W02']),
('R05', 'Pemicu Makanan', 'KANDIDAT_PEMICU_MAKANAN', 'Mengonsumsi makanan tertentu memicu gejala (biasanya kulit atau pencernaan).', true, ARRAY['P05'], ARRAY['GEJALA_KULIT', 'GEJALA_PENCERNAAN', 'W01']),
('R06', 'Produk Kontak', 'KANDIDAT_PRODUK_KONTAK', 'Penggunaan produk tertentu menyebabkan keluhan pada kulit. Kesesuaian lokasi gejala memperkuat hal ini.', true, ARRAY['GEJALA_KULIT', 'P06'], ARRAY['W01', 'W03'])
ON CONFLICT (id) DO UPDATE 
SET title = EXCLUDED.title, conclusion = EXCLUDED.conclusion, explanation = EXCLUDED.explanation, 
    is_candidate = EXCLUDED.is_candidate, required_facts = EXCLUDED.required_facts, supporting_facts = EXCLUDED.supporting_facts;
