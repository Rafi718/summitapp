import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../alpine_theme.dart';
import '../../../models/product.dart';

enum ProductCardStyle { compact, grid }

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductCardStyle style;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.style = ProductCardStyle.compact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return style == ProductCardStyle.compact ? _compact(context) : _grid(context);
  }

  Widget _compact(BuildContext context) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, '/product-detail', arguments: {'productId': product.id}),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: AppColors.textMuted),
                        loadingBuilder: (context, child, progress) => progress == null ? child : Container(color: AppColors.surfaceAlt),
                      ),
                    ),
                    if (product.isOnSale)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.sale, borderRadius: BorderRadius.circular(4)),
                          child: Text('−${product.discountPercent}%', style: AppText.label(size: 9, color: Colors.white, weight: FontWeight.w700)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(size: 13, weight: FontWeight.w500, color: AppColors.textPrimary, height: 1.3),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Rp ${formatter.format(product.effectivePrice)}',
                    style: AppText.body(size: 13, weight: FontWeight.w700, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (product.isOnSale) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Rp ${formatter.format(product.price)}',
                      style: AppText.caption(size: 11, color: AppColors.textMuted).copyWith(decoration: TextDecoration.lineThrough),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(BuildContext context) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, '/product-detail', arguments: {'productId': product.id}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, color: AppColors.textMuted),
                      loadingBuilder: (context, child, progress) => progress == null ? child : Container(color: AppColors.surfaceAlt),
                    ),
                  ),
                  if (product.isOnSale)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.sale, borderRadius: BorderRadius.circular(4)),
                        child: Text('−${product.discountPercent}%', style: AppText.label(size: 9, color: Colors.white, weight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: AppText.body(size: 13, weight: FontWeight.w500, color: AppColors.textPrimary, height: 1.3),
          ),
          const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Rp ${formatter.format(product.effectivePrice)}',
                    style: AppText.body(size: 13, weight: FontWeight.w700, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (product.isOnSale) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rp ${formatter.format(product.price)}',
                      style: AppText.caption(size: 10, color: AppColors.textMuted).copyWith(decoration: TextDecoration.lineThrough),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
