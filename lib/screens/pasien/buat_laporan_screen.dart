import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class BuatLaporanScreen extends StatefulWidget {
  const BuatLaporanScreen({super.key});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keluhanController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _hasilAnalisis;

  @override
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
  }

  Future<void> _kirimLaporan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasilAnalisis = null;
    });

    try {
      final response = await ApiService.post('/laporan', {
        'keluhan_pasien': _keluhanController.text.trim(),
      });

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _hasilAnalisis = response['data']['analisis_llm'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dikirim dan dianalisis'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal mengirim laporan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildHasilAnalisis() {
    if (_hasilAnalisis == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 24),
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
                'Hasil Analisis AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const Divider(),
          _buildInfoRow('Diagnosis Sementara',
              _hasilAnalisis!['diagnosis_sementara'] ?? '-'),
          _buildInfoRow('Tingkat Urgensi',
              _hasilAnalisis!['tingkat_urgensi'] ?? '-'),
          _buildInfoRow('Penyebab Lingkungan',
              _hasilAnalisis!['penyebab_lingkungan'] ?? '-'),
          const SizedBox(height: 8),
          const Text(
            'Rekomendasi Tindakan:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...(_hasilAnalisis!['rekomendasi_tindakan'] as List? ?? [])
              .map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(item.toString())),
                      ],
                    ),
                  )),
          const SizedBox(height: 8),
          const Text(
            'Fasilitas Kesehatan Terdekat:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...(_hasilAnalisis!['fasilitas_kesehatan_terdekat'] as List? ?? [])
              .map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                        '• ${item['nama']} (${item['jenis']}) - ${item['estimasi_jarak']}'),
                  )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _hasilAnalisis!['catatan'] ??
                        'Hasil ini bersifat sementara dan harus dikonfirmasi oleh dokter.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan Keluhan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ceritakan keluhan Anda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deskripsikan gejala yang Anda rasakan secara detail agar AI dapat memberikan analisis yang lebih akurat.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Keluhan',
                controller: _keluhanController,
                hint: 'Contoh: Saya demam 3 hari, kepala pusing, muncul bintik merah di kulit...',
                maxLines: 5,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Keluhan wajib diisi' : null,
              ),
              CustomButton(
                label: 'Kirim & Analisis',
                onPressed: _kirimLaporan,
                isLoading: _isLoading,
              ),
              _buildHasilAnalisis(),
            ],
          ),
        ),
      ),
    );
  }
}