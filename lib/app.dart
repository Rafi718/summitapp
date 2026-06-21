import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/admin_provider.dart';
import '../pages/splash/splash_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/main_shell/main_shell.dart';
import '../pages/catalog/search_page.dart';
import '../pages/catalog/product_list_page.dart';
import '../pages/catalog/product_detail_page.dart';
import '../pages/checkout/checkout_page.dart';
import '../pages/orders/order_detail_page.dart';
import '../pages/profile/edit_profile_page.dart';
import '../pages/profile/address_list_page.dart';
import '../pages/profile/address_form_page.dart';
import '../pages/wishlist/wishlist_page.dart';
import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/admin_product_list_page.dart';
import '../pages/admin/admin_product_form_page.dart';
import '../pages/admin/admin_category_list_page.dart';
import '../pages/admin/admin_category_form_page.dart';
import '../pages/admin/admin_order_list_page.dart';
import '../pages/admin/admin_order_detail_page.dart';
import '../pages/admin/admin_sales_report_page.dart';

/// Routes that require an authenticated admin user. Any non-admin (or
/// unauthenticated) visitor is bounced back to the main shell with a
/// SnackBar so deep-linking to `/admin/...` can't bypass the gate.
const _adminRoutes = <String>{
  AppRoutes.adminDashboard,
  AppRoutes.adminProducts,
  AppRoutes.adminProductForm,
  AppRoutes.adminCategories,
  AppRoutes.adminCategoryForm,
  AppRoutes.adminOrders,
  AppRoutes.adminOrderDetail,
  AppRoutes.adminSalesReport,
};

class SummitApp extends StatelessWidget {
  const SummitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ProductProvider()..loadProducts()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      // Builder gives us a build context that is BELOW MultiProvider in the
      // tree, so `context.read<AuthProvider>()` inside onGenerateRoute can
      // actually find the provider. Without this, the captured `context`
      // from SummitApp.build is ABOVE MultiProvider and the lookup throws
      // "Could not find the correct Provider<AuthProvider>".
      child: Builder(
        builder: (context) {
          return MaterialApp(
        title: 'Summit App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          // Admin route guard: only authenticated admins may proceed.
          if (_adminRoutes.contains(settings.name)) {
            final auth = context.read<AuthProvider>();
            final user = auth.currentUser;
            if (user == null || !user.isAdmin) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const _AdminAccessDeniedPage(),
              );
            }
          }
          switch (settings.name) {
            case AppRoutes.splash:
              return MaterialPageRoute(settings: settings, builder: (_) => const SplashPage());
            case AppRoutes.onboarding:
              return MaterialPageRoute(settings: settings, builder: (_) => const OnboardingPage());
            case AppRoutes.login:
              return MaterialPageRoute(settings: settings, builder: (_) => const LoginPage());
            case AppRoutes.register:
              return MaterialPageRoute(settings: settings, builder: (_) => const RegisterPage());
            case AppRoutes.main:
              return MaterialPageRoute(settings: settings, builder: (_) => const MainShell());
            case AppRoutes.search:
              return MaterialPageRoute(settings: settings, builder: (_) => const SearchPage());
            case AppRoutes.productList:
              return MaterialPageRoute(settings: settings, builder: (_) => const ProductListPage());
            case AppRoutes.productDetail:
              return MaterialPageRoute(settings: settings, builder: (_) => const ProductDetailPage());
            case AppRoutes.checkout:
              return MaterialPageRoute(settings: settings, builder: (_) => const CheckoutPage());
            case AppRoutes.orderDetail:
              return MaterialPageRoute(settings: settings, builder: (_) => const OrderDetailPage());
            case AppRoutes.editProfile:
              return MaterialPageRoute(settings: settings, builder: (_) => const EditProfilePage());
            case AppRoutes.addressList:
              return MaterialPageRoute(settings: settings, builder: (_) => const AddressListPage());
            case AppRoutes.addressForm:
              return MaterialPageRoute(settings: settings, builder: (_) => const AddressFormPage());
            case AppRoutes.wishlist:
              return MaterialPageRoute(settings: settings, builder: (_) => const WishlistPage());
            case AppRoutes.adminDashboard:
              return MaterialPageRoute(settings: settings, builder: (_) => const AdminDashboardPage());
            case AppRoutes.adminProducts:
              return MaterialPageRoute(settings: settings, builder: (_) => const AdminProductListPage());
            case AppRoutes.adminProductForm:
              return MaterialPageRoute(settings: settings, builder: (_) => const AdminProductFormPage());
            case AppRoutes.adminCategories:
              return MaterialPageRoute(settings: settings, builder: (_) => const AdminCategoryListPage());
            case AppRoutes.adminCategoryForm:
              return MaterialPageRoute(settings: settings, builder: (_) => const AdminCategoryFormPage());
            case AppRoutes.adminOrders:
              return MaterialPageRoute(settings: settings, builder: (_) => const AdminOrderListPage());
            case AppRoutes.adminOrderDetail:
              return MaterialPageRoute(settings: settings, builder: (_) => const AdminOrderDetailPage());
            case AppRoutes.adminSalesReport:
              return MaterialPageRoute(settings: settings, builder: (_) => const AdminSalesReportPage());
            default:
              return MaterialPageRoute(settings: settings, builder: (_) => const MainShell());
          }
        },
          );
        },
      ),
    );
  }
}

/// Shown when a non-admin tries to deep-link to an admin route.
/// Auto-redirects to the main shell after a short delay so the user
/// isn't stuck on a dead-end screen.
class _AdminAccessDeniedPage extends StatefulWidget {
  const _AdminAccessDeniedPage();

  @override
  State<_AdminAccessDeniedPage> createState() => _AdminAccessDeniedPageState();
}

class _AdminAccessDeniedPageState extends State<_AdminAccessDeniedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses ditolak. Halaman admin hanya untuk akun admin.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF1A3329))),
    );
  }
}
