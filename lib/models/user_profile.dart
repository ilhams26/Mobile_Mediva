/// Model profil pengguna dari API `/me`.
class UserProfile {
  final int id;
  final String username;
  final String? noHp;
  final String? tanggalLahir;
  final String? jenisKelamin;

  const UserProfile({
    required this.id,
    required this.username,
    this.noHp,
    this.tanggalLahir,
    this.jenisKelamin,
  });

  /// Format nomor HP tanpa awalan '0' untuk ditampilkan dengan prefix +62.
  String get formattedPhone {
    if (noHp == null || noHp!.isEmpty) return '';
    return noHp!.startsWith('0') ? noHp!.substring(1) : noHp!;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      username: json['username'] ?? 'User',
      noHp: json['no_hp'],
      tanggalLahir: json['tanggal_lahir'],
      jenisKelamin: json['jenis_kelamin'],
    );
  }
}
