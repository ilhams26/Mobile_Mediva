import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../utils/currency_formatter.dart';
import 'upload_resep_screen.dart';

class ObatDetailScreen extends StatelessWidget {
  final Medicine obat;

  const ObatDetailScreen({super.key, required this.obat});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // JALUR GAMBAR VPS
    String imageUrl = "${ApiService.storageUrl}/${obat.foto}";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Obat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
              child: obat.foto != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.medication_liquid,
                        size: 100,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.medication_liquid,
                      size: 100,
                      color: Colors.grey,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (obat.isObatKeras)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "K",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  Text(
                    obat.nama,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rp ${formatRupiah(obat.harga)}",
                        style: TextStyle(
                          fontSize: 22,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // INFO STOK TAMPIL DI SINI
                      Text(
                        "Stok: ${obat.stokTotal}",
                        style: TextStyle(
                          fontSize: 16,
                          color: obat.isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Deskripsi Obat:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    obat.deskripsi ?? "Tidak ada deskripsi obat.",
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),

                  if (obat.isObatKeras) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "Peringatan:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Ini adalah obat keras. Anda wajib melampirkan resep dokter untuk membeli.",
                      style: TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: obat.isObatKeras
                ? ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadResepScreen(
                            obatId: obat.id.toString(),
                            namaObat: obat.nama,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.document_scanner),
                    label: const Text(
                      "Upload Resep untuk Beli",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await CartService.addToCart(obat);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${obat.nama} masuk keranjang!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context); // Balik ke Home
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Gagal memasukkan ke keranjang"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text(
                      "Tambah ke Keranjang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
