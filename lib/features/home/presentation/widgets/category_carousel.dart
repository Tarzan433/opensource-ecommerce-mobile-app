import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/home_models.dart';

/// "Bestsellers" quick-commerce section:
/// Header with bold "Bestsellers" title and orange "See all" link.
/// Horizontal scrolling row of category cards.
/// Each card features a 2x2 product image collage, a "+N more" pill chip,
/// and a 2-line category name under it.
class CategoryCarousel extends StatelessWidget {
  final List<HomeCategory> categories;
  final ValueChanged<HomeCategory>? onCategoryTap;
  final VoidCallback? onSeeAll;

  const CategoryCarousel({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: "Bestsellers" + "See all" link in orange
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Bestsellers',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.white : AppColors.neutral900,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal scrolling row of cards
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _BestsellerCategoryCard(
                key: ValueKey('bestseller_cat_${category.id}'),
                category: category,
                index: index,
                onTap: onCategoryTap != null
                    ? () => onCategoryTap!(category)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BestsellerCategoryCard extends StatelessWidget {
  final HomeCategory category;
  final int index;
  final VoidCallback? onTap;

  const _BestsellerCategoryCard({
    super.key,
    required this.category,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock count like +139 more, +464 more, etc.
    final mockMoreCount = ((index * 83 + 65) % 400) + 20;

    return Semantics(
      button: true,
      label: l10n.homeCategorySemanticLabel(category.name),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card container with 2x2 collage + "+N more" chip
              Container(
                width: 110,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.bestsellerCardDarkBg
                      : AppColors.bestsellerCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.neutral700
                        : const Color(0xFFE8ECEF),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.all(7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 2x2 image collage
                    _buildCollage(context),
                    const SizedBox(height: 6),
                    // "+N more" chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.neutral700 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '+$mockMoreCount more',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.neutral300
                              : AppColors.neutral600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Category name below, centered (max 2 lines)
              SizedBox(
                height: 32,
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.2,
                    color:
                        isDark ? AppColors.neutral100 : AppColors.neutral900,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.neutral700.withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildTileImage(context, 0)),
                const SizedBox(width: 4),
                Expanded(child: _buildTileImage(context, 1)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildTileImage(context, 2)),
                const SizedBox(width: 4),
                Expanded(child: _buildTileImage(context, 3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileImage(BuildContext context, int tileIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = category.logoUrl != null && category.logoUrl!.isNotEmpty;

    const tileIcons = [
      Icons.shopping_bag_outlined,
      Icons.fastfood_outlined,
      Icons.local_cafe_outlined,
      Icons.lunch_dining_outlined,
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: isDark ? AppColors.neutral800 : const Color(0xFFF7F8FA),
        alignment: Alignment.center,
        child: hasImage
            ? Image.network(
                category.logoUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, error, stackTrace) => _placeholder(
                  context,
                  tileIcons[tileIndex % tileIcons.length],
                ),
              )
            : _placeholder(context, tileIcons[tileIndex % tileIcons.length]),
      ),
    );
  }

  Widget _placeholder(
    BuildContext context, [
    IconData icon = Icons.shopping_basket_outlined,
  ]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      icon,
      size: 16,
      color: isDark ? AppColors.neutral500 : AppColors.neutral400,
    );
  }
}
