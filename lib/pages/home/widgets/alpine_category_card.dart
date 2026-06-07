import 'package:flutter/material.dart';
import '../alpine_theme.dart';
import '../../models/category.dart' as models;

class AlpineCategoryCard extends StatelessWidget {
  final models.Category category;
  final VoidCallback onTap;
  final double size;

  const AlpineCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.size = 88,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = AlpineAssets.categoryImages[category.id] ?? AlpineAssets.gear;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AlpineTheme.creamDark,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AlpineTheme.creamDark,
                      child: const Icon(Icons.terrain, color: AlpineTheme.stone, size: 28),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: AlpineTheme.creamDark);
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 6,
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AlpineTheme.body(
                        size: 10,
                        color: Colors.white,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
