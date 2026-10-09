import 'package:flutter/material.dart';

void main() {
  runApp(const AllergyExpertApp());
}

class AllergyExpertApp extends StatelessWidget {
  const AllergyExpertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistem Pakar Pemicu Alergi',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF167D8D),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCE4EA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCE4EA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF167D8D),
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const QuestionnaireScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// MODEL DATA & KNOWLEDGE BASE (SINGLE SOURCE OF TRUTH)
// -----------------------------------------------------------------------------

enum FactCategory { gejala, paparan, aktivitas, waktu, turunan, none }

class Fact {
  final String code;
  final String label;
  final FactCategory category;
  final bool isRedFlag;

  const Fact(this.code, this.label, this.category, {this.isRedFlag = false});
}

class RuleBase {
  // SINGLE SOURCE OF TRUTH untuk definisi fakta
  static const List<Fact> definedFacts = [
    // Gejala
    Fact('G01', 'Bersin berulang', FactCategory.gejala),
    Fact('G02', 'Hidung berair atau tersumbat', FactCategory.gejala),
    Fact('G03', 'Mata gatal atau berair', FactCategory.gejala),
    Fact('G04', 'Kulit gatal atau kemerahan', FactCategory.gejala),
    Fact('G05', 'Bentol atau biduran', FactCategory.gejala),
    Fact('G06', 'Mual, muntah, atau nyeri perut', FactCategory.gejala),
    Fact('G07', 'Bengkak pada bibir atau wajah', FactCategory.gejala, isRedFlag: true),
    Fact('G08', 'Sulit bernapas / tenggorokan menyempit', FactCategory.gejala, isRedFlag: true),
    Fact('G09', 'Pusing berat / lemas / hampir pingsan', FactCategory.gejala, isRedFlag: true),

    // Paparan Lingkungan
    Fact('P01', 'Terpapar debu atau tungau', FactCategory.paparan),
    Fact('P02', 'Berada dekat kucing, anjing, atau hewan lain', FactCategory.paparan),
    Fact('P03', 'Terpapar tanaman atau serbuk sari', FactCategory.paparan),
    Fact('P04', 'Berada di ruangan lembap atau berjamur', FactCategory.paparan),
    Fact('P05', 'Mengonsumsi makanan tertentu sebelum gejala', FactCategory.paparan),
    Fact('P06', 'Menggunakan sabun, kosmetik, parfum, atau losion', FactCategory.paparan),

    // Aktivitas
    Fact('A01', 'Membersihkan kamar atau ruangan', FactCategory.aktivitas),
    Fact('A02', 'Berkebun atau beraktivitas di luar', FactCategory.aktivitas),
    Fact('A03', 'Berinteraksi dengan hewan', FactCategory.aktivitas),

    // Waktu & Pola
    Fact('W01', 'Gejala muncul saat atau setelah paparan', FactCategory.waktu),
    Fact('W02', 'Gejala berulang pada paparan serupa', FactCategory.waktu),
    Fact('W03', 'Lokasi gejala sesuai area paparan/kontak', FactCategory.waktu),
  ];

  static Fact? getFactByCode(String code) {
    try {
      return definedFacts.firstWhere((f) => f.code == code);
    } catch (_) {
      return null;
    }
  }

  static bool checkRedFlag(Set<String> facts) {
    if (facts.contains('G08') || facts.contains('G09')) return true;
    if (facts.contains('G07') &&
        (facts.contains('G05') || facts.contains('G06') || facts.contains('P05'))) {
      return true; // Pola Anafilaksis
    }
    return false;
  }
}

class ExpertRule {
  final String id;
  final Set<String> requiredFacts;
  final Set<String> supportingFacts;
  final String conclusion;
  final String title;
  final String explanation;
  final bool isCandidate;

  const ExpertRule({
    required this.id,
    required this.requiredFacts,
    this.supportingFacts = const {},
    required this.conclusion,
    required this.title,
    required this.explanation,
    this.isCandidate = false,
  });

  // Calculate Match Score (0.0 to 1.0)
  double matchScore(Set<String> facts) {
    if (requiredFacts.isNotEmpty) {
      bool hasAllRequired = requiredFacts.every((f) => facts.contains(f));
      if (!hasAllRequired) return 0.0;
    }

    if (supportingFacts.isEmpty) return 1.0;

    int matchCount = supportingFacts.where((f) => facts.contains(f)).length;
    return matchCount / supportingFacts.length;
  }
}

class CandidateResult {
  final ExpertRule rule;
  final double score;

