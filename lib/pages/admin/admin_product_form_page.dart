import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class AdminProductFormPage extends StatefulWidget {
  const AdminProductFormPage({super.key});

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isSaving = false;
  bool _hasChanges = false;
  int? _existingProductId;

  // Controllers
  final _imagesController = TextEditingController();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sizeGuideController = TextEditingController();

  int? _selectedCategoryId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['productId'] != null) {
        _loadProduct(args['productId'] as int);
      }
    });
  }

  void _loadProduct(int productId) {
    final provider = context.read<ProductProvider>();
    final product = provider.getProductById(productId);
    if (product == null) return;

    setState(() {
      _isEditing = true;
      _existingProductId = productId;
      _selectedCategoryId = product.categoryId;
      _isActive = product.isActive;
      _imagesController.text = product.images.join(', ');
      _nameController.text = product.name;
      _brandController.text = product.brand;
      _priceController.text = product.price.toString();
      _discountPriceController.text = product.discountPrice?.toString() ?? '';
      _stockController.text = product.stock.toString();
      _weightController.text = product.weight.toString();
      _descriptionController.text = product.description;
      _sizeGuideController.text = product.sizeGuide ?? '';
    });
  }

  @override
  void dispose() {
    _imagesController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _sizeGuideController.dispose();
    super.dispose();
  }

  void _markChanged() => _hasChanges = true;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu'), backgroundColor: AppColors.sale),
      );
      return;
    }

    setState(() => _isSaving = true);

    final images = _imagesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final product = Product(
      id: _isEditing ? _existingProductId : null,
      categoryId: _selectedCategoryId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      brand: _brandController.text.trim(),
      weight: int.tryParse(_weightController.text) ?? 0,
      price: int.tryParse(_priceController.text) ?? 0,
      discountPrice: _discountPriceController.text.trim().isEmpty ? null : int.tryParse(_discountPriceController.text),
      stock: int.tryParse(_stockController.text) ?? 0,
      rating: 0,
      reviewCount: 0,
      soldCount: 0,
      images: images,
      isActive: _isActive,
      sizeGuide: _sizeGuideController.text.trim().isEmpty ? null : _sizeGuideController.text.trim(),
      createdAt: _isEditing ? '' : DateTime.now().toIso8601String(),
    );

    final provider = context.read<ProductProvider>();
    final error = _isEditing
        ? await provider.updateProduct(product)
        : await provider.addProduct(product);

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
    final provider = context.watch<ProductProvider>();

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
                title: _isEditing ? 'Edit Produk' : 'Tambah Produk',
                showBackButton: true,
                trailing: _isEditing
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.brand.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('EDIT', style: AppText.label(size: 10, color: AppColors.brand)),
                      )
                    : null,
              ),
              Expanded(
                child: provider.isLoading && _isEditing
                    ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
                    : Form(
                        key: _formKey,
                        onChanged: _markChanged,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          children: [
                            _sectionLabel('Informasi Dasar'),
                            const SizedBox(height: 12),
                            _buildImageField(),
                            const SizedBox(height: 16),
                            _buildTextField(_nameController, 'Nama Produk', required: true),
                            const SizedBox(height: 16),
                            _buildTextField(_brandController, 'Brand', required: true),
                            const SizedBox(height: 16),
                            _buildCategoryDropdown(provider),
                            const SizedBox(height: 24),
                            _sectionLabel('Harga & Stok'),
                            const SizedBox(height: 12),
                            _buildTextField(_priceController, 'Harga (Rp)', required: true, keyboardType: TextInputType.number),
                            const SizedBox(height: 16),
                            _buildTextField(_discountPriceController, 'Harga Diskon (Rp)', required: false, keyboardType: TextInputType.number, hint: 'Opsional'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(_stockController, 'Stok', required: true, keyboardType: TextInputType.number)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildTextField(_weightController, 'Berat (gram)', required: true, keyboardType: TextInputType.number)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _sectionLabel('Detail Tambahan'),
                            const SizedBox(height: 12),
                            _buildTextField(_descriptionController, 'Deskripsi', required: true, maxLines: 4),
                            const SizedBox(height: 16),
                            _buildTextField(_sizeGuideController, 'Size Guide', required: false, maxLines: 3, hint: 'Opsional'),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              value: _isActive,
                              onChanged: (v) => setState(() { _isActive = v; _markChanged(); }),
                              title: Text('Produk Aktif', style: AppText.body(size: 14, weight: FontWeight.w500)),
                              subtitle: Text(_isActive ? 'Produk terlihat oleh pembeli' : 'Produk disembunyikan', style: AppText.caption(size: 12, color: AppColors.textSecondary)),
                              activeThumbColor: AppColors.brand,
                              contentPadding: EdgeInsets.zero,
                            ),
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

  Widget _sectionLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppText.label(size: 11, color: AppColors.brand, letterSpacing: 0.8)),
    );
  }

  Widget _buildImageField() {
    final urls = _imagesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final previewUrl = urls.isNotEmpty ? urls.first : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _imagesController,
          style: AppText.body(size: 14),
          decoration: InputDecoration(
            labelText: 'Gambar URL',
            labelStyle: AppText.caption(size: 12, color: AppColors.textSecondary),
            hintText: 'Pisahkan multiple URL dengan koma',
            hintStyle: AppText.caption(size: 12, color: AppColors.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.brand)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        if (previewUrl.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              previewUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.broken_image, color: AppColors.textMuted),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      style: AppText.body(size: 14),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppText.caption(size: 12, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: AppText.caption(size: 12, color: AppColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.brand)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildCategoryDropdown(ProductProvider provider) {
    return DropdownButtonFormField<int>(
      initialValue: _selectedCategoryId,
      items: provider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: AppText.body(size: 14)))).toList(),
      onChanged: (v) => setState(() { _selectedCategoryId = v; _markChanged(); }),
      decoration: InputDecoration(
        labelText: 'Kategori',
        labelStyle: AppText.caption(size: 12, color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.brand)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: (v) => v == null ? 'Pilih kategori' : null,
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
              : Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Produk', style: AppText.button(size: 14)),
        ),
      ),
    );
  }
}