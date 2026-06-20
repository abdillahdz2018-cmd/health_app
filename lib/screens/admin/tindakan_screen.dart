import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class TindakanScreen extends StatefulWidget {
  const TindakanScreen({super.key});

  @override
  State<TindakanScreen> createState() => _TindakanScreenState();
}

class _TindakanScreenState extends State<TindakanScreen> {
  List<dynamic> _tindakanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTindakan();
  }

  Future<void> _fetchTindakan() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/admin/tindakan');
      if (response['success'] == true) {
        setState(() {
          _tindakanList = response['data'] as List;
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

  Future<void> _updateStatus(int id, String status) async {
    try {
      final response = await ApiService.put(
        '/admin/tindakan/$id/status',
        {'status_tindakan': status},
      );
      if (response['success'] == true) {
        _fetchTindakan();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showBuatTindakanDialog() {
    final targetRtController = TextEditingController();
    final targetRwController = TextEditingController();
    final deskripsiController = TextEditingController();
    final tanggalController = TextEditingController();
    String selectedJenis = 'Kerja Bakti';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Tindakan Lingkungan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Target RT',
                      controller: targetRtController,
                      hint: '003',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Target RW',
                      controller: targetRwController,
                      hint: '012',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const Text(
                'Jenis Tindakan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              StatefulBuilder(
                builder: (context, setStateDialog) =>
                    DropdownButtonFormField<String>(
                  value: selectedJenis,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Kerja Bakti', child: Text('Kerja Bakti')),
                    DropdownMenuItem(
                        value: 'Fogging', child: Text('Fogging')),
                    DropdownMenuItem(
                        value: 'Penyuluhan Sanitasi',
                        child: Text('Penyuluhan Sanitasi')),
                    DropdownMenuItem(
                        value: 'Pembagian Abate',
                        child: Text('Pembagian Abate')),
                    DropdownMenuItem(
                        value: 'Lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (value) {
                    setStateDialog(() => selectedJenis = value!);
                  },
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Deskripsi Kegiatan',
                controller: deskripsiController,
                hint: 'Jelaskan rencana kegiatan',
                maxLines: 3,
              ),
              CustomTextField(
                label: 'Tanggal Rencana',
                controller: tanggalController,
                hint: 'YYYY-MM-DD',
                keyboardType: TextInputType.datetime,
                prefixIcon: Icons.calendar_today,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (targetRtController.text.isEmpty ||
                  targetRwController.text.isEmpty ||
                  deskripsiController.text.isEmpty ||
                  tanggalController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua field wajib diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final response = await ApiService.post('/admin/tindakan', {
                'target_rt': targetRtController.text.trim(),
                'target_rw': targetRwController.text.trim(),
                'jenis_tindakan': selectedJenis,
                'deskripsi_kegiatan': deskripsiController.text.trim(),
                'tanggal_rencana': tanggalController.text.trim(),
              });

              if (!context.mounted) return;
              Navigator.pop(context);

              if (response['success'] == true) {
                _fetchTindakan();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tindakan berhasil dibuat'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response['message'] ?? 'Gagal'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Berjalan':
        return Colors.blue;
      case 'Batal':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tindakan Lingkungan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBuatTindakanDialog,
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tindakanList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada tindakan lingkungan',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchTindakan,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tindakanList.length,
                    itemBuilder: (context, index) {
                      final tindakan = _tindakanList[index];
                      final status = tindakan['status_tindakan'];
                      final color = _statusColor(status);

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
                                    tindakan['jenis_tindakan'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: color),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                          color: color, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(tindakan['deskripsi_kegiatan']),
                              const SizedBox(height: 4),
                              Text(
                                'RT ${tindakan['target_rt']} / RW ${tindakan['target_rw']} • ${tindakan['tanggal_rencana']}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              if (status != 'Selesai' && status != 'Batal')
                                Row(
                                  children: [
                                    if (status == 'Direncanakan')
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _updateStatus(
                                              tindakan['id'], 'Berjalan'),
                                          child: const Text('Mulai'),
                                        ),
                                      ),
                                    if (status == 'Berjalan') ...[
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _updateStatus(
                                              tindakan['id'], 'Selesai'),
                                          style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.green),
                                          child: const Text('Selesai'),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _updateStatus(
                                            tindakan['id'], 'Batal'),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red),
                                        child: const Text('Batal'),
                                      ),
                                    ),
                                  ],
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