  const CandidateResult(this.rule, this.score);
}

class InferenceEngine {
  static const List<ExpertRule> rules = [
    // STAGE 1: FAKTA TURUNAN (DERIVED FACTS)
    ExpertRule(
      id: 'L1-01',
      requiredFacts: {},
      supportingFacts: {'G01', 'G02', 'G03'},
      conclusion: 'GEJALA_PERNAPASAN_ATAS',
      title: 'Gejala Pernapasan',
      explanation: 'Pasien mengalami gejala pernapasan atas.',
    ),
    ExpertRule(
      id: 'L1-02',
      requiredFacts: {},
      supportingFacts: {'G04', 'G05'},
      conclusion: 'GEJALA_KULIT',
      title: 'Gejala Kulit',
      explanation: 'Pasien mengalami keluhan pada kulit.',
    ),
    ExpertRule(
      id: 'L1-03',
      requiredFacts: {},
      supportingFacts: {'G06'},
      conclusion: 'GEJALA_PENCERNAAN',
      title: 'Gejala Pencernaan',
      explanation: 'Pasien mengalami keluhan pencernaan.',
    ),
    
    // STAGE 2: KANDIDAT PEMICU BERDASARKAN FAKTA DASAR DAN TURUNAN
    ExpertRule(
      id: 'R01',
      requiredFacts: {'GEJALA_PERNAPASAN_ATAS', 'P01'},
      supportingFacts: {'A01', 'W01', 'W02'},
      conclusion: 'KANDIDAT_DEBU_TUNGAU',
      title: 'Debu atau Tungau',
      explanation: 'Paparan debu/tungau memicu gejala pernapasan atas. Aktivitas membersihkan ruangan dan waktu kemunculan gejala mendukung temuan ini.',
      isCandidate: true,
    ),
    ExpertRule(
      id: 'R02',
      requiredFacts: {'GEJALA_PERNAPASAN_ATAS', 'P02'},
      supportingFacts: {'A03', 'W01', 'W02'},
      conclusion: 'KANDIDAT_ALERGEN_HEWAN',
      title: 'Alergen Hewan (Bulu/Saliva)',
      explanation: 'Berada dekat hewan terindikasi memicu gejala pernapasan. Interaksi langsung memperkuat hal ini.',
      isCandidate: true,
    ),
    ExpertRule(
      id: 'R03',
      requiredFacts: {'GEJALA_PERNAPASAN_ATAS', 'P03'},
      supportingFacts: {'A02', 'W01'},
      conclusion: 'KANDIDAT_SERBUK_SARI',
      title: 'Serbuk Sari / Tanaman',
      explanation: 'Beraktivitas di luar ruangan dengan paparan tanaman memicu gejala pernapasan.',
      isCandidate: true,
    ),
    ExpertRule(
      id: 'R04',
      requiredFacts: {'GEJALA_PERNAPASAN_ATAS', 'P04'},
      supportingFacts: {'W01', 'W02'},
      conclusion: 'KANDIDAT_JAMUR_LINGKUNGAN',
      title: 'Jamur Lingkungan',
      explanation: 'Berada di ruangan lembap atau berjamur memunculkan gejala pernapasan.',
      isCandidate: true,
    ),
    ExpertRule(
      id: 'R05',
      requiredFacts: {'P05'},
      supportingFacts: {'GEJALA_KULIT', 'GEJALA_PENCERNAAN', 'W01'},
      conclusion: 'KANDIDAT_PEMICU_MAKANAN',
      title: 'Pemicu Makanan',
      explanation: 'Mengonsumsi makanan tertentu memicu gejala (biasanya kulit atau pencernaan).',
      isCandidate: true,
    ),
    ExpertRule(
      id: 'R06',
      requiredFacts: {'GEJALA_KULIT', 'P06'},
      supportingFacts: {'W01', 'W03'},
      conclusion: 'KANDIDAT_PRODUK_KONTAK',
      title: 'Produk Kontak',
      explanation: 'Penggunaan produk tertentu menyebabkan keluhan pada kulit. Kesesuaian lokasi gejala memperkuat hal ini.',
      isCandidate: true,
    ),
  ];

