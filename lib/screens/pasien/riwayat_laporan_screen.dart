import 'package:flutter/material.dart';
import '../../models/laporan.dart';
import '../../services/api_service.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  List<Laporan> _laporanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/laporan/saya');
      if (response['success'] == true) {
        setState(() {
          _laporanList = (response['data'] as List)
              .map((e) => Laporan.fromJson(e))
              .toList();
        });
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

  Color _statusColor(String status) {
    switch (status) {
      case 'terkonfirmasi':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'terkonfirmasi':
        return 'Terkonfirmasi';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _laporanList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada laporan',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchLaporan,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _laporanList.length,
                    itemBuilder: (context, index) {
                      final laporan = _laporanList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Laporan #${laporan.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                              laporan.statusKonfirmasi)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _statusColor(
                                            laporan.statusKonfirmasi),
                                      ),
                                    ),
                                    child: Text(
                                      _statusLabel(laporan.statusKonfirmasi),
                                      style: TextStyle(
                                        color: _statusColor(
                                            laporan.statusKonfirmasi),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                laporan.keluhanPasien,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tanggal: ${laporan.tanggalLapor}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              if (laporan.diagnosisFinal != null) ...[
                                const Divider(),
                                Text(
                                  'Diagnosis: ${laporan.diagnosisFinal}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                              if (laporan.namaPemeriksa != null)
                                Text(
                                  'Diperiksa oleh: ${laporan.namaPemeriksa}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}