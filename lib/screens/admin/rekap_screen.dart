import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RekapScreen extends StatefulWidget {
  const RekapScreen({super.key});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  List<dynamic> _rekapList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRekap();
  }

  Future<void> _fetchRekap() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/admin/rekap');
      if (response['success'] == true) {
        setState(() {
          _rekapList = response['data'] as List;
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

  Color _getWarningColor(int jumlah) {
    if (jumlah >= 5) return Colors.red;
    if (jumlah >= 3) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Penyakit'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rekapList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada data penyakit terkonfirmasi',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchRekap,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rekapList.length,
                    itemBuilder: (context, index) {
                      final rekap = _rekapList[index];
                      final jumlah = rekap['jumlah_penderita'] as int;
                      final color = _getWarningColor(jumlah);

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
                                  Expanded(
                                    child: Text(
                                      rekap['diagnosis_final'] ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: color),
                                    ),
                                    child: Text(
                                      '$jumlah kasus',
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.nature_outlined,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      rekap['penyebab_lingkungan'] ?? '-',
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                ],
                              ),
                              if (rekap['rt_terdampak'] != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      'RT terdampak: ${rekap['rt_terdampak']}',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                              if (jumlah >= 3) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber,
                                          color: color, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        jumlah >= 5
                                            ? 'Perlu tindakan segera!'
                                            : 'Perlu perhatian',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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