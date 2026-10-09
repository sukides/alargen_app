import 'package:flutter/material.dart';

import 'config/supabase_config.dart';
import 'models/fact.dart';
import 'models/rule.dart';
import 'services/expert_system_service.dart';
import 'screens/questionnaire_screen.dart';

export 'config/supabase_config.dart';
export 'models/fact.dart';
export 'models/rule.dart';
export 'models/consultation.dart';
export 'services/expert_system_service.dart';
export 'screens/questionnaire_screen.dart';
export 'screens/result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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
            borderSide: const BorderSide(color: Color(0xFF167D8D), width: 1.5),
          ),
        ),
      ),
      home: const QuestionnaireScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// BACKWARDS-COMPATIBILITY ADAPTERS FOR TEST SUITE & LEGACY CALLERS
// -----------------------------------------------------------------------------

class RuleBase {
  static const List<Fact> definedFacts = builtInFacts;

  static Fact? getFactByCode(String code) {
    try {
      return definedFacts.firstWhere((f) => f.code == code);
    } catch (_) {
      return null;
    }
  }

  static bool checkRedFlag(Set<String> facts) {
    return ExpertSystemService().checkRedFlag(facts, definedFacts);
  }
}

class InferenceEngine {
  static const List<ExpertRule> rules = builtInRules;

  static List<CandidateResult> runForwardChaining(Set<String> initialFacts) {
    return ExpertSystemService().runForwardChaining(initialFacts, rules);
  }
}
