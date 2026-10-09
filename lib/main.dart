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
// MODEL DATA DAN BASIS PENGETAHUAN
// -----------------------------------------------------------------------------

class ExpertRule {
  final String id;
  final Set<String> conditions;
  final String conclusion;
  final String title;
  final String explanation;

  const ExpertRule({
    required this.id,
    required this.conditions,
    required this.conclusion,
    required this.title,
    required this.explanation,
  });
}

class InferenceResult {
  final Set<String> facts;
  final List<ExpertRule> firedRules;
  final Set<String> candidates;

  const InferenceResult({
    required this.facts,
    required this.firedRules,
    required this.candidates,
  });
}

class RuleBase {
  // Catatan: aturan berikut adalah contoh untuk tugas pemrograman.
  // Aturan medis harus ditinjau dan divalidasi sebelum digunakan nyata.
  static const List<ExpertRule> rules = [
    ExpertRule(
      id: 'R01',
      conditions: {'G01', 'P01', 'A01', 'W01'},
      conclusion: 'KANDIDAT_DEBU_TUNGAU',
      title: 'Paparan debu atau tungau',
      explanation:
          'Bersin berulang dilaporkan bersama paparan debu saat membersihkan '
          'ruangan dan gejala muncul saat/setelah paparan.',
    ),
    ExpertRule(
      id: 'R02',
      conditions: {'G01', 'G03', 'P02', 'A03', 'W01'},
      conclusion: 'KANDIDAT_ALERGEN_HEWAN',
      title: 'Paparan hewan',
      explanation:
          'Bersin dan gejala mata dilaporkan bersama paparan hewan dan '
          'interaksi dengan hewan.',
    ),
    ExpertRule(
      id: 'R03',
      conditions: {'G01', 'G03', 'P03', 'A02', 'W01'},
      conclusion: 'KANDIDAT_SERBUK_SARI',
      title: 'Paparan serbuk sari atau tanaman',
      explanation:
          'Bersin dan gejala mata dilaporkan saat beraktivitas di luar '
          'ruangan dengan paparan tanaman/serbuk sari.',
    ),
    ExpertRule(
      id: 'R04',
      conditions: {'G01', 'P04', 'W01', 'W03'},
      conclusion: 'KANDIDAT_JAMUR_LINGKUNGAN',
      title: 'Paparan lingkungan lembap atau berjamur',
      explanation:
          'Bersin dilaporkan bersama paparan lingkungan lembap/berjamur '
          'dan lokasi gejala sesuai area paparan.',
    ),
    ExpertRule(
      id: 'R05A',
      conditions: {'P05', 'W01', 'W02', 'G04'},
      conclusion: 'KANDIDAT_PEMICU_MAKANAN',
      title: 'Paparan makanan sebelum gejala kulit',
      explanation:
          'Ada laporan konsumsi makanan sebelum gejala, pola berulang, '
          'dan gejala kulit. Ini hanya kandidat untuk ditinjau lebih lanjut.',
    ),
    ExpertRule(
      id: 'R05B',
      conditions: {'P05', 'W01', 'W02', 'G05'},
      conclusion: 'KANDIDAT_PEMICU_MAKANAN',
      title: 'Paparan makanan sebelum biduran',
      explanation:
          'Ada laporan konsumsi makanan sebelum gejala, pola berulang, '
          'dan biduran. Ini bukan konfirmasi alergi makanan.',
    ),
    ExpertRule(
      id: 'R05C',
      conditions: {'P05', 'W01', 'W02', 'G06'},
      conclusion: 'KANDIDAT_PEMICU_MAKANAN',
      title: 'Paparan makanan sebelum gejala pencernaan',
      explanation:
          'Ada laporan konsumsi makanan sebelum gejala, pola berulang, '
          'dan keluhan pencernaan. Penyebab lain juga mungkin.',
    ),
    ExpertRule(
      id: 'R06',
      conditions: {'G04', 'P06', 'W01', 'W03'},
      conclusion: 'KANDIDAT_PRODUK_KONTAK',
      title: 'Produk yang bersentuhan dengan kulit',
      explanation:
          'Keluhan kulit dilaporkan di area yang sesuai dengan paparan '
          'produk kontak. Iritasi dan alergi kontak perlu dibedakan.',
    ),
    ExpertRule(
      id: 'R07',
      conditions: {'KANDIDAT_DEBU_TUNGAU', 'W02'},
      conclusion: 'POLA_PAPARAN_BERULANG',
      title: 'Pola paparan berulang',
      explanation:
          'Pola gejala dilaporkan berulang pada paparan serupa. '
          'Pengulangan ini mendukung penelusuran, tetapi tidak membuktikan sebab.',
    ),
  ];
}

