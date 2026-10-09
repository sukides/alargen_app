import 'package:flutter/material.dart';

import '../models/rule.dart';

class ResultScreen extends StatelessWidget {
  final List<CandidateResult> candidates;
  final bool isRedFlag;
  final String foodDescription;
  final String productDescription;
  final String notes;
  final bool isSavedToCloud;

  const ResultScreen({
    super.key,
    required this.candidates,
    required this.isRedFlag,
    required this.foodDescription,
    required this.productDescription,
    required this.notes,
    this.isSavedToCloud = false,
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

              _buildCloudSyncStatus(),
              const SizedBox(height: 16),

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

  Widget _buildCloudSyncStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSavedToCloud
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSavedToCloud ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: isSavedToCloud
                ? const Color(0xFF2E7D32)
                : const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Text(
            isSavedToCloud
                ? 'Riwayat tersimpan ke Cloud (Supabase)'
                : 'Tidak tersimpan ke Cloud (Offline Mode)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSavedToCloud
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isHighConfidence
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isHighConfidence
                              ? 'Cocok $percentage%'
                              : 'Sebagian ($percentage%)',
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
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F7),
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
    if (foodDescription.isEmpty &&
        productDescription.isEmpty &&
        notes.isEmpty) {
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
          if (notes.isNotEmpty) _buildNoteItem(Icons.notes, 'Lainnya: $notes'),
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
