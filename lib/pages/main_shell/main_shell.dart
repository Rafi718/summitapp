import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../home/home_page.dart';
import '../catalog/category_page.dart';
import '../cart/cart_page.dart';
import '../orders/order_list_page.dart';
import '../profile/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final CartProvider _cart;
  late final AuthProvider _auth;
  ProductProvider? _productProvider;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomePage(),
      CategoryPage(),
      CartPage(),
      OrderListPage(),
      ProfilePage(),
    ];

    _cart = context.read<CartProvider>();
    _auth = context.read<AuthProvider>();
    _productProvider = context.read<ProductProvider>();

    _auth.addListener(_onAuthChanged);
    _productProvider!.addListener(_onProductsChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCart();
    });
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _productProvider?.removeListener(_onProductsChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    _syncCart();
  }

  void _onProductsChanged() {
    if (!mounted) return;
    final products = _productProvider!.products;
    if (products.isNotEmpty) {
      _cart.setProductCache(products);
    }
  }

  void _syncCart() {
    final user = _auth.currentUser;
    if (user?.id == null) {
      if (_cart.userId != null) _cart.clearCart();
      return;
    }

    final userId = user!.id!;
    if (_cart.userId == userId) {
      final products = _productProvider?.products ?? [];
      if (products.isNotEmpty) _cart.setProductCache(products);
      return;
    }

    _cart.loadCart(userId).then((_) {
      final products = _productProvider?.products ?? [];
      if (products.isNotEmpty) _cart.setProductCache(products);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          const BottomNavigationBarItem(icon: Icon(Icons.category_outlined), activeIcon: Icon(Icons.category), label: 'Kategori'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${cart.itemCount}', style: const TextStyle(fontSize: 10)),
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              label: Text('${cart.itemCount}', style: const TextStyle(fontSize: 10)),
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Keranjang',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
