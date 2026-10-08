import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../screens/midtrans_screen.dart';
import 'api_service.dart';
import 'cart_service.dart';

/// Hasil checkout yang dikembalikan ke caller.
class CheckoutResult {
  final bool success;
  final String? errorMessage;

  const CheckoutResult({required this.success, this.errorMessage});
}

/// Service untuk memproses checkout dan pembayaran Midtrans.
///
/// Berbeda dengan versi sebelumnya, service ini tidak lagi menampilkan
/// SnackBar secara langsung — caller yang bertanggung jawab atas UI feedback.
/// Satu-satunya interaksi UI adalah navigasi ke MidtransPaymentScreen
/// karena membutuhkan BuildContext.
class OrderService {
  OrderService._();

  /// Proses checkout melalui Midtrans.
  ///
  /// Mengirim data keranjang ke API, lalu membuka halaman pembayaran Midtrans.
  /// Mengembalikan [CheckoutResult] yang menunjukkan sukses/gagal.
  static Future<CheckoutResult> checkoutMidtrans(
    BuildContext context,
    List<CartItem> selectedItems,
  ) async {
    try {
      final payload = selectedItems
          .map((item) => item.toCheckoutPayload())
          .toList();

      final data = await ApiService.checkoutMidtrans(payload);

      if (data == null) {
        return const CheckoutResult(
          success: false,
          errorMessage: 'Checkout gagal. Silakan coba lagi.',
        );
      }

      final String snapToken = data['snap_token'];
      final String orderCode = data['order_code'];

      if (!context.mounted) {
        return const CheckoutResult(success: false);
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MidtransPaymentScreen(
            snapToken: snapToken,
            orderCode: orderCode,
          ),
        ),
      );

      if (result == true) {
        // Bersihkan item yang sudah dibayar dari keranjang
        final boughtIds = selectedItems.map((e) => e.id).toList();
        await CartService.removeItems(boughtIds);
        return const CheckoutResult(success: true);
      }

      return const CheckoutResult(success: false);
    } catch (e) {
      return const CheckoutResult(
        success: false,
        errorMessage: 'Terjadi kesalahan. Cek koneksi Anda.',
      );
    }
  }
}
