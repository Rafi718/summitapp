import 'package:flutter/material.dart';
import '../../../widgets/app_image.dart';
import '../alpine_theme.dart';
import '../../../models/category.dart' as models;

class CategoryTile extends StatelessWidget {
  final models.Category category;
  final VoidCallback onTap;
  final double size;

  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppImage(
              src: category.image ?? AppAssets.categoryImages[category.id] ?? AppAssets.hero,
              fit: BoxFit.cover,
              placeholder: const Icon(Icons.terrain, color: AppColors.textMuted, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(size: 11, color: AppColors.textPrimary, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
