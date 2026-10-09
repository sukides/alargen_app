-- Seed new dataset from Sayyid for specific allergen categories
INSERT INTO facts (code, label, category, group_name, is_red_flag) VALUES
-- Alergi Lingkungan
('P10', 'Debu rumah dan tungau debu', 'paparan', 'Alergi Lingkungan', false),
('P11', 'Serbuk sari tanaman', 'paparan', 'Alergi Lingkungan', false),
('P12', 'Bulu atau serpihan kulit hewan', 'paparan', 'Alergi Lingkungan', false),
('P13', 'Jamur dan spora jamur', 'paparan', 'Alergi Lingkungan', false),
('P14', 'Asap rokok', 'paparan', 'Alergi Lingkungan', false),

-- Alergi Makanan
('P20', 'Susu sapi', 'paparan', 'Alergi Makanan', false),
('P21', 'Telur', 'paparan', 'Alergi Makanan', false),
('P22', 'Kacang tanah dan kacang pohon', 'paparan', 'Alergi Makanan', false),
('P23', 'Ikan', 'paparan', 'Alergi Makanan', false),
('P24', 'Udang, kepiting, dan kerang', 'paparan', 'Alergi Makanan', false),
('P25', 'Gandum dan kedelai', 'paparan', 'Alergi Makanan', false),

-- Alergi Hewan
('P30', 'Kucing', 'paparan', 'Alergi Hewan', false),
('P31', 'Anjing', 'paparan', 'Alergi Hewan', false),
('P32', 'Hewan pengerat tertentu', 'paparan', 'Alergi Hewan', false),
('P33', 'Sengatan atau gigitan serangga', 'paparan', 'Alergi Hewan', true), -- gigitan serangga bisa red flag (anafilaksis)

-- Alergi / Produk Kontak
('P40', 'Pewangi parfum dan kosmetik', 'paparan', 'Alergi Produk Kontak', false),
('P41', 'Pengawet dalam produk perawatan', 'paparan', 'Alergi Produk Kontak', false),
('P42', 'Nikel pada perhiasan', 'paparan', 'Alergi Produk Kontak', false),
('P43', 'Lateks pada sarung tangan / produk medis', 'paparan', 'Alergi Produk Kontak', false),
('P44', 'Bahan kimia tertentu dalam produk kerja', 'paparan', 'Alergi Produk Kontak', false),

-- Alergi Obat
('P50', 'Antibiotik tertentu (Misal: Penisilin)', 'paparan', 'Alergi Obat', true), -- Obat sering red flag
('P51', 'Obat antinyeri tertentu (Misal: NSAID)', 'paparan', 'Alergi Obat', true),
('P52', 'Obat lain sesuai riwayat medis', 'paparan', 'Alergi Obat', true)
ON CONFLICT (code) DO UPDATE 
SET label = EXCLUDED.label, group_name = EXCLUDED.group_name, is_red_flag = EXCLUDED.is_red_flag;

-- Update Group Names for existing old facts (if needed, or leave as General)
UPDATE facts SET group_name = 'Gejala Umum' WHERE code LIKE 'G%';
UPDATE facts SET group_name = 'Kondisi / Aktivitas' WHERE code LIKE 'A%' OR code LIKE 'W%';

-- Tambahkan Rule Spesifik Baru berdasarkan kategori Sayyid
INSERT INTO rules (id, title, conclusion, explanation, category, is_candidate, required_facts, supporting_facts) VALUES
('R10', 'Alergen Obat (Antibiotik / Antinyeri)', 'KANDIDAT_ALERGI_OBAT', 'Reaksi alergi muncul pasca konsumsi antibiotik atau antinyeri. Perlu pengawasan medis ketat.', 'Alergi Obat', true, ARRAY['GEJALA_KULIT'], ARRAY['P50', 'P51', 'P52', 'G07', 'G08']),
('R11', 'Alergen Sengatan Serangga', 'KANDIDAT_GIGITAN_SERANGGA', 'Reaksi bengkak parah atau sesak akibat sengatan tawon, lebah, atau serangga lain.', 'Alergi Hewan', true, ARRAY['P33'], ARRAY['G07', 'G08', 'W01']),
('R12', 'Alergen Seafood', 'KANDIDAT_SEAFOOD', 'Reaksi akibat konsumsi udang, kepiting, atau kerang yang memicu reaksi pencernaan atau kulit.', 'Alergi Makanan', true, ARRAY['P24'], ARRAY['GEJALA_PENCERNAAN', 'GEJALA_KULIT', 'W01']),
('R13', 'Alergen Susu / Telur', 'KANDIDAT_DAIRY_EGG', 'Reaksi pasca konsumsi susu sapi atau telur.', 'Alergi Makanan', true, ARRAY['GEJALA_PENCERNAAN'], ARRAY['P20', 'P21', 'GEJALA_KULIT']),
('R14', 'Alergen Asap Rokok', 'KANDIDAT_ASAP_ROKOK', 'Paparan asap rokok memicu masalah pernapasan signifikan.', 'Alergi Lingkungan', true, ARRAY['P14', 'GEJALA_PERNAPASAN_ATAS'], ARRAY['W01', 'W02'])
ON CONFLICT (id) DO UPDATE 
SET title = EXCLUDED.title, explanation = EXCLUDED.explanation, category = EXCLUDED.category, required_facts = EXCLUDED.required_facts;
