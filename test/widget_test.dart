import 'package:flutter_test/flutter_test.dart';
import 'package:alargen_app/main.dart';

void main() {
  group('Sistem Pakar Inferensi & RuleBase Tests', () {
    test('Red flag harus terdeteksi jika ada kesulitan bernapas (G08)', () {
      final facts = {'G08', 'P01'};
      expect(RuleBase.checkRedFlag(facts), isTrue);
    });

    test('Red flag harus terdeteksi pada pola anafilaksis (G07 + G05 + P05)', () {
      final facts = {'G07', 'G05', 'P05'};
      expect(RuleBase.checkRedFlag(facts), isTrue);
    });

    test('Red flag tidak terpicu untuk alergi debu ringan tanpa komplikasi', () {
      final facts = {'G01', 'G02', 'P01', 'A01'};
      expect(RuleBase.checkRedFlag(facts), isFalse);
    });

    test('Forward Chaining menghasilkan kandidat debu & tungau dengan score kecocokan', () {
      // G01 memicu GEJALA_PERNAPASAN_ATAS (turunan L1)
      // Bersama P01 dan A01, memicu KANDIDAT_DEBU_TUNGAU
      final facts = {'G01', 'P01', 'A01', 'W01'};
      final results = InferenceEngine.runForwardChaining(facts);

      expect(results, isNotEmpty);
      expect(results.first.rule.conclusion, equals('KANDIDAT_DEBU_TUNGAU'));
      expect(results.first.score, greaterThan(0.5));
    });

    test('Forward Chaining kandidat makanan dan perhitungan score multi-faktor', () {
      // P05 + G04 (memicu GEJALA_KULIT)
      final facts = {'P05', 'G04', 'W01'};
      final results = InferenceEngine.runForwardChaining(facts);

      expect(results, isNotEmpty);
      final foodResult = results.firstWhere((r) => r.rule.conclusion == 'KANDIDAT_PEMICU_MAKANAN');
      expect(foodResult.score, greaterThan(0.0));
    });
  });

  testWidgets('App smoke test & initial render', (WidgetTester tester) async {
    await tester.pumpWidget(const AllergyExpertApp());
    expect(find.text('Sistem Pakar Pemicu Alergi'), findsOneWidget);
    expect(find.text('Forward Chaining'), findsOneWidget);
  });
}
