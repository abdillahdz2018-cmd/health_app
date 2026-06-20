import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/laporan.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'konfirmasi_screen.dart';

class NakesHomeScreen extends StatefulWidget {
  const NakesHomeScreen({super.key});

  @override
  State<NakesHomeScreen> createState() => _NakesHomeScreenState();
}

class _NakesHomeScreenState extends State<NakesHomeScreen> {
  List<Laporan> _laporanList = [];
  bool _isLoading = true;
  String _selectedStatus = 'menunggu';

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await ApiService.get('/nakes/laporan?status=$_selectedStatus');
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Dashboard Nakes'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade700,
            child: Text(
              'Selamat datang, ${user?.namaLengkap ?? '-'}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          // Filter Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'menunggu', child: Text('Menunggu')),
                      DropdownMenuItem(
                          value: 'terkonfirmasi', child: Text('Terkonfirmasi')),
                      DropdownMenuItem(
                          value: 'ditolak', child: Text('Ditolak')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                      _fetchLaporan();
                    },
                  ),
                ),
              ],
            ),
          ),

          // List Laporan
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _laporanList.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada laporan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchLaporan,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _laporanList.length,
                          itemBuilder: (context, index) {
                            final laporan = _laporanList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Laporan #${laporan.id}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
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
                                        laporan.statusKonfirmasi,
                                        style: TextStyle(
                                          color: _statusColor(
                                              laporan.statusKonfirmasi),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      laporan.keluhanPasien,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'RT ${laporan.laporRt} / RW ${laporan.laporRw} • ${laporan.tanggalLapor}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                onTap: laporan.statusKonfirmasi == 'menunggu'
                                    ? () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => KonfirmasiScreen(
                                                laporan: laporan),
                                          ),
                                        );
                                        if (result == true) _fetchLaporan();
                                      }
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}