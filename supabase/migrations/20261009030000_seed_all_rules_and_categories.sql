-- Lengkapi seluruh Layer 1 (Aturan Turunan) dan Stage 2 (Kandidat Pemicu Alergi 5 Kategori)
INSERT INTO rules (id, title, conclusion, explanation, category, is_candidate, required_facts, supporting_facts) VALUES
-- Stage 1: Fakta Turunan (Intermediate Deductions)
('L1-01', 'Gejala Pernapasan Atas', 'GEJALA_PERNAPASAN_ATAS', 'Pasien terindikasi mengalami gejala pernapasan atas.', 'Gejala Umum', false, '{}', ARRAY['G01', 'G02', 'G03']),
('L1-02', 'Gejala Kulit', 'GEJALA_KULIT', 'Pasien terindikasi mengalami keluhan/reaksi pada kulit.', 'Gejala Umum', false, '{}', ARRAY['G04', 'G05', 'G07']),
('L1-03', 'Gejala Pencernaan', 'GEJALA_PENCERNAAN', 'Pasien terindikasi mengalami gangguan pencernaan.', 'Gejala Umum', false, '{}', ARRAY['G06']),
('L1-04', 'Gejala Sesak / Red Flag Napas', 'GEJALA_SESAK', 'Pasien mengalami kesulitan bernapas / penyempitan jalan napas.', 'Gejala Umum', false, '{}', ARRAY['G08']),

-- Stage 2: Kategori 1 - Alergi Lingkungan
('R01', 'Alergen Debu & Tungau', 'KANDIDAT_DEBU_TUNGAU', 'Paparan debu atau tungau rumah memicu gejala pernapasan. Aktivitas membersihkan ruangan memperkuat temuan ini.', 'Alergi Lingkungan', true, ARRAY['P10'], ARRAY['GEJALA_PERNAPASAN_ATAS', 'A01', 'W01', 'W02']),
('R03', 'Alergen Serbuk Sari Tanaman', 'KANDIDAT_SERBUK_SARI', 'Paparan tanaman atau serbuk sari memicu gejala alergi pernapasan/mata saat beraktivitas di luar.', 'Alergi Lingkungan', true, ARRAY['P11'], ARRAY['GEJALA_PERNAPASAN_ATAS', 'A02', 'W01']),
('R04', 'Alergen Jamur & Spora', 'KANDIDAT_JAMUR_SPORA', 'Keberadaan di ruangan lembap/berjamur memicu reaksi alergi.', 'Alergi Lingkungan', true, ARRAY['P13'], ARRAY['GEJALA_PERNAPASAN_ATAS', 'W01', 'W02']),
('R14', 'Alergen Asap Rokok', 'KANDIDAT_ASAP_ROKOK', 'Paparan asap rokok memicu iritasi saluran pernapasan signifikan.', 'Alergi Lingkungan', true, ARRAY['P14'], ARRAY['GEJALA_PERNAPASAN_ATAS', 'GEJALA_SESAK', 'W01', 'W02']),

-- Stage 2: Kategori 2 - Alergi Makanan
('R05', 'Pemicu Makanan Umum', 'KANDIDAT_MAKANAN_UMUM', 'Konsumsi makanan tertentu memicu reaksi alergi.', 'Alergi Makanan', true, ARRAY['P05'], ARRAY['GEJALA_KULIT', 'GEJALA_PENCERNAAN', 'W01']),
('R12', 'Alergen Seafood (Udang / Kepiting / Kerang)', 'KANDIDAT_SEAFOOD', 'Konsumsi seafood memicu reaksi alergi akut pada kulit atau saluran cerna.', 'Alergi Makanan', true, ARRAY['P24'], ARRAY['GEJALA_KULIT', 'GEJALA_PENCERNAAN', 'G07', 'W01']),
('R13', 'Alergen Susu Sapi', 'KANDIDAT_SUSU_SAPI', 'Konsumsi susu sapi memicu keluhan pencernaan atau gatal/bentol.', 'Alergi Makanan', true, ARRAY['P20'], ARRAY['GEJALA_PENCERNAAN', 'GEJALA_KULIT', 'W01']),
('R15', 'Alergen Telur', 'KANDIDAT_TELUR', 'Konsumsi telur memicu reaksi alergi kulit atau pencernaan.', 'Alergi Makanan', true, ARRAY['P21'], ARRAY['GEJALA_KULIT', 'GEJALA_PENCERNAAN', 'W01']),
('R16', 'Alergen Kacang Tanah & Pohon', 'KANDIDAT_KACANG', 'Konsumsi kacang memicu reaksi alergi yang dapat berisiko anafilaksis.', 'Alergi Makanan', true, ARRAY['P22'], ARRAY['GEJALA_KULIT', 'G07', 'GEJALA_SESAK', 'W01']),
('R17', 'Alergen Gandum & Kedelai', 'KANDIDAT_GANDUM_KEDELAI', 'Konsumsi produk gandum atau kedelai memicu reaksi tidak nyaman pada pencernaan/kulit.', 'Alergi Makanan', true, ARRAY['P25'], ARRAY['GEJALA_PENCERNAAN', 'GEJALA_KULIT', 'W01']),

