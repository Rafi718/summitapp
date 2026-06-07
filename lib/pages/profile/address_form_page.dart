import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address.dart';
import '../home/alpine_theme.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _subdistrictController;
  late TextEditingController _postalCodeController;
  bool _isPrimary = false;
  Address? _editAddress;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _subdistrictController = TextEditingController();
    _postalCodeController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['address'] != null && _editAddress == null) {
      _editAddress = args['address'] as Address;
      _labelController.text = _editAddress!.label;
      _nameController.text = _editAddress!.recipientName;
      _phoneController.text = _editAddress!.recipientPhone;
      _addressController.text = _editAddress!.fullAddress;
      _cityController.text = _editAddress!.city;
      _subdistrictController.text = _editAddress!.subdistrict;
      _postalCodeController.text = _editAddress!.postalCode;
      _isPrimary = _editAddress!.isPrimary;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _subdistrictController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final address = Address(
      id: _editAddress?.id,
      userId: auth.currentUser!.id!,
      label: _labelController.text.trim(),
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      fullAddress: _addressController.text.trim(),
      city: _cityController.text.trim(),
      subdistrict: _subdistrictController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      isPrimary: _isPrimary,
    );

    if (_editAddress != null) {
      await auth.service.updateAddress(address);
    } else {
      await auth.service.addAddress(address);
      if (_isPrimary && address.id != null) {
        await auth.service.setPrimaryAddress(address.id!);
      }
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _field(String label, TextEditingController controller, {String? hint, TextInputType? type, int maxLines = 1, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        validator: validator ?? (v) => v == null || v.trim().isEmpty ? '$label tidak boleh kosong' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  children: [
                    _field('Label (contoh: Rumah, Kantor)', _labelController),
                    _field('Nama Penerima', _nameController),
                    _field('No HP', _phoneController, type: TextInputType.phone),
                    _field('Alamat Lengkap', _addressController, maxLines: 3),
                    _field('Kecamatan', _subdistrictController),
                    Row(
                      children: [
                        Expanded(flex: 2, child: _field('Kota / Kabupaten', _cityController)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Kode Pos', _postalCodeController, type: TextInputType.number)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Jadikan alamat utama', style: AppText.body(size: 13, weight: FontWeight.w500)),
                        value: _isPrimary,
                        onChanged: (v) => setState(() => _isPrimary = v),
                        activeThumbColor: AppColors.brand,
                      ),
                    ),
                  ],
                ),
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
                    onPressed: _save,
                    child: Text(_editAddress != null ? 'Simpan Perubahan' : 'Tambah Alamat', style: AppText.button(size: 14)),
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
          Expanded(child: Text(_editAddress != null ? 'Edit Alamat' : 'Tambah Alamat', style: AppText.display(size: 20))),
        ],
      ),
    );
  }
}
