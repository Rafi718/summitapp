import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
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
      ],
      child: MaterialApp(
        title: 'Summit App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return MaterialPageRoute(builder: (_) => const SplashPage());
            case AppRoutes.onboarding:
              return MaterialPageRoute(builder: (_) => const OnboardingPage());
            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case AppRoutes.register:
              return MaterialPageRoute(builder: (_) => const RegisterPage());
            case AppRoutes.main:
              return MaterialPageRoute(builder: (_) => const MainShell());
            case AppRoutes.search:
              return MaterialPageRoute(builder: (_) => const SearchPage());
            case AppRoutes.productList:
              return MaterialPageRoute(builder: (_) => const ProductListPage());
            case AppRoutes.productDetail:
              return MaterialPageRoute(builder: (_) => const ProductDetailPage());
            case AppRoutes.checkout:
              return MaterialPageRoute(builder: (_) => const CheckoutPage());
            case AppRoutes.orderDetail:
              return MaterialPageRoute(builder: (_) => const OrderDetailPage());
            case AppRoutes.editProfile:
              return MaterialPageRoute(builder: (_) => const EditProfilePage());
            case AppRoutes.addressList:
              return MaterialPageRoute(builder: (_) => const AddressListPage());
            case AppRoutes.addressForm:
              return MaterialPageRoute(builder: (_) => const AddressFormPage());
            case AppRoutes.wishlist:
              return MaterialPageRoute(builder: (_) => const WishlistPage());
            default:
              return MaterialPageRoute(builder: (_) => const MainShell());
          }
        },
      ),
    );
  }
}
