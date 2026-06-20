class User {
  final int id;
  final String username;
  final String email;
  final String namaLengkap;
  final String role;
  final String noRt;
  final String noRw;
  final String kelurahan;
  final String kecamatan;
  final String? noTelepon;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.namaLengkap,
    required this.role,
    required this.noRt,
    required this.noRw,
    required this.kelurahan,
    required this.kecamatan,
    this.noTelepon,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      namaLengkap: json['nama_lengkap'],
      role: json['role'],
      noRt: json['no_rt'],
      noRw: json['no_rw'],
      kelurahan: json['kelurahan'],
      kecamatan: json['kecamatan'],
      noTelepon: json['no_telepon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nama_lengkap': namaLengkap,
      'role': role,
      'no_rt': noRt,
      'no_rw': noRw,
      'kelurahan': kelurahan,
      'kecamatan': kecamatan,
      'no_telepon': noTelepon,
    };
  }
}