-- Stage 2: Kategori 3 - Alergi Hewan & Serangga
('R02', 'Alergen Bulu Hewan (Kucing / Anjing)', 'KANDIDAT_BULU_HEWAN', 'Paparan bulu/kulit hewan memicu alergi pernapasan atau kulit saat berinteraksi.', 'Alergi Hewan', true, ARRAY['P12'], ARRAY['GEJALA_PERNAPASAN_ATAS', 'A03', 'W01', 'W02']),
('R11', 'Alergen Sengatan / Gigitan Serangga', 'KANDIDAT_GIGITAN_SERANGGA', 'Reaksi akut bengkak atau bentol pasca gigitan/sengatan serangga.', 'Alergi Hewan', true, ARRAY['P33'], ARRAY['GEJALA_KULIT', 'G07', 'GEJALA_SESAK', 'W01']),
('R18', 'Alergen Kucing Spesifik', 'KANDIDAT_KUCING', 'Interaksi dekat dengan kucing memicu bersin, mata berair, atau gatal.', 'Alergi Hewan', true, ARRAY['P30'], ARRAY['GEJALA_PERNAPASAN_ATAS', 'A03', 'W01']),
('R19', 'Alergen Anjing Spesifik', 'KANDIDAT_ANJING', 'Interaksi dekat dengan anjing memicu reaksi alergi pernapasan/kulit.', 'Alergi Hewan', true, ARRAY['P31'], ARRAY['GEJALA_PERNAPASAN_ATAS', 'A03', 'W01']),
('R20', 'Alergen Hewan Pengerat / Lainnya', 'KANDIDAT_HEWAN_LAIN', 'Paparan hewan pengerat atau hewan peliharaan lain memicu gejala.', 'Alergi Hewan', true, ARRAY['P32'], ARRAY['GEJALA_PERNAPASAN_ATAS', 'W01']),

-- Stage 2: Kategori 4 - Alergi Produk Kontak
('R06', 'Alergen Pewangi, Sabun & Kosmetik', 'KANDIDAT_KOSMETIK_PARFUM', 'Penggunaan produk perawatan tubuh/kosmetik memicu reaksi dermatitis kontak pada kulit.', 'Alergi Produk Kontak', true, ARRAY['P40'], ARRAY['GEJALA_KULIT', 'W01', 'W03']),
('R21', 'Alergen Pengawet Produk Perawatan', 'KANDIDAT_PENGAWET_PRODUK', 'Bahan pengawet dalam sabun/lotion memicu iritasi kulit berkelanjutan.', 'Alergi Produk Kontak', true, ARRAY['P41'], ARRAY['GEJALA_KULIT', 'W01', 'W03']),
('R22', 'Alergen Nikel pada Perhiasan', 'KANDIDAT_NIKEL', 'Kontak perhiasan atau aksesoris berbahan nikel menimbulkan ruam gatal di area kontak.', 'Alergi Produk Kontak', true, ARRAY['P42'], ARRAY['GEJALA_KULIT', 'W03']),
('R23', 'Alergen Lateks (Sarung Tangan / Karet)', 'KANDIDAT_LATEKS', 'Penggunaan sarung tangan/produk karet memicu gatal kemerahan lokal atau reaksi sistemik.', 'Alergi Produk Kontak', true, ARRAY['P43'], ARRAY['GEJALA_KULIT', 'G07', 'W03']),
('R24', 'Alergen Bahan Kimia Kerja', 'KANDIDAT_KIMIA_KERJA', 'Paparan bahan kimia industri/pembersih memicu dermatitis kontak akibat kerja.', 'Alergi Produk Kontak', true, ARRAY['P44'], ARRAY['GEJALA_KULIT', 'W01', 'W03']),

-- Stage 2: Kategori 5 - Alergi Obat
('R10', 'Alergen Obat Antibiotik (Penisilin, dll)', 'KANDIDAT_ANTIBIOTIK', 'Konsumsi antibiotik memicu erupsi obat pada kulit atau pembengkakan. Butuh evaluasi medis segera.', 'Alergi Obat', true, ARRAY['P50'], ARRAY['GEJALA_KULIT', 'G07', 'GEJALA_SESAK', 'W01']),
('R25', 'Alergen Obat Antinyeri (NSAID / Aspirin)', 'KANDIDAT_OBAT_ANTINYERI', 'Konsumsi obat pereda nyeri/NSAID memicu biduran atau sesak napas.', 'Alergi Obat', true, ARRAY['P51'], ARRAY['GEJALA_KULIT', 'G07', 'GEJALA_SESAK', 'W01']),
('R26', 'Alergen Obat Lainnya', 'KANDIDAT_OBAT_LAIN', 'Riwayat konsumsi obat medis tertentu memicu reaksi alergi.', 'Alergi Obat', true, ARRAY['P52'], ARRAY['GEJALA_KULIT', 'G07', 'W01'])
ON CONFLICT (id) DO UPDATE 
SET title = EXCLUDED.title, conclusion = EXCLUDED.conclusion, explanation = EXCLUDED.explanation, 
    category = EXCLUDED.category, is_candidate = EXCLUDED.is_candidate, 
    required_facts = EXCLUDED.required_facts, supporting_facts = EXCLUDED.supporting_facts;
