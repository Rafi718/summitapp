import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address.dart';
import '../../config/app_theme.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final auth = context.read<AuthProvider>();
    final addresses = await auth.service.getAddresses();
    if (mounted) {
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alamat Saya')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/address-form');
          _loadAddresses();
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Belum ada alamat', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: address.isPrimary ? AppTheme.primaryGreen : Colors.grey[200]!,
                          width: address.isPrimary ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          address.isPrimary ? Icons.check_circle : Icons.location_on_outlined,
                          color: address.isPrimary ? AppTheme.primaryGreen : Colors.grey,
                        ),
                        title: Text(address.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${address.recipientName} - ${address.recipientPhone}\n${address.fullAddress}, ${address.subdistrict}, ${address.city} ${address.postalCode}'),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            if (!address.isPrimary)
                              const PopupMenuItem(value: 'primary', child: Text('Jadikan Utama')),
                            const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                          ],
                          onSelected: (value) async {
                            final auth = context.read<AuthProvider>();
                            if (value == 'edit') {
                              await Navigator.pushNamed(context, '/address-form', arguments: {'address': address});
                            } else if (value == 'primary') {
                              await auth.service.setPrimaryAddress(address.id!);
                            } else if (value == 'delete') {
                              await auth.service.deleteAddress(address.id!);
                            }
                            _loadAddresses();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