  static List<CandidateResult> runForwardChaining(Set<String> initialFacts) {
    final facts = <String>{...initialFacts};
    final firedRules = <ExpertRule>[];
    
    // Iterasi Forward Chaining (Max 5 depth untuk menghindari infinite loop)
    bool changed = true;
    int depth = 0;
    while (changed && depth < 5) {
      changed = false;
      depth++;

      for (final rule in rules) {
        if (!rule.isCandidate && !facts.contains(rule.conclusion)) {
          // Aturan turunan (L1) -> butuh minimal 1 supporting fact (OR logic kustom untuk L1)
          if (rule.supportingFacts.any((f) => facts.contains(f))) {
            facts.add(rule.conclusion);
            firedRules.add(rule);
            changed = true;
          }
        }
      }
    }

    // Hitung Match Score untuk Kandidat Pemicu (Stage 2)
    final candidates = <CandidateResult>[];
    for (final rule in rules) {
      if (rule.isCandidate) {
        double score = rule.matchScore(facts);
        if (score > 0) {
          candidates.add(CandidateResult(rule, score));
        }
      }
    }

    // Urutkan kandidat berdasarkan score tertinggi
    candidates.sort((a, b) => b.score.compareTo(a.score));

    return candidates;
  }
}

// -----------------------------------------------------------------------------
// UI SCREEN: KUESIONER
// -----------------------------------------------------------------------------

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final Map<String, bool> _answers = {};

  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _otherNotesController = TextEditingController();

  bool _isRedFlagActive = false;

  @override
  void initState() {
    super.initState();
    // Initialize _answers from RuleBase single source
    for (var fact in RuleBase.definedFacts) {
      if (fact.category != FactCategory.none && fact.category != FactCategory.turunan) {
        _answers[fact.code] = false;
      }
    }
  }

  @override
  void dispose() {
    _foodController.dispose();
    _productController.dispose();
    _otherNotesController.dispose();
    super.dispose();
  }

  void _setAnswer(String code, bool value) {
    setState(() {
      _answers[code] = value;
      _isRedFlagActive = RuleBase.checkRedFlag(_buildFacts());
    });
  }

  Set<String> _buildFacts() {
    final facts = <String>{};
    _answers.forEach((code, value) {
      if (value) facts.add(code);
    });
    
    // Keyword extraction sederhana dari teks
    final foodText = _foodController.text.toLowerCase();
    if (foodText.contains('telur') || foodText.contains('susu') || foodText.contains('udang') || foodText.contains('kacang')) {
      facts.add('P05'); // otomatis nambahin P05 jika nulis makanan
    }

    return facts;
  }

