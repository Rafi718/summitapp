import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../home/alpine_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.currentUser?.name ?? '');
    _phoneController = TextEditingController(text: auth.currentUser?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      context.read<AuthProvider>().updateProfile(photo: picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 96, height: 96,
                        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(48)),
                        clipBehavior: Clip.antiAlias,
                        child: auth.currentUser?.photo != null
                            ? Image.file(File(auth.currentUser!.photo!), fit: BoxFit.cover)
                            : const Icon(Icons.person, color: AppColors.textMuted, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text('Ketuk untuk ubah foto', style: AppText.caption(size: 11, color: AppColors.textMuted))),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outlined, size: 18)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Nomor HP', prefixIcon: Icon(Icons.phone_outlined, size: 18)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(color: AppColors.background, border: Border(top: BorderSide(color: AppColors.divider))),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      await auth.updateProfile(name: _nameController.text.trim(), phone: _phoneController.text.trim());
                      if (!mounted) return;
                      navigator.pop();
                      messenger.showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
                    },
                    child: Text('Simpan', style: AppText.button(size: 14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Edit Profil', style: AppText.display(size: 20))),
        ],
      ),
    );
  }
}
