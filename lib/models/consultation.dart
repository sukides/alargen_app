import 'rule.dart';

class Consultation {
  final String? id;
  final String? patientName;
  final List<String> selectedFacts;
  final String? foodDescription;
  final String? productDescription;
  final String? notes;
  final bool isRedFlag;
  final List<CandidateResult> resultCandidates;
  final DateTime? createdAt;

  Consultation({
    this.id,
    this.patientName,
    required this.selectedFacts,
    this.foodDescription,
    this.productDescription,
    this.notes,
    this.isRedFlag = false,
    required this.resultCandidates,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (patientName != null && patientName!.isNotEmpty)
        'patient_name': patientName,
      'selected_facts': selectedFacts,
      if (foodDescription != null && foodDescription!.isNotEmpty)
        'food_description': foodDescription,
      if (productDescription != null && productDescription!.isNotEmpty)
        'product_description': productDescription,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'is_red_flag': isRedFlag,
      'result_candidates': resultCandidates.map((c) => c.toMap()).toList(),
    };
  }
}
