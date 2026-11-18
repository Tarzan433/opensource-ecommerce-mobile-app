import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/home_models.dart';

/// Compact grocery-style small product card for grids.
///
/// Responsive: accepts [cardWidth] or calculates for 3-column layout.
class ProductCardSmall extends StatelessWidget {
  final HomeProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;
  final bool isWishlistProcessing;

  /// Optional explicit width. If null, calculated from screen width.
  final double? cardWidth;

  const ProductCardSmall({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onWishlistTap,
    this.isWishlisted = false,
    this.isWishlistProcessing = false,
    this.cardWidth,
  });

  double _resolveWidth(BuildContext context) {
    if (cardWidth != null) return cardWidth!;
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth - 40 - 24) / 3;
  }

  @override
  Widget build(BuildContext context) {
    final w = _resolveWidth(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: product.name,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image with tight 8px radius
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: w,
                      height: w,
                      color: isDark ? AppColors.neutral800 : const Color(0x1A0E1019),
                      child: product.baseImageUrl != null &&
                              product.baseImageUrl!.isNotEmpty
                          ? Image.network(
                              product.baseImageUrl!,
                              fit: BoxFit.cover,
                              width: w,
                              height: w,
                              errorBuilder: (_, __, ___) => _placeholder(isDark),
                            )
                          : _placeholder(isDark),
                    ),
                  ),
                  // Wishlist heart icon (top-right)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: isWishlistProcessing ? null : onWishlistTap,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: isWishlistProcessing
                            ? const Padding(
                                padding: EdgeInsets.all(4),
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppColors.neutral400,
                                ),
                              )
                            : Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 13,
                                color: isWishlisted
                                    ? Colors.red
                                    : AppColors.neutral800,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Rating badge (if available)
              if (product.reviewCount > 0) ...[
                _buildRating(context),
                const SizedBox(height: 4),
              ],
              // Product Name: max 2 lines
              Text(
                product.name,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.15,
                  color: isDark ? AppColors.neutral200 : AppColors.neutral800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Price and ADD button row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      _priceLabel(),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? AppColors.white : AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onAddToCart ?? onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.neutral800 : AppColors.white,
                        border: Border.all(
                          color: AppColors.primary500,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ADD',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rating badge
  Widget _buildRating(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (product.reviewCount == 0) return const SizedBox.shrink();
    final ratingStr = product.averageRating.toStringAsFixed(1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.successGreen,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 11, color: AppColors.white),
              const SizedBox(width: 1),
              Text(
                ratingStr,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            '(${product.reviewCount})',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 10,
              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _priceLabel() {
    return product.displayPriceLabel;
  }

  Widget _placeholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: isDark ? AppColors.neutral500 : AppColors.neutral400,
      ),
    );
  }
}
