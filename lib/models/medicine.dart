/// Model data obat dari API `/obats`.
class Medicine {
  final int id;
  final String nama;
  final String? deskripsi;
  final double harga;
  final String jenis;
  final String? foto;
  final int stokTotal;
  final int? categoryId;

  const Medicine({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.harga,
    required this.jenis,
    this.foto,
    required this.stokTotal,
    this.categoryId,
  });

  /// Apakah obat ini termasuk obat keras yang membutuhkan resep.
  bool get isObatKeras => jenis == 'keras';

  /// Apakah stok masih tersedia.
  bool get isAvailable => stokTotal > 0;

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama: json['nama'] ?? 'Tanpa Nama',
      deskripsi: json['deskripsi'],
      harga: double.tryParse(json['harga'].toString()) ?? 0,
      jenis: json['jenis'] ?? 'bebas',
      foto: json['foto'],
      stokTotal: int.tryParse(json['stok_total']?.toString() ?? '0') ?? 0,
      categoryId: json['category_id'] != null
          ? int.tryParse(json['category_id'].toString())
          : null,
    );
  }

  /// Konversi ke Map untuk kebutuhan penyimpanan lokal (keranjang).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'jenis': jenis,
      'foto': foto,
      'stok_total': stokTotal,
      'category_id': categoryId,
    };
  }
}
