import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/category.dart' as models;
import '../../widgets/app_image.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

IconData _iconFromName(String name) {
  const map = {
    'camping': Icons.cabin,
    'bedtime': Icons.bedtime_outlined,
    'backpack': Icons.backpack_outlined,
    'hiking': Icons.hiking,
    'style': Icons.checkroom_outlined,
    'lock': Icons.lock_outline,
    'light': Icons.lightbulb_outline,
    'airline_seat_flat': Icons.airline_seat_flat,
    'outdoor_grill': Icons.outdoor_grill_outlined,
    'category': Icons.category_outlined,
  };
  return map[name] ?? Icons.category_outlined;
}

const _iconEntries = [
  ('camping', Icons.cabin, 'Camping'),
  ('bedtime', Icons.bedtime_outlined, 'Bedtime'),
  ('backpack', Icons.backpack_outlined, 'Backpack'),
  ('hiking', Icons.hiking, 'Hiking'),
  ('style', Icons.checkroom_outlined, 'Style'),
  ('lock', Icons.lock_outline, 'Lock'),
  ('light', Icons.lightbulb_outline, 'Light'),
  ('airline_seat_flat', Icons.airline_seat_flat, 'Seat'),
  ('outdoor_grill', Icons.outdoor_grill_outlined, 'Grill'),
  ('category', Icons.category_outlined, 'Category'),
];

class AdminCategoryFormPage extends StatefulWidget {
  const AdminCategoryFormPage({super.key});

  @override
  State<AdminCategoryFormPage> createState() => _AdminCategoryFormPageState();
}

class _AdminCategoryFormPageState extends State<AdminCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();
  String _selectedIcon = 'category';
  bool _isEditing = false;
  bool _isSaving = false;
  bool _hasChanges = false;
  int? _existingCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['categoryId'] != null) {
        _loadCategory(args['categoryId'] as int);
      }
    });
  }

  void _loadCategory(int categoryId) {
    final provider = context.read<ProductProvider>();
    final category = provider.categories.where((c) => c.id == categoryId).firstOrNull;
    if (category == null) return;

    setState(() {
      _isEditing = true;
      _existingCategoryId = categoryId;
      _nameController.text = category.name;
      _imageController.text = category.image ?? '';
      _selectedIcon = category.icon;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _markChanged() => _hasChanges = true;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/category_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final originalName = picked.path.split(Platform.pathSeparator).last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savedName = '${timestamp}_$originalName';
      final savedPath = '${imagesDir.path}/$savedName';

      await File(picked.path).copy(savedPath);

      setState(() {
        _imageController.text = savedPath;
        _markChanged();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: AppColors.sale),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final category = models.Category(
      id: _isEditing ? _existingCategoryId : null,
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      image: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
    );

    final provider = context.read<ProductProvider>();
    final error = _isEditing
        ? await provider.updateCategory(category)
        : await provider.addCategory(category);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.sale),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Batalkan perubahan?', style: AppText.title(size: 16)),
        content: Text('Data yang belum disimpan akan hilang.', style: AppText.body(size: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Tetap di sini', style: AppText.body(size: 13, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sale),
            child: const Text('Buang'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              PageHeader(
                title: _isEditing ? 'Edit Kategori' : 'Tambah Kategori',
                showBackButton: true,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  onChanged: _markChanged,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    children: [
                      const SizedBox(height: 8),
                      // Live preview
                      _buildPreview(),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        style: AppText.body(size: 14),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama kategori wajib diisi' : null,
                        decoration: InputDecoration(
                          labelText: 'Nama Kategori',
                          labelStyle: AppText.caption(size: 12, color: AppColors.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.brand)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildImageField(),
                      const SizedBox(height: 24),
                      Text('Pilih Ikon (fallback)', style: AppText.title(size: 14)),
                      const SizedBox(height: 12),
                      _buildIconGrid(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildSaveBar(),
      ),
    );
  }

  Widget _buildPreview() {
    final icon = _iconFromName(_selectedIcon);
    final name = _nameController.text.trim().isEmpty ? 'Nama Kategori' : _nameController.text.trim();
    final imageUrl = _imageController.text.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? AppImage(src: imageUrl, fit: BoxFit.cover, placeholder: Icon(icon, color: Colors.white, size: 24))
                : Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppText.body(size: 16, weight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Preview tampilan kategori', style: AppText.caption(size: 12, color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageField() {
    final imageUrl = _imageController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gambar Kategori', style: AppText.title(size: 14)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _imageController,
          style: AppText.body(size: 14),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'URL Gambar atau path file',
            labelStyle: AppText.caption(size: 12, color: AppColors.textSecondary),
            hintText: 'https://... atau pilih dari galeri',
            hintStyle: AppText.caption(size: 12, color: AppColors.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.brand)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library, size: 18),
              label: const Text('Pilih dari Galeri'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (imageUrl.isNotEmpty) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _imageController.clear();
                    _markChanged();
                  });
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sale,
                  side: const BorderSide(color: AppColors.sale),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
        if (imageUrl.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppImage(src: imageUrl, fit: BoxFit.cover),
          ),
        ],
      ],
    );
  }

  Widget _buildIconGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _iconEntries.map((entry) {
        final (name, iconData, label) = entry;
        final isSelected = _selectedIcon == name;
        return GestureDetector(
          onTap: () => setState(() { _selectedIcon = name; _markChanged(); }),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brand.withValues(alpha: 0.1) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.brand : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, size: 24, color: isSelected ? AppColors.brand : AppColors.textSecondary),
                const SizedBox(height: 4),
                Text(label, style: AppText.caption(size: 10, color: isSelected ? AppColors.brand : AppColors.textSecondary, weight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand,
            disabledBackgroundColor: AppColors.textMuted,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Kategori', style: AppText.button(size: 14)),
        ),
      ),
    );
  }
}