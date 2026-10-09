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

  factory ExpertRule.fromMap(Map<String, dynamic> map) {
    return ExpertRule(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      conclusion: map['conclusion'] as String? ?? '',
      explanation: map['explanation'] as String? ?? '',
      isCandidate: map['is_candidate'] as bool? ?? false,
      requiredFacts: _parseSet(map['required_facts']),
      supportingFacts: _parseSet(map['supporting_facts']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'conclusion': conclusion,
      'explanation': explanation,
      'is_candidate': isCandidate,
      'required_facts': requiredFacts.toList(),
      'supporting_facts': supportingFacts.toList(),
    };
  }

  static Set<String> _parseSet(dynamic val) {
    if (val == null) return {};
    if (val is List) return val.map((e) => e.toString()).toSet();
    return {};
  }

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

  Map<String, dynamic> toMap() {
    return {
      'rule_id': rule.id,
      'title': rule.title,
      'conclusion': rule.conclusion,
      'explanation': rule.explanation,
      'score': score,
    };
  }
}

const List<ExpertRule> builtInRules = [
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
    explanation:
        'Berada di ruangan lembap atau berjamur memunculkan gejala pernapasan.',
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
