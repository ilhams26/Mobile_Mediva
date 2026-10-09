// Model item keranjang yang disimpan secara lokal di SharedPreferences.
class CartItem {
  final int id;
  final String nama;
  final double harga;
  int qty;
  final int stokTotal;
  bool selected;

  CartItem({
    required this.id,
    required this.nama,
    required this.harga,
    this.qty = 1,
    this.stokTotal = 999,
    this.selected = true,
  });

  double get subtotal => harga * qty;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama: json['nama'] ?? 'Tanpa Nama',
      harga: double.tryParse(json['harga'].toString()) ?? 0,
      qty: int.tryParse(json['qty'].toString()) ?? 1,
      stokTotal: int.tryParse(json['stok_total'].toString()) ?? 999,
      selected: json['selected'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'qty': qty,
      'stok_total': stokTotal,
      'selected': selected,
    };
  }

  /// Konversi ke format yang diharapkan Laravel saat checkout.
  Map<String, dynamic> toCheckoutPayload() {
    return {'obat_id': id, 'qty': qty};
  }
}
