-- Masukkan seluruh master data Gejala, Aktivitas, dan Waktu ke Supabase Cloud
INSERT INTO facts (code, label, category, is_red_flag, group_name) VALUES
-- Gejala Pernapasan & Mata
('G01', 'Bersin-bersin berulang', 'gejala', false, 'Gejala Pernapasan'),
('G02', 'Hidung berair, tersumbat, atau gatal', 'gejala', false, 'Gejala Pernapasan'),
('G03', 'Mata merah, gatal, atau berair', 'gejala', false, 'Gejala Pernapasan'),

-- Gejala Kulit
('G04', 'Kulit gatal, kemerahan, atau ruam', 'gejala', false, 'Gejala Kulit'),
('G05', 'Bentol-bentol lebar / biduran (urtikaria)', 'gejala', false, 'Gejala Kulit'),

-- Gejala Pencernaan
('G06', 'Mual, muntah, kram perut, atau diare', 'gejala', false, 'Gejala Pencernaan'),

-- Gejala Berbahaya (Red Flags)
('G07', 'Bengkak pada bibir, kelopak mata, atau wajah (Angioedema)', 'gejala', true, 'Tanda Bahaya (Red Flag)'),
('G08', 'Sulit bernapas / sesak / bunyi mengi (Wheezing)', 'gejala', true, 'Tanda Bahaya (Red Flag)'),
('G09', 'Pusing berat / lemas mendadak / hampir pingsan', 'gejala', true, 'Tanda Bahaya (Red Flag)'),

-- Aktivitas Pemicu
('A01', 'Sedang atau setelah membersihkan kamar / ruangan', 'aktivitas', false, 'Aktivitas'),
('A02', 'Sedang atau setelah berkebun / beraktivitas di luar ruangan', 'aktivitas', false, 'Aktivitas'),
('A03', 'Sedang atau setelah berinteraksi / membelai hewan', 'aktivitas', false, 'Aktivitas'),

-- Waktu & Karakteristik Gejala
('W01', 'Gejala muncul sangat cepat (hitungan menit hingga 2 jam setelah paparan)', 'waktu', false, 'Waktu & Pola'),
('W02', 'Gejala selalu berulang setiap kali terpapar hal yang sama', 'waktu', false, 'Waktu & Pola'),
('W03', 'Lokasi ruam gatal persis di area yang bersentuhan dengan benda', 'waktu', false, 'Waktu & Pola')

ON CONFLICT (code) DO UPDATE 
SET label = EXCLUDED.label, 
    category = EXCLUDED.category, 
    is_red_flag = EXCLUDED.is_red_flag,
    group_name = EXCLUDED.group_name;
