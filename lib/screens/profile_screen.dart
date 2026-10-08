import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    final data = await ApiService.getProfile();
    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Image.asset('assets/images/Logo_Mediva.png', height: 30),
            const SizedBox(width: 10),
            const Text(
              "Mediva",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aplikasi Apotek Digital berbasis Mobile untuk memudahkan transaksi kesehatan Anda.",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            const Text(
              "Dikembangkan Oleh:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("1. M. Ilham Ghazali Simarmata"),
            const Text("2. Tsaabita Parisya Mauladi Aziz"),
            const Text("3. Ai Siti Nur Paojiah"),
            const SizedBox(height: 15),
            const Text(
              "Mitra Resmi:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("Apotek Mediva"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: colorScheme.surface,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.secondary.withOpacity(
                            0.2,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          userData?.username ?? "User",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "+62 ${userData?.formattedPhone ?? ''}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    color: colorScheme.surface,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.edit_outlined,
                            color: colorScheme.primary,
                          ),
                          title: const Text("Edit Profil & Password"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfileScreen(userData: userData),
                              ),
                            );

                            if (result == true) {
                              _loadProfile();
                            }
                          },
                        ),
                        const Divider(height: 1),

                        ListTile(
                          leading: Icon(
                            Icons.dark_mode_outlined,
                            color: colorScheme.primary,
                          ),
                          title: const Text("Mode Gelap"),
                          trailing: Switch(
                            activeThumbColor: colorScheme.primary,
                            value: themeNotifier.value == ThemeMode.dark,
                            onChanged: (val) => themeNotifier.value = val
                                ? ThemeMode.dark
                                : ThemeMode.light,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                          ),
                          title: const Text("Tentang Aplikasi"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: _showAboutDialog,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            "Keluar Akun",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.remove('token');
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (r) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
