/// Model pesanan dari API `/orders`.
class Order {
  final int id;
  final String orderCode;
  final String status;
  final String paymentStatus;
  final String metodePembayaran;
  final double totalHarga;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.paymentStatus,
    required this.metodePembayaran,
    required this.totalHarga,
    required this.items,
  });

  /// Apakah pesanan ini sedang aktif (belum selesai/dibatalkan).
  bool get isActive =>
      status == 'diproses' || status == 'siap_diambil';

  /// Apakah pesanan menunggu pembayaran Midtrans.
  bool get isWaitingPayment =>
      paymentStatus == 'unpaid' && metodePembayaran == 'midtrans';

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] as List<dynamic>? ?? [];
    return Order(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      orderCode: json['order_code'] ?? '-',
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      metodePembayaran: json['metode_pembayaran'] ?? '',
      totalHarga: double.tryParse(json['total_harga'].toString()) ?? 0,
      items: rawItems.map((e) => OrderItem.fromJson(e)).toList(),
    );
  }

  /// Teks ringkasan item pesanan, contoh: "2x Paracetamol, 1x Amoxicillin".
  String get itemsSummary {
    if (items.isEmpty) return 'Tidak ada detail obat';
    return items.map((i) => '${i.qty}x ${i.namaObat}').join(', ');
  }
}

/// Model item di dalam pesanan.
class OrderItem {
  final int id;
  final int qty;
  final double harga;
  final double subtotal;
  final String namaObat;

  const OrderItem({
    required this.id,
    required this.qty,
    required this.harga,
    required this.subtotal,
    required this.namaObat,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final obat = json['obat'] as Map<String, dynamic>? ?? {};
    return OrderItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      qty: int.tryParse(json['qty'].toString()) ?? 0,
      harga: double.tryParse(json['harga'].toString()) ?? 0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      namaObat: obat['nama'] ?? 'Obat',
    );
  }
}
