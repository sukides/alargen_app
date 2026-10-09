import '../config/supabase_config.dart';
import '../models/fact.dart';
import '../models/rule.dart';
import '../models/consultation.dart';

class ExpertSystemService {
  bool isConnected = false;

  Future<List<Fact>> fetchFacts() async {
    final client = SupabaseConfig.client;
    if (client == null) {
      isConnected = false;
      return builtInFacts;
    }

    try {
      final response = await client.from('facts').select().order('code');
      final List<Fact> facts = (response as List)
          .map((e) => Fact.fromMap(e))
          .toList();
      isConnected = true;
      return facts.isNotEmpty ? facts : builtInFacts;
    } catch (e) {
      isConnected = false;
      return builtInFacts;
    }
  }

  Future<List<ExpertRule>> fetchRules() async {
    final client = SupabaseConfig.client;
    if (client == null) {
      isConnected = false;
      return builtInRules;
    }

    try {
      final response = await client.from('rules').select().order('id');
      final List<ExpertRule> rules = (response as List)
          .map((e) => ExpertRule.fromMap(e))
          .toList();
      isConnected = true;
      return rules.isNotEmpty ? rules : builtInRules;
    } catch (e) {
      isConnected = false;
      return builtInRules;
    }
  }

  Future<bool> saveConsultation(Consultation consultation) async {
    final client = SupabaseConfig.client;
    if (client == null) return false;

    try {
      await client.from('consultations').insert(consultation.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  bool checkRedFlag(Set<String> facts, List<Fact> allFacts) {
    // Dynamically check isRedFlag from fact list
    for (var f in allFacts) {
      if (f.isRedFlag && facts.contains(f.code)) return true;
    }

    // Pola Anafilaksis fallback (G07 + (G05 OR G06 OR P05))
    if (facts.contains('G07') &&
        (facts.contains('G05') ||
            facts.contains('G06') ||
            facts.contains('P05'))) {
      return true;
    }

    return false;
  }

  List<CandidateResult> runForwardChaining(
    Set<String> initialFacts,
    List<ExpertRule> rules,
  ) {
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
          bool conditionMet = false;
          if (rule.requiredFacts.isNotEmpty) {
            conditionMet = rule.requiredFacts.every((f) => facts.contains(f));
            if (rule.supportingFacts.isNotEmpty) {
              conditionMet =
                  conditionMet &&
                  rule.supportingFacts.any((f) => facts.contains(f));
            }
          } else if (rule.supportingFacts.isNotEmpty) {
            conditionMet = rule.supportingFacts.any((f) => facts.contains(f));
          }

          if (conditionMet) {
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
