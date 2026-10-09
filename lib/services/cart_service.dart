import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/cart_item.dart';
import '../models/medicine.dart';

// Service untuk mengelola keranjang belanja di penyimpanan lokal.
class CartService {
  CartService._();

  // Tambah obat ke keranjang. Jika sudah ada, qty bertambah 1.
  static Future<void> addToCart(Medicine medicine) async {
    final items = await getCart();

    final index = items.indexWhere((item) => item.id == medicine.id);

    if (index != -1) {
      if (items[index].qty < medicine.stokTotal) {
        items[index].qty++;
      }
    } else {
      items.add(CartItem(
        id: medicine.id,
        nama: medicine.nama,
        harga: medicine.harga,
        qty: 1,
        stokTotal: medicine.stokTotal,
        selected: true,
      ));
    }

    await saveCart(items);
  }

  // Tambah obat ke keranjang dari data mentah
  static Future<void> addToCartFromRaw(Map<String, dynamic> obat) async {
    final medicine = Medicine.fromJson(obat);
    await addToCart(medicine);
  }

  // Ambil semua item dari keranjang.
  static Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cartStringList =
        prefs.getStringList(ApiConfig.cartKey) ?? [];

    final List<CartItem> items = [];
    for (final str in cartStringList) {
      try {
        items.add(CartItem.fromJson(
          Map<String, dynamic>.from(json.decode(str)),
        ));
      } catch (e) {
        debugPrint('Error parsing cart item: $e');
      }
    }
    return items;
  }

  // Simpan cart items ke penyimpanan lokal.
  static Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded =
        items.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(ApiConfig.cartKey, encoded);
  }

  // Hapus item tertentu berdasarkan ID
  static Future<void> removeItems(List<int> ids) async {
    final items = await getCart();
    items.removeWhere((item) => ids.contains(item.id));
    await saveCart(items);
  }

  /// Kosongkan keranjang
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.cartKey);
  }
}
