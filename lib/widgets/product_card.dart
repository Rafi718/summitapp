import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../config/app_theme.dart';
import 'app_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool compact;

  const ProductCard({super.key, required this.product, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-detail', arguments: {'productId': product.id});
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                  ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AppImage(
                    src: imageUrl,
                    height: compact ? 110 : 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      height: compact ? 110 : 140,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
                if (product.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: compact ? 12 : 13, fontWeight: FontWeight.w600, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(product.brand, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Rp ${formatter.format(product.effectivePrice)}',
                        style: TextStyle(
                          fontSize: compact ? 13 : 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Rp ${formatter.format(product.price)}',
                            style: const TextStyle(
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppTheme.accentYellow),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.soldCount} terjual)',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
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
