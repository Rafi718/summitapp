import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address.dart';

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
    if (args != null && args['address'] != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editAddress != null ? 'Edit Alamat' : 'Tambah Alamat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Label (contoh: Rumah, Kantor)', prefixIcon: Icon(Icons.label_outlined)),
                validator: (v) => v == null || v.isEmpty ? 'Label tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Penerima', prefixIcon: Icon(Icons.person_outlined)),
                validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'No HP Penerima', prefixIcon: Icon(Icons.phone_outlined)),
                validator: (v) => v == null || v.isEmpty ? 'No HP tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Alamat Lengkap', prefixIcon: Icon(Icons.home_outlined), alignLabelWithHint: true),
                validator: (v) => v == null || v.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subdistrictController,
                decoration: const InputDecoration(labelText: 'Kecamatan', prefixIcon: Icon(Icons.map_outlined)),
                validator: (v) => v == null || v.isEmpty ? 'Kecamatan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Kota/Kabupaten'),
                      validator: (v) => v == null || v.isEmpty ? 'Kota tidak boleh kosong' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Kode Pos'),
                      validator: (v) => v == null || v.isEmpty ? 'Kosong' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Jadikan alamat utama'),
                value: _isPrimary,
                onChanged: (v) => setState(() => _isPrimary = v),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
