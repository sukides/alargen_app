import 'package:flutter/material.dart';

import '../models/fact.dart';
import '../models/rule.dart';
import '../models/consultation.dart';
import '../services/expert_system_service.dart';
import 'result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final ExpertSystemService _expertService = ExpertSystemService();
  List<Fact> _facts = List.of(builtInFacts);
  List<ExpertRule> _rules = List.of(builtInRules);
  bool _isRefreshing = false;

  final Map<String, bool> _answers = {};

  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _otherNotesController = TextEditingController();

  bool _isRedFlagActive = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal dengan built-in data agar instan & offline-ready
    _initAnswers(_facts);
    _loadData();
  }

  void _initAnswers(List<Fact> facts) {
    for (var fact in facts) {
      if (fact.category != FactCategory.none &&
          fact.category != FactCategory.turunan) {
        _answers.putIfAbsent(fact.code, () => false);
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isRefreshing = true);
    try {
      final facts = await _expertService.fetchFacts();
      final rules = await _expertService.fetchRules();

      if (mounted) {
        setState(() {
          _facts = facts;
          _rules = rules;
          _initAnswers(_facts);
          _isRedFlagActive = _expertService.checkRedFlag(_buildFacts(), _facts);
          _isRefreshing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _foodController.dispose();
    _productController.dispose();
    _otherNotesController.dispose();
    super.dispose();
  }

  void _setAnswer(String code, bool value) {
    setState(() {
      _answers[code] = value;
      _isRedFlagActive = _expertService.checkRedFlag(_buildFacts(), _facts);
    });
  }

  Set<String> _buildFacts() {
    final facts = <String>{};
    _answers.forEach((code, value) {
      if (value) facts.add(code);
    });

    // Keyword extraction sederhana dari teks
    final foodText = _foodController.text.toLowerCase();
    if (foodText.contains('telur') ||
        foodText.contains('susu') ||
        foodText.contains('udang') ||
        foodText.contains('kacang')) {
      facts.add('P05'); // otomatis nambahin P05 jika nulis makanan
    }

    return facts;
  }

  Future<void> _showResults() async {
    final facts = _buildFacts();

    if (facts.where((f) => f.startsWith('G') || f.startsWith('P')).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih setidaknya satu gejala (G) dan satu paparan (P).',
          ),
        ),
      );
      return;
    }

    // Tampilkan loading overlay saat memproses & menyimpan
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final candidates = _expertService.runForwardChaining(facts, _rules);

    final consultation = Consultation(
      patientName: _patientNameController.text.trim(),
      selectedFacts: facts.toList(),
      foodDescription: _foodController.text.trim(),
      productDescription: _productController.text.trim(),
      notes: _otherNotesController.text.trim(),
      isRedFlag: _isRedFlagActive,
      resultCandidates: candidates,
    );

    final saved = await _expertService.saveConsultation(consultation);

    if (mounted) {
      Navigator.of(context).pop(); // Tutup loading dialog
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            candidates: candidates,
            isRedFlag: _isRedFlagActive,
            foodDescription: _foodController.text.trim(),
            productDescription: _productController.text.trim(),
            notes: _otherNotesController.text.trim(),
            isSavedToCloud: saved,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Fact> gejala = _facts
        .where((f) => f.category == FactCategory.gejala)
        .toList();
    List<Fact> paparan = _facts
        .where((f) => f.category == FactCategory.paparan)
        .toList();
    List<Fact> aktivitas = _facts
        .where((f) => f.category == FactCategory.aktivitas)
        .toList();
    List<Fact> waktu = _facts
        .where((f) => f.category == FactCategory.waktu)
        .toList();

    // Grouping paparan by groupName (Sayyid's Allergen Categories)
    final Map<String, List<Fact>> paparanGrouped = {};
    for (var fact in paparan) {
      final group = fact.groupName ?? 'Faktor Paparan Lainnya';
      paparanGrouped.putIfAbsent(group, () => []).add(fact);
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (!_expertService.isConnected) _buildOfflineNotice(),
                    if (!_expertService.isConnected) const SizedBox(height: 18),
                    if (_isRedFlagActive) _buildSafetyNotice(),
                    if (_isRedFlagActive) const SizedBox(height: 18),

                    _buildTextField(
                      controller: _patientNameController,
                      label: 'Nama Pasien / Pengguna (opsional)',
                      hint: 'Masukkan nama Anda',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    _buildQuestionSection(
                      title: '1. Gejala yang dialami',
                      subtitle: 'Pilih semua gejala yang sesuai.',
                      icon: Icons.health_and_safety_outlined,
                      facts: gejala,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      '2. Faktor Paparan Alergen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF167D8D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih satu atau lebih kategori paparan yang Anda alami.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),

                    ...paparanGrouped.entries.map((entry) {
                      IconData groupIcon = Icons.bubble_chart_outlined;
                      if (entry.key.contains('Makanan')) {
                        groupIcon = Icons.restaurant;
                      } else if (entry.key.contains('Lingkungan')) {
                        groupIcon = Icons.park_outlined;
                      } else if (entry.key.contains('Hewan')) {
                        groupIcon = Icons.pets_outlined;
                      } else if (entry.key.contains('Kontak')) {
                        groupIcon = Icons.dry_cleaning_outlined;
                      } else if (entry.key.contains('Obat')) {
                        groupIcon = Icons.medication_outlined;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildQuestionSection(
                          title: entry.key,
                          subtitle: 'Centang semua yang pernah dialami.',
                          icon: groupIcon,
                          facts: entry.value,
                        ),
                      );
                    }),

                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _foodController,
                      label: 'Makanan spesifik yang dikonsumsi (opsional)',
                      hint: 'Contoh: udang balado, susu sapi murni',
                      icon: Icons.restaurant,
                      onChanged: (_) => setState(
                        () => _isRedFlagActive = _expertService.checkRedFlag(
                          _buildFacts(),
                          _facts,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _productController,
                      label: 'Produk/Obat spesifik yang digunakan (opsional)',
                      hint: 'Contoh: parfum merk X, obat parasetamol Y',
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
                      subtitle:
                          'Jawab berdasarkan pengalaman yang sudah terjadi.',
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
                          _patientNameController.clear();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              if (_expertService.isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_done, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Cloud Sync',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
            children: [
              const HeaderChip(label: 'Forward Chaining'),
              const HeaderChip(label: 'Match Score'),
              const HeaderChip(label: 'Real-time Alert'),
              if (_isRefreshing) const HeaderChip(label: 'Memuat data...'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_off, color: Color(0xFF64748B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mode Offline Aktif\n'
              'Gagal terhubung ke Supabase. Menggunakan data pakar bawaan (built-in). Hasil analisis tidak akan disimpan ke cloud.',
              style: TextStyle(
                color: Color(0xFF475569),
                height: 1.45,
                fontSize: 13,
              ),
            ),
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
              'PERINGATAN DARURAT (REDFLAG)\n\n'
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
    if (facts.isEmpty) return const SizedBox.shrink();
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
                    color: fact.isRedFlag
                        ? const Color(0xFFD32F2F)
                        : Colors.black87,
                    fontWeight: fact.isRedFlag
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                activeColor: fact.isRedFlag
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF167D8D),
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