  void _showResults() {
    final facts = _buildFacts();

    if (facts.where((f) => f.startsWith('G') || f.startsWith('P')).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih setidaknya satu gejala (G) dan satu paparan (P).'),
        ),
      );
      return;
    }

    final candidates = InferenceEngine.runForwardChaining(facts);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          candidates: candidates,
          isRedFlag: _isRedFlagActive,
          foodDescription: _foodController.text.trim(),
          productDescription: _productController.text.trim(),
          notes: _otherNotesController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Fact> gejala = RuleBase.definedFacts.where((f) => f.category == FactCategory.gejala).toList();
    List<Fact> paparan = RuleBase.definedFacts.where((f) => f.category == FactCategory.paparan).toList();
    List<Fact> aktivitas = RuleBase.definedFacts.where((f) => f.category == FactCategory.aktivitas).toList();
    List<Fact> waktu = RuleBase.definedFacts.where((f) => f.category == FactCategory.waktu).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_isRedFlagActive) _buildSafetyNotice(),
                  if (_isRedFlagActive) const SizedBox(height: 18),
                  
                  _buildQuestionSection(
                    title: '1. Gejala yang dialami',
                    subtitle: 'Pilih semua gejala yang sesuai.',
                    icon: Icons.health_and_safety_outlined,
                    facts: gejala,
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionSection(
                    title: '2. Faktor lingkungan & Makanan',
                    subtitle: 'Pilih paparan yang pernah terjadi sebelum gejala.',
                    icon: Icons.home_outlined,
                    facts: paparan,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _foodController,
                    label: 'Makanan yang dikonsumsi (opsional)',
                    hint: 'Contoh: telur, susu, udang, kacang',
                    icon: Icons.restaurant,
                    onChanged: (_) => setState(() => _isRedFlagActive = RuleBase.checkRedFlag(_buildFacts())),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _productController,
                    label: 'Produk yang digunakan (opsional)',
                    hint: 'Contoh: sabun atau losion tertentu',
                    icon: Icons.spa_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionSection(
                    title: '3. Aktivitas saat paparan',
                    subtitle: 'Pilih aktivitas yang relevan.',
                    icon: Icons.directions_walk_outlined,
                    facts: aktivitas,
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionSection(
                    title: '4. Waktu dan pola gejala',
                    subtitle: 'Jawab berdasarkan pengalaman yang sudah terjadi.',
                    icon: Icons.schedule_outlined,
                    facts: waktu,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _otherNotesController,
                    label: 'Catatan tambahan (opsional)',
                    hint: 'Tuliskan lokasi, waktu, atau informasi lain',
                    icon: Icons.notes_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _showResults,
                    icon: const Icon(Icons.psychology_outlined),
                    label: const Text('Analisis dengan Forward Chaining'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        for (final key in _answers.keys) {
                          _answers[key] = false;
                        }
                        _foodController.clear();
                        _productController.clear();
                        _otherNotesController.clear();
                        _isRedFlagActive = false;
                      });
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset semua jawaban'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Catatan: aplikasi ini adalah prototipe edukasi. '
                    'Hasilnya bukan diagnosis medis dan aturan contoh belum '
                    'divalidasi secara klinis.',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF126E82), Color(0xFF239A9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Sistem Pakar Pemicu Alergi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Identifikasi kandidat pemicu berdasarkan gejala dan faktor paparan',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              HeaderChip(label: 'Forward Chaining'),
              HeaderChip(label: 'Match Score'),
              HeaderChip(label: 'Real-time Alert'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        border: Border.all(color: const Color(0xFFF4D29D)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'PERINGATAN DARURAT (REDFLAG)\\n\\n'
              'Gejala anafilaksis atau gangguan pernapasan terdeteksi. '
              'Segera cari pertolongan medis darurat! Jangan menunggu hasil analisis.',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                height: 1.45,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Fact> facts,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF167D8D)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...facts.map(
            (fact) => Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                value: _answers[fact.code] ?? false,
                onChanged: (value) => _setAnswer(fact.code, value ?? false),
                title: Text(
                  fact.label,
                  style: TextStyle(
                    fontSize: 14, 
                    height: 1.35,
                    color: fact.isRedFlag ? const Color(0xFFD32F2F) : Colors.black87,
                    fontWeight: fact.isRedFlag ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                activeColor: fact.isRedFlag ? const Color(0xFFD32F2F) : const Color(0xFF167D8D),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class HeaderChip extends StatelessWidget {
  final String label;

  const HeaderChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HALAMAN HASIL (RESULT SCREEN)
// -----------------------------------------------------------------------------

class ResultScreen extends StatelessWidget {
  final List<CandidateResult> candidates;
  final bool isRedFlag;
  final String foodDescription;
  final String productDescription;
  final String notes;

  const ResultScreen({
    super.key,
    required this.candidates,
    required this.isRedFlag,
    required this.foodDescription,
    required this.productDescription,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hasil Analisis',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        shape: const Border(bottom: BorderSide(color: Color(0xFFE2E8EE))),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isRedFlag) _buildRedFlagBanner(),
              if (isRedFlag) const SizedBox(height: 16),
              _buildCandidatesSection(),
              const SizedBox(height: 20),
              _buildNotesSection(),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Kuesioner'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRedFlagBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.medical_services_outlined, color: Color(0xFFD32F2F)),
              SizedBox(width: 8),
              Text(
                'Tindakan Darurat Diperlukan',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Sistem mendeteksi tanda bahaya (seperti sulit bernapas, bengkak wajah, atau pusing berat) yang mungkin merupakan indikasi anafilaksis. Segera hubungi layanan gawat darurat.',
            style: TextStyle(
              color: Color(0xFFB71C1C),
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesSection() {
    if (candidates.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kandidat Pemicu Alergi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2939),
          ),
        ),
        const SizedBox(height: 12),
        ...candidates.map((candidate) {
          final percentage = (candidate.score * 100).toInt();
          final isHighConfidence = candidate.score >= 0.7;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8EE)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          candidate.rule.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2939),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isHighConfidence
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isHighConfidence ? 'Cocok $percentage%' : 'Sebagian ($percentage%)',
                          style: TextStyle(
                            color: isHighConfidence
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE65100),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    candidate.rule.explanation,
                    style: const TextStyle(
                      color: Color(0xFF475467),
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8EE)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_outlined,
              size: 32,
              color: Color(0xFF98A2B3),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak Cukup Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aturan pakar tidak menemukan kandidat pemicu yang cocok dengan '
            'kombinasi gejala dan paparan yang Anda masukkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF667085),
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    if (foodDescription.isEmpty && productDescription.isEmpty && notes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Tambahan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF344054),
            ),
          ),
          const SizedBox(height: 12),
          if (foodDescription.isNotEmpty)
            _buildNoteItem(Icons.restaurant, 'Makanan: $foodDescription'),
          if (productDescription.isNotEmpty)
            _buildNoteItem(Icons.spa_outlined, 'Produk: $productDescription'),
          if (notes.isNotEmpty)
            _buildNoteItem(Icons.notes, 'Lainnya: $notes'),
        ],
      ),
    );
  }

  Widget _buildNoteItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF667085)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF475467),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
