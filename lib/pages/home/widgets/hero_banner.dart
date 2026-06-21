import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../alpine_theme.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceAlt,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            AppAssets.hero,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.surfaceAlt),
            loadingBuilder: (context, child, progress) => progress == null ? child : Container(color: AppColors.surfaceAlt),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Koleksi Terbaru', style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2, letterSpacing: -0.3,
                )),
                const SizedBox(height: 4),
                Text('Perlengkapan pendakian musim ini', style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.85), height: 1.3,
                )),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/product-list', arguments: {'categoryId': 0}),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Belanja', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 14, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
