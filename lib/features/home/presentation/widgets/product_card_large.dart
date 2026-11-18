import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/home_models.dart';

/// Large product card with quick-commerce styling.
///
/// Responsive: accepts [cardWidth] or calculates for 2-column horizontal row.
class ProductCardLarge extends StatelessWidget {
  final HomeProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;
  final bool isWishlistProcessing;
  final bool showWishlistIcon;

  /// Optional explicit width. If null, calculated from screen width.
  final double? cardWidth;

  const ProductCardLarge({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onWishlistTap,
    this.isWishlisted = false,
    this.isWishlistProcessing = false,
    this.showWishlistIcon = true,
    this.cardWidth,
  });

  double _resolveWidth(BuildContext context) {
    if (cardWidth != null) return cardWidth!;
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth - 40 - 12) / 2;
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
              _buildImage(w, isDark),
              const SizedBox(height: 6),
              if (product.reviewCount > 0) ...[
                _buildRating(context),
                const SizedBox(height: 4),
              ],
              Text(
                product.name,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1.2,
                  color: isDark ? AppColors.neutral200 : AppColors.neutral800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Price and ADD button row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildPriceRow(context),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onAddToCart ?? onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary500,
                          letterSpacing: 0.5,
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

  Widget _buildImage(double size, bool isDark) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size,
            height: size * 0.95,
            color: isDark ? AppColors.neutral800 : const Color(0x1A0E1019),
            child:
                product.baseImageUrl != null && product.baseImageUrl!.isNotEmpty
                ? Image.network(
                    product.baseImageUrl!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size * 0.95,
                    errorBuilder: (context, error, stackTrace) =>
                        _imagePlaceholder(isDark),
                  )
                : _imagePlaceholder(isDark),
          ),
        ),
        if (showWishlistIcon)
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: isWishlistProcessing ? null : onWishlistTap,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: isWishlistProcessing
                    ? const Padding(
                        padding: EdgeInsets.all(5),
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.neutral400,
                        ),
                      )
                    : Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 15,
                        color: isWishlisted ? Colors.red : AppColors.neutral800,
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (product.hasDiscount) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.displayPriceLabel,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.1,
                    color: isDark ? AppColors.white : AppColors.neutral900,
                  ),
                ),
                if (product.originalPriceLabel != null &&
                    product.originalPriceLabel!.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    product.originalPriceLabel!,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.1,
                      color: AppColors.neutral500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.homeDiscountOff(product.discountPercent.toString()),
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.1,
                color: AppColors.primary500,
              ),
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        product.displayPriceLabel,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          fontSize: 15,
          height: 1.1,
          color: isDark ? AppColors.white : AppColors.neutral900,
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
              const Icon(Icons.star, size: 12, color: AppColors.white),
              const SizedBox(width: 1),
              Text(
                ratingStr,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
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
              fontSize: 11,
              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 36,
        color: isDark ? AppColors.neutral500 : AppColors.neutral400,
      ),
    );
  }
}
