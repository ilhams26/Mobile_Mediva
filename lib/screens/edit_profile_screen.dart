import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile? userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller Profil
  late TextEditingController nameController;
  late TextEditingController dobController;
  String? selectedGender;

  // Controller Password
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  bool _isObscureOld = true;
  bool _isObscureNew = true;

  @override
  void initState() {
    super.initState();
    String tglLahir = widget.userData?.tanggalLahir ?? '';
    if (tglLahir.contains('T')) tglLahir = tglLahir.split('T')[0];

    nameController = TextEditingController(text: widget.userData?.username);
    dobController = TextEditingController(text: tglLahir);

    String? genderAsli = widget.userData?.jenisKelamin;
    if (genderAsli != null &&
        (genderAsli.toUpperCase() == 'L' || genderAsli.toUpperCase() == 'P')) {
      selectedGender = genderAsli.toUpperCase();
    }
  }

  void _simpanProfil() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Menyimpan profil...')));
    bool sukses = await ApiService.updateProfile(
      nameController.text,
      dobController.text,
      selectedGender ?? '',
    );

    if (sukses) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembali bawa nilai true
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _simpanPassword() async {
    if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi semua kolom password!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (newPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru minimal 6 karakter!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mengubah password...')));
    bool sukses = await ApiService.changePassword(
      oldPassController.text,
      newPassController.text,
    );

    if (sukses) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diubah!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      oldPassController.clear();
      newPassController.clear();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password lama salah atau terjadi kesalahan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil & Keamanan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KARTU EDIT PROFIL ---
            const Text(
              "Data Pribadi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: dobController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tanggal Lahir',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2006, 1, 26),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(
                    () => dobController.text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}",
                  );
                }
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: selectedGender,
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin',
                prefixIcon: Icon(Icons.wc),
              ),
              items: const [
                DropdownMenuItem(value: 'L', child: Text("Laki-laki")),
                DropdownMenuItem(value: 'P', child: Text("Perempuan")),
              ],
              onChanged: (val) => setState(() => selectedGender = val),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _simpanProfil,
                child: const Text("Simpan Profil"),
              ),
            ),

            const Divider(height: 50, thickness: 1),

            // --- KARTU GANTI PASSWORD ---
            const Text(
              "Ganti Password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: oldPassController,
              obscureText: _isObscureOld,
              decoration: InputDecoration(
                labelText: 'Password Lama',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscureOld ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _isObscureOld = !_isObscureOld),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: newPassController,
              obscureText: _isObscureNew,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _isObscureNew = !_isObscureNew),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
                onPressed: _simpanPassword,
                child: const Text("Ubah Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
