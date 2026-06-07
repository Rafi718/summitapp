import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(title: 'Alamat Saya', showBackButton: true),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 1.5))
                  : _addresses.isEmpty
                      ? EmptyState(
                          icon: Icons.location_off_outlined,
                          title: 'Belum ada alamat',
                          description: 'Tambahkan alamat untuk mulai checkout',
                          actionLabel: 'Tambah Alamat',
                          onAction: () async { await Navigator.pushNamed(context, '/address-form'); _loadAddresses(); },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: _addresses.length,
                          itemBuilder: (context, index) {
                            final address = _addresses[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DarkCard(
                                color: address.isPrimary ? AppColors.brand.withValues(alpha: 0.05) : AppColors.background,
                                padding: const EdgeInsets.all(16),
                                onTap: () => _showActions(address),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      address.isPrimary ? Icons.check_circle : Icons.location_on_outlined,
                                      color: address.isPrimary ? AppColors.brand : AppColors.textMuted,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(address.label, style: AppText.title(size: 14)),
                                              if (address.isPrimary) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(4)),
                                                  child: Text('Utama', style: AppText.caption(size: 9, color: Colors.white, weight: FontWeight.w600)),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text('${address.recipientName} • ${address.recipientPhone}', style: AppText.caption(size: 12, color: AppColors.textMuted)),
                                          const SizedBox(height: 4),
                                          Text('${address.fullAddress}, ${address.subdistrict}, ${address.city} ${address.postalCode}', style: AppText.caption(size: 12, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async { await Navigator.pushNamed(context, '/address-form'); _loadAddresses(); },
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 18),
        label: Text('Tambah', style: AppText.button(size: 12)),
      ),
    );
  }

  void _showActions(Address address) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
              title: Text('Edit', style: AppText.body(size: 14)),
              onTap: () async { Navigator.pop(context); await Navigator.pushNamed(context, '/address-form', arguments: {'address': address}); _loadAddresses(); },
            ),
            if (!address.isPrimary)
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppColors.textPrimary),
                title: Text('Jadikan Utama', style: AppText.body(size: 14)),
                onTap: () async { Navigator.pop(context); await context.read<AuthProvider>().service.setPrimaryAddress(address.id!); _loadAddresses(); },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.sale),
              title: Text('Hapus', style: AppText.body(size: 14, color: AppColors.sale)),
              onTap: () async { Navigator.pop(context); await context.read<AuthProvider>().service.deleteAddress(address.id!); _loadAddresses(); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
