import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/alpine_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.backpack_outlined,
      title: 'Perlengkapan\nTerlengkap',
      description: 'Dari tenda, carrier, sepatu, hingga aksesoris pendakian. Semua ada di satu tempat.',
    ),
    _OnboardingData(
      icon: Icons.local_offer_outlined,
      title: 'Harga Terbaik\n& Promo',
      description: 'Dapatkan harga terbaik dengan promo eksklusif setiap minggunya untuk semua gear outdoor.',
    ),
    _OnboardingData(
      icon: Icons.local_shipping_outlined,
      title: 'Pesan &\nLangsung Dikirim',
      description: 'Pilih peralatanmu, checkout, dan kami kirim langsung ke alamatmu.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seen_onboarding', true);
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Lewati', style: AppText.caption(size: 13, color: AppColors.textMuted, weight: FontWeight.w500)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(60)),
                          child: Icon(page.icon, size: 56, color: AppColors.brand),
                        ),
                        const SizedBox(height: 40),
                        Text(page.title, textAlign: TextAlign.center, style: AppText.display(size: 26, weight: FontWeight.w700, height: 1.2)),
                        const SizedBox(height: 16),
                        Text(page.description, textAlign: TextAlign.center, style: AppText.body(size: 14, color: AppColors.textSecondary, height: 1.6)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.textPrimary : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_currentPage == _pages.length - 1) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('seen_onboarding', true);
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                  child: Text(_currentPage == _pages.length - 1 ? 'Mulai Sekarang' : 'Lanjut', style: AppText.button(size: 14)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  _OnboardingData({required this.icon, required this.title, required this.description});
}