// -----------------------------------------------------------------------------
// MESIN INFERENSI FORWARD CHAINING
// -----------------------------------------------------------------------------

InferenceResult runForwardChaining(Set<String> initialFacts) {
  final facts = <String>{...initialFacts};
  final firedRules = <ExpertRule>[];
  final firedRuleIds = <String>{};

  bool changed = true;

  while (changed) {
    changed = false;

    for (final rule in RuleBase.rules) {
      if (firedRuleIds.contains(rule.id)) continue;

      // Aturan hanya aktif jika seluruh kondisi IF terpenuhi.
      final allConditionsSatisfied =
          rule.conditions.every((condition) => facts.contains(condition));

      if (allConditionsSatisfied) {
        firedRuleIds.add(rule.id);
        firedRules.add(rule);

        final addedNewFact = facts.add(rule.conclusion);
        if (addedNewFact) changed = true;
      }
    }
  }

  final candidates = facts
      .where((fact) => fact.startsWith('KANDIDAT_'))
      .toSet();

  return InferenceResult(
    facts: facts,
    firedRules: firedRules,
    candidates: candidates,
  );
}

// -----------------------------------------------------------------------------
// KUESIONER
// -----------------------------------------------------------------------------

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final Map<String, bool> _answers = {
    'G01': false,
    'G02': false,
    'G03': false,
    'G04': false,
    'G05': false,
    'G06': false,
    'G07': false,
    'P01': false,
    'P02': false,
    'P03': false,
    'P04': false,
    'P05': false,
    'P06': false,
    'A01': false,
    'A02': false,
    'A03': false,
    'W01': false,
    'W02': false,
    'W03': false,
  };

  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _otherNotesController = TextEditingController();

  @override
  void dispose() {
    _foodController.dispose();
    _productController.dispose();
    _otherNotesController.dispose();
    super.dispose();
  }

  void _setAnswer(String code, bool value) {
    setState(() => _answers[code] = value);
  }

  Set<String> _buildFacts() {
    final facts = <String>{};
    _answers.forEach((code, value) {
      if (value) facts.add(code);
    });
    return facts;
  }

  void _showResults() {
    final facts = _buildFacts();

    if (facts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih setidaknya satu gejala atau faktor paparan.'),
        ),
      );
      return;
    }

    final result = runForwardChaining(facts);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: result,
          foodDescription: _foodController.text.trim(),
          productDescription: _productController.text.trim(),
          notes: _otherNotesController.text.trim(),
          answers: Map<String, bool>.from(_answers),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSafetyNotice(),
                  const SizedBox(height: 18),
                  _buildQuestionSection(
                    title: '1. Gejala yang dialami',
                    subtitle: 'Pilih semua gejala yang sesuai.',
                    icon: Icons.health_and_safety_outlined,
                    questions: const [
                      QuestionItem('G01', 'Bersin berulang'),
                      QuestionItem('G02', 'Hidung berair atau tersumbat'),
                      QuestionItem('G03', 'Mata gatal atau berair'),
                      QuestionItem('G04', 'Kulit gatal atau kemerahan'),
                      QuestionItem('G05', 'Bentol atau biduran'),
                      QuestionItem('G06', 'Mual, muntah, atau nyeri perut'),
                      QuestionItem('G07', 'Bengkak pada bibir atau wajah'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionSection(
                    title: '2. Faktor lingkungan',
                    subtitle: 'Pilih paparan yang pernah terjadi sebelum gejala.',
                    icon: Icons.home_outlined,
                    questions: const [
                      QuestionItem('P01', 'Terpapar debu atau tungau'),
                      QuestionItem('P02', 'Berada dekat kucing, anjing, atau hewan lain'),
                      QuestionItem('P03', 'Terpapar tanaman atau serbuk sari'),
                      QuestionItem('P04', 'Berada di ruangan lembap atau berjamur'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionSection(
                    title: '3. Makanan dan produk kontak',
                    subtitle: 'Centang jika paparan mendahului gejala.',
                    icon: Icons.restaurant_outlined,
                    questions: const [
                      QuestionItem('P05', 'Mengonsumsi makanan tertentu sebelum gejala'),
                      QuestionItem('P06', 'Menggunakan sabun, kosmetik, parfum, atau losion'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _foodController,
                    label: 'Makanan yang dikonsumsi (opsional)',
                    hint: 'Contoh: telur, susu, udang',
                    icon: Icons.restaurant,
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
                    title: '4. Aktivitas saat paparan',
                    subtitle: 'Pilih aktivitas yang relevan.',
                    icon: Icons.directions_walk_outlined,
                    questions: const [
                      QuestionItem('A01', 'Membersihkan kamar atau ruangan'),
                      QuestionItem('A02', 'Berkebun atau beraktivitas di luar'),
                      QuestionItem('A03', 'Berinteraksi dengan hewan'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionSection(
                    title: '5. Waktu dan pola gejala',
                    subtitle: 'Jawab berdasarkan pengalaman yang sudah terjadi.',
                    icon: Icons.schedule_outlined,
                    questions: const [
                      QuestionItem('W01', 'Gejala muncul saat atau setelah paparan'),
                      QuestionItem('W02', 'Gejala berulang pada paparan serupa'),
                      QuestionItem('W03', 'Lokasi gejala sesuai area paparan/kontak'),
                    ],
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
              HeaderChip(label: 'Multi-faktor'),
              HeaderChip(label: 'Prototipe'),
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
          Icon(Icons.info_outline, color: Color(0xFF9A5B00)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Jika ada kesulitan bernapas, tenggorokan terasa menyempit, '
              'atau lidah/tenggorokan membengkak, segera cari pertolongan '
              'darurat. Jangan menunggu hasil aplikasi.',
              style: TextStyle(
                color: Color(0xFF714500),
                height: 1.45,
                fontSize: 13,
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
    required List<QuestionItem> questions,
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
          ...questions.map(
            (question) => CheckboxListTile(
              value: _answers[question.code] ?? false,
              onChanged: (value) =>
                  _setAnswer(question.code, value ?? false),
              title: Text(
                question.label,
                style: const TextStyle(fontSize: 14, height: 1.35),
              ),
              subtitle: Text(
                question.code,
                style: const TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 11,
                ),
              ),
              activeColor: const Color(0xFF167D8D),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
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
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class QuestionItem {
  final String code;
  final String label;

  const QuestionItem(this.code, this.label);
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
// HALAMAN HASIL
// -----------------------------------------------------------------------------

class ResultScreen extends StatelessWidget {
  final InferenceResult result;
  final String foodDescription;
  final String productDescription;
  final String notes;
  final Map<String, bool> answers;

  const ResultScreen({
    super.key,
    required this.result,
    required this.foodDescription,
    required this.productDescription,
    required this.notes,
    required this.answers,
  });

  static const Map<String, String> _candidateNames = {
    'KANDIDAT_DEBU_TUNGAU': 'Debu atau tungau',
    'KANDIDAT_ALERGEN_HEWAN': 'Paparan hewan',
    'KANDIDAT_SERBUK_SARI': 'Serbuk sari atau tanaman',
    'KANDIDAT_JAMUR_LINGKUNGAN': 'Jamur lingkungan',
    'KANDIDAT_PEMICU_MAKANAN': 'Makanan yang dilaporkan',
    'KANDIDAT_PRODUK_KONTAK': 'Produk yang bersentuhan dengan kulit',
  };

  static const Map<String, String> _factLabels = {
    'G01': 'Bersin berulang',
    'G02': 'Hidung berair atau tersumbat',
    'G03': 'Mata gatal atau berair',
    'G04': 'Kulit gatal atau kemerahan',
    'G05': 'Biduran',
    'G06': 'Gejala pencernaan',
    'G07': 'Pembengkakan bibir atau wajah',
    'P01': 'Paparan debu atau tungau',
    'P02': 'Paparan hewan',
    'P03': 'Paparan tanaman atau serbuk sari',
    'P04': 'Lingkungan lembap atau berjamur',
    'P05': 'Konsumsi makanan sebelum gejala',
    'P06': 'Penggunaan produk kontak',
    'A01': 'Aktivitas membersihkan ruangan',
    'A02': 'Aktivitas luar ruangan atau berkebun',
    'A03': 'Interaksi dengan hewan',
    'W01': 'Gejala muncul saat/setelah paparan',
    'W02': 'Gejala berulang pada paparan serupa',
    'W03': 'Lokasi gejala sesuai area paparan',
  };

  @override
  Widget build(BuildContext context) {  
    final candidateFacts = result.candidates.toList()..sort();
    final emergencyReported = answers['G07'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        backgroundColor: const Color(0xFFF4F7FA),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF126E82), Color(0xFF239A9C)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.fact_check_outlined, color: Colors.white, size: 32),
                SizedBox(height: 12),
                Text(
                  'Hasil penalaran sistem',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Hasil dibuat dengan mencocokkan fakta input terhadap aturan IF–THEN.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (emergencyReported) ...[
            _buildEmergencyCard(),
            const SizedBox(height: 16),
          ],
          _buildSectionCard(
            title: 'Kandidat pemicu',
            icon: Icons.search,
            child: candidateFacts.isEmpty
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi belum cukup untuk menghasilkan kandidat '
                        'berdasarkan aturan yang tersedia.',
                        style: TextStyle(height: 1.5),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ini tidak berarti alergi tidak ada. Aturan sistem '
                        'masih terbatas dan belum mencakup semua kemungkinan.',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: candidateFacts.map((candidate) {
                      final name =
                          _candidateNames[candidate] ?? candidate;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7F5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFCBE8E3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF167D8D),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 14),
          _buildSectionCard(
            title: 'Aturan yang terpenuhi',
            icon: Icons.account_tree_outlined,
            child: result.firedRules.isEmpty
                ? const Text(
                    'Tidak ada aturan IF–THEN yang seluruh kondisinya '
                    'terpenuhi.',
                    style: TextStyle(height: 1.5),
                  )
                : Column(
                    children: result.firedRules.map((rule) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE2E8EE),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${rule.id} · ${rule.title}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF167D8D),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'IF: ${rule.conditions.join(' AND ')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'THEN: ${rule.conclusion}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              rule.explanation,
                              style: const TextStyle(height: 1.45),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 14),
          _buildSectionCard(
            title: 'Fakta yang dipilih',
            icon: Icons.checklist_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: answers.entries
                  .where((entry) => entry.value)
                  .map(
                    (entry) => Chip(
                      label: Text(
                        '${entry.key}: ${_factLabels[entry.key] ?? entry.key}',
                      ),
                      backgroundColor: const Color(0xFFEAF0F5),
                      side: BorderSide.none,
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (foodDescription.isNotEmpty ||
              productDescription.isNotEmpty ||
              notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildSectionCard(
              title: 'Catatan pengguna',
              icon: Icons.notes_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (foodDescription.isNotEmpty)
                    _noteLine('Makanan', foodDescription),
                  if (productDescription.isNotEmpty)
                    _noteLine('Produk', productDescription),
                  if (notes.isNotEmpty) _noteLine('Catatan', notes),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          _buildSectionCard(
            title: 'Batasan hasil',
            icon: Icons.shield_outlined,
            child: const Text(
              'Hasil ini merupakan kandidat berdasarkan aturan contoh, '
              'bukan diagnosis alergi. Aturan IF–THEN belum divalidasi secara '
              'klinis dan hasil tidak menghitung probabilitas. Jangan mencoba '
              'paparan ulang untuk menguji dugaan pemicu. Konsultasikan dengan '
              'tenaga medis untuk penilaian lebih lanjut.',
              style: TextStyle(height: 1.55),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Kembali ke kuesioner'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        border: Border.all(color: const Color(0xFFE9A4A4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFB42318)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kamu menandai pembengkakan bibir atau wajah. Jika pembengkakan '
              'melibatkan lidah/tenggorokan, disertai kesulitan bernapas, '
              'pusing berat, atau memburuk cepat, cari pertolongan darurat '
              'segera. Jangan mengandalkan aplikasi untuk menilai tingkat '
              'kegawatan.',
              style: TextStyle(
                color: Color(0xFF912018),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF167D8D)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _noteLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF344054),
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
