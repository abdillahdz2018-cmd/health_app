class Laporan {
  final int id;
  final String keluhanPasien;
  final String statusKonfirmasi;
  final String? diagnosisFinal;
  final String? penyebabLingkungan;
  final String? catatanMedis;
  final Map<String, dynamic>? hasilAnalisisLlm;
  final String tanggalLapor;
  final String? tanggalKonfirmasi;
  final String? namaPemeriksa;
  final String? namaPasien;
  final String laporRt;
  final String laporRw;

  Laporan({
    required this.id,
    required this.keluhanPasien,
    required this.statusKonfirmasi,
    this.diagnosisFinal,
    this.penyebabLingkungan,
    this.catatanMedis,
    this.hasilAnalisisLlm,
    required this.tanggalLapor,
    this.tanggalKonfirmasi,
    this.namaPemeriksa,
    this.namaPasien,
    required this.laporRt,
    required this.laporRw,
  });

  factory Laporan.fromJson(Map<String, dynamic> json) {
    return Laporan(
      id: json['id'],
      keluhanPasien: json['keluhan_pasien'],
      statusKonfirmasi: json['status_konfirmasi'],
      diagnosisFinal: json['diagnosis_final'],
      penyebabLingkungan: json['penyebab_lingkungan'],
      catatanMedis: json['catatan_medis'],
      hasilAnalisisLlm: json['hasil_analisis_llm'] != null
          ? Map<String, dynamic>.from(json['hasil_analisis_llm'])
          : null,
      tanggalLapor: json['tanggal_lapor'],
      tanggalKonfirmasi: json['tanggal_konfirmasi'],
      namaPemeriksa: json['nama_pemeriksa'],
      namaPasien: json['nama_pasien'],
      laporRt: json['lapor_rt'],
      laporRw: json['lapor_rw'],
    );
  }
}