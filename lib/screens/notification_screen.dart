import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_item.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => isLoading = true);
    final data = await ApiService.getNotifications();
    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  Future<void> _markAsRead(String id, bool isRead) async {
    if (isRead) return;
    bool sukses = await ApiService.markNotificationAsRead(id);
    if (sukses) {
      _fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Belum ada notifikasi",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];

                      return Card(
                        elevation: notif.isRead ? 0 : 2,
                        color: notif.isRead
                            ? colorScheme.surface
                            : colorScheme.primary.withOpacity(0.05),
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: notif.isRead
                                ? Colors.transparent
                                : colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: notif.isRead
                                ? Colors.grey.shade300
                                : colorScheme.primary.withOpacity(0.2),
                            child: Icon(
                              Icons.notifications,
                              color: notif.isRead
                                  ? Colors.grey
                                  : colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              notif.message,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.black54,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await _markAsRead(
                              notif.id.toString(),
                              notif.isRead,
                            );

                            if (notif.isPrescriptionApproved) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              bool isUsed = prefs.getBool(
                                      'resep_used_${notif.id}') ??
                                  false;

                              if (isUsed) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Resep ini sudah pernah dimasukkan ke keranjang!",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                final navigator = Navigator.of(
                                  context,
                                  rootNavigator: true,
                                );
                                final messenger = ScaffoldMessenger.of(context);

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  final allMedicines =
                                      await ApiService.getMedicines();
                                  dynamic obatTarget;

                                  for (var obat in allMedicines) {
                                    if (notif.message.toLowerCase().contains(
                                      obat.nama.toLowerCase(),
                                    )) {
                                      obatTarget = obat;
                                      break;
                                    }
                                  }

                                  navigator.pop();

                                  if (obatTarget != null) {
                                    await CartService.addToCart(obatTarget);
                                    await prefs.setBool(
                                      'resep_used_${notif.id}',
                                      true,
                                    );

                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${obatTarget.nama} berhasil dimasukkan ke keranjang!",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Resep Disetujui"),
                                          content: const Text(
                                            "Resep Anda valid. Silakan cari obat tersebut di beranda dan tambahkan ke keranjang secara manual.",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Tutup"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  navigator.pop();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Terjadi kesalahan jaringan saat mengambil obat.",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } else {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(notif.title),
                                    content: Text(notif.message),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Tutup"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
