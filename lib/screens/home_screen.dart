import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../utils/currency_formatter.dart';
import 'cart_screen.dart';
import 'notification_screen.dart';
import 'obat_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Medicine> medicines = [];
  bool isLoading = true;
  int unreadNotifCount = 0;

  String? currentSearch;
  int? currentKategoriId;
  String namaUser = "Pengguna";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final unreadCount = await ApiService.getUnreadNotificationCount();
    final profileData = await ApiService.getProfile();
    final data = await ApiService.getMedicines(
      search: currentSearch,
      kategoriId: currentKategoriId,
    );

    setState(() {
      if (profileData != null) {
        namaUser = profileData.username;
      }
      medicines = data;
      unreadNotifCount = unreadCount;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/Logo_Mediva.png', height: 40),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                  _fetchData();
                },
              ),
              if (unreadNotifCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadNotifCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ).then((_) => _fetchData()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $namaUser!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  currentSearch = value;
                  _fetchData();
                },
                decoration: InputDecoration(
                  hintText: 'Cari obat...',
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Kategori",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip("Semua", null, colorScheme, isDark),
                    _buildCategoryChip("Obat Bebas", 1, colorScheme, isDark),
                    _buildCategoryChip("Obat Keras", 2, colorScheme, isDark),
                    _buildCategoryChip("Vitamin", 3, colorScheme, isDark),
                    _buildCategoryChip(
                      "Alat Kesehatan",
                      4,
                      colorScheme,
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Katalog Obat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : medicines.isEmpty
                  ? const Center(child: Text("Obat tidak ditemukan"))
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: medicines.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemBuilder: (context, index) {
                        final obat = medicines[index];
                        final imageUrl =
                            "${ApiService.storageUrl}/${obat.foto}";

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ObatDetailScreen(obat: obat),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.primary),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.medication,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        obat.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Rp ${formatRupiah(obat.harga)}",
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (obat.isObatKeras) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Obat Keras! Wajib lampirkan resep di halaman detail.",
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange,
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ObatDetailScreen(
                                                    obat: obat,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              try {
                                                await CartService.addToCart(
                                                  obat,
                                                );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "${obat.nama} berhasil ditambah ke keranjang!",
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                      duration: const Duration(
                                                        seconds: 1,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Gagal masuk keranjang, coba lagi.",
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          child: const Text("Tambah"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    String title,
    int? kategoriId,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    bool isSelected = currentKategoriId == kategoriId;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        onSelected: (bool value) {
          setState(() {
            currentKategoriId = kategoriId;
            _fetchData();
          });
        },
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surface,
      ),
    );
  }
}
