enum FactCategory { gejala, paparan, aktivitas, waktu, turunan, none }

class Fact {
  final String code;
  final String label;
  final FactCategory category;
  final String? groupName;
  final bool isRedFlag;

  const Fact(
    this.code,
    this.label,
    this.category, {
    this.groupName,
    this.isRedFlag = false,
  });

  factory Fact.fromMap(Map<String, dynamic> map) {
    return Fact(
      map['code'] as String? ?? '',
      map['label'] as String? ?? '',
      _parseCategory(map['category'] as String?),
      groupName: map['group_name'] as String?,
      isRedFlag: map['is_red_flag'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'label': label,
      'category': category.name,
      'group_name': groupName,
      'is_red_flag': isRedFlag,
    };
  }

  static FactCategory _parseCategory(String? catStr) {
    if (catStr == null) return FactCategory.none;
    switch (catStr.toLowerCase()) {
      case 'gejala':
        return FactCategory.gejala;
      case 'paparan':
        return FactCategory.paparan;
      case 'aktivitas':
        return FactCategory.aktivitas;
      case 'waktu':
        return FactCategory.waktu;
      case 'turunan':
        return FactCategory.turunan;
      default:
        return FactCategory.none;
    }
  }
}

const List<Fact> builtInFacts = [
  // Gejala
  Fact('G01', 'Bersin berulang', FactCategory.gejala),
  Fact('G02', 'Hidung berair atau tersumbat', FactCategory.gejala),
  Fact('G03', 'Mata gatal atau berair', FactCategory.gejala),
  Fact('G04', 'Kulit gatal atau kemerahan', FactCategory.gejala),
  Fact('G05', 'Bentol atau biduran', FactCategory.gejala),
  Fact('G06', 'Mual, muntah, atau nyeri perut', FactCategory.gejala),
  Fact(
    'G07',
    'Bengkak pada bibir atau wajah',
    FactCategory.gejala,
    isRedFlag: true,
  ),
  Fact(
    'G08',
    'Sulit bernapas / tenggorokan menyempit',
    FactCategory.gejala,
    isRedFlag: true,
  ),
  Fact(
    'G09',
    'Pusing berat / lemas / hampir pingsan',
    FactCategory.gejala,
    isRedFlag: true,
  ),

  // Paparan Lingkungan
  Fact('P01', 'Terpapar debu atau tungau', FactCategory.paparan),
  Fact(
    'P02',
    'Berada dekat kucing, anjing, atau hewan lain',
    FactCategory.paparan,
  ),
  Fact('P03', 'Terpapar tanaman atau serbuk sari', FactCategory.paparan),
  Fact('P04', 'Berada di ruangan lembap atau berjamur', FactCategory.paparan),
  Fact(
    'P05',
    'Mengonsumsi makanan tertentu sebelum gejala',
    FactCategory.paparan,
  ),
  Fact(
    'P06',
    'Menggunakan sabun, kosmetik, parfum, atau losion',
    FactCategory.paparan,
  ),

  // Aktivitas
  Fact('A01', 'Membersihkan kamar atau ruangan', FactCategory.aktivitas),
  Fact('A02', 'Berkebun atau beraktivitas di luar', FactCategory.aktivitas),
  Fact('A03', 'Berinteraksi dengan hewan', FactCategory.aktivitas),

  // Waktu & Pola
  Fact('W01', 'Gejala muncul saat atau setelah paparan', FactCategory.waktu),
  Fact('W02', 'Gejala berulang pada paparan serupa', FactCategory.waktu),
  Fact('W03', 'Lokasi gejala sesuai area paparan/kontak', FactCategory.waktu),
];
