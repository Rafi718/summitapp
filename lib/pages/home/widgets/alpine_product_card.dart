import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../alpine_theme.dart';
import '../../models/product.dart';

class AlpineProductCard extends StatelessWidget {
  final Product product;
  final AlpineCardVariant variant;
  final VoidCallback? onTap;

  const AlpineProductCard({
    super.key,
    required this.product,
    this.variant = AlpineCardVariant.compact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AlpineCardVariant.compact:
        return _buildCompact(context);
      case AlpineCardVariant.editorial:
        return _buildEditorial(context);
      case AlpineCardVariant.minimal:
        return _buildMinimal(context);
    }
  }

  Widget _buildCompact(BuildContext context) {
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
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AlpineTheme.creamDark,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                    Container(color: AlpineTheme.creamDark, child: const Icon(Icons.image, color: AlpineTheme.stone, size: 32)),
                  ),
                  if (product.isOnSale)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: AlpineTheme.terracotta, borderRadius: BorderRadius.circular(3)),
                        child: Text('−${product.discountPercent}%', style: AlpineTheme.label(size: 9, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.brand.toUpperCase(),
              style: AlpineTheme.label(size: 9, color: AlpineTheme.stone),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AlpineTheme.body(size: 13, weight: FontWeight.w600, color: AlpineTheme.charcoal, height: 1.3),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rp${formatter.format(product.effectivePrice)}', style: AlpineTheme.body(size: 13, weight: FontWeight.w800, color: AlpineTheme.forest)),
                if (product.isOnSale) ...[
                  const SizedBox(width: 6),
                  Text('Rp${formatter.format(product.price)}', style: AlpineTheme.body(size: 10, color: AlpineTheme.stone, letterSpacing: 0).copyWith(decoration: TextDecoration.lineThrough)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorial(BuildContext context) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, '/product-detail', arguments: {'productId': product.id}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.85,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AlpineTheme.creamDark,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                    Container(color: AlpineTheme.creamDark, child: const Icon(Icons.image, color: AlpineTheme.stone)),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.favorite_border, size: 14, color: AlpineTheme.charcoal),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(product.brand.toUpperCase(), style: AlpineTheme.label(size: 9, color: AlpineTheme.stone)),
          const SizedBox(height: 3),
          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: AlpineTheme.display(size: 16, weight: FontWeight.w500, color: AlpineTheme.charcoal, height: 1.2, letterSpacing: -0.2),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Rp${formatter.format(product.effectivePrice)}', style: AlpineTheme.body(size: 14, weight: FontWeight.w800, color: AlpineTheme.forest)),
              if (product.isOnSale) ...[
                const SizedBox(width: 6),
                Text('Rp${formatter.format(product.price)}', style: AlpineTheme.body(size: 11, color: AlpineTheme.stone).copyWith(decoration: TextDecoration.lineThrough)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinimal(BuildContext context) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, '/product-detail', arguments: {'productId': product.id}),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AlpineTheme.creamDark,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
              Container(color: AlpineTheme.creamDark, child: const Icon(Icons.image, color: AlpineTheme.stone, size: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.brand.toUpperCase(), style: AlpineTheme.label(size: 9, color: AlpineTheme.stone)),
                const SizedBox(height: 2),
                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: AlpineTheme.body(size: 13, weight: FontWeight.w600, color: AlpineTheme.charcoal, height: 1.3),
                ),
                const SizedBox(height: 6),
                Text('Rp${formatter.format(product.effectivePrice)}', style: AlpineTheme.body(size: 13, weight: FontWeight.w800, color: AlpineTheme.forest)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum AlpineCardVariant { compact, editorial, minimal }
