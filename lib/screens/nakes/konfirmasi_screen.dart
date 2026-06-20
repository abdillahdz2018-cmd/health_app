import 'package:flutter/material.dart';
import '../../models/laporan.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class KonfirmasiScreen extends StatefulWidget {
  final Laporan laporan;

  const KonfirmasiScreen({super.key, required this.laporan});

  @override
  State<KonfirmasiScreen> createState() => _KonfirmasiScreenState();
}

class _KonfirmasiScreenState extends State<KonfirmasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _penyebabController = TextEditingController();
  final _catatanController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill dari hasil LLM jika ada
    final llm = widget.laporan.hasilAnalisisLlm;
    if (llm != null) {
      _diagnosisController.text = llm['diagnosis_sementara'] ?? '';
      _penyebabController.text = llm['penyebab_lingkungan'] ?? '';
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _penyebabController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _konfirmasi(String status) async {
    if (status == 'terkonfirmasi' && !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.put(
        '/nakes/laporan/${widget.laporan.id}/konfirmasi',
        {
          'status_konfirmasi': status,
          if (status == 'terkonfirmasi') ...{
            'diagnosis_final': _diagnosisController.text.trim(),
            'penyebab_lingkungan': _penyebabController.text.trim(),
          },
          if (_catatanController.text.isNotEmpty)
            'catatan_medis': _catatanController.text.trim(),
        },
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final laporan = widget.laporan;
    final llm = laporan.hasilAnalisisLlm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Laporan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Laporan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laporan #${laporan.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RT ${laporan.laporRt} / RW ${laporan.laporRw}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Divider(height: 16),
                    const Text(
                      'Keluhan Pasien:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(laporan.keluhanPasien),
                  ],
                ),
              ),

              // Hasil Analisis LLM
              if (llm != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.smart_toy, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Saran AI',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Diagnosis: ${llm['diagnosis_sementara'] ?? '-'}'),
                      Text(
                          'Penyebab: ${llm['penyebab_lingkungan'] ?? '-'}'),
                      Text(
                          'Urgensi: ${llm['tingkat_urgensi'] ?? '-'}'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Text(
                'Isi Diagnosis Final',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Diagnosis Final',
                controller: _diagnosisController,
                hint: 'Contoh: Demam Berdarah Dengue (DBD)',
                prefixIcon: Icons.medical_information_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Diagnosis final wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Penyebab Lingkungan',
                controller: _penyebabController,
                hint: 'Contoh: Genangan air dan jentik nyamuk',
                prefixIcon: Icons.nature_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Penyebab lingkungan wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Catatan Medis (Opsional)',
                controller: _catatanController,
                hint: 'Tambahkan catatan medis jika perlu',
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Konfirmasi Diagnosis',
                onPressed: () => _konfirmasi('terkonfirmasi'),
                isLoading: _isLoading,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Tolak Laporan',
                onPressed: () => _konfirmasi('ditolak'),
                isLoading: _isLoading,
                color: Colors.red.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}