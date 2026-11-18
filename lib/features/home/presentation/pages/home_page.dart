import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/channel_logo.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/wishlist/wishlist_cubit.dart';
import '../../data/models/home_models.dart';
import '../../../product/presentation/pages/product_detail_page.dart';
import '../../../category/presentation/pages/category_products_grid_page.dart';
import '../../../category/data/models/category_model.dart';
import '../../../category/data/repository/category_repository.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../bloc/home_bloc.dart';
import '../widgets/category_carousel.dart';
import '../widgets/image_carousel.dart';
import '../widgets/product_card_large.dart';
import '../widgets/product_card_small.dart';
import '../widgets/recently_viewed_products_section.dart';
import '../widgets/section_header.dart';
import '../widgets/services_content_section.dart';
import '../widgets/static_content_widget.dart';

/// Quick-commerce header constants
const String deliveryPrefixText = 'Delivery in';
const String deliveryTimeText = '15 minutes';
const String deliveryLocationText = 'Home - Mangaluru';
const String searchPlaceholderText = 'Search "milk"';

/// The main Home page of the Bagisto Flutter app.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  int _selectedCategoryTabIndex = 0; // MOCK category tabs state ("All" default)

  @override
  void initState() {
    super.initState();
    // Observe app lifecycle to refresh wishlist on resume
    WidgetsBinding.instance.addObserver(this);
    // Load/refresh wishlist in background when home page is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistCubit>().refreshWishlist();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh wishlist when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<WishlistCubit>().refreshWishlist();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// Navigate to the Search page.
  void _openSearchPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SearchPage()));
  }

  /// Navigate to the Product Detail page for a given [HomeProduct].
  void _openProductDetail(BuildContext context, HomeProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          urlKey: product.urlKey,
          productId: product.numericId?.toString() ?? product.id,
          productName: product.name,
          productType: product.type,
        ),
      ),
    );
  }

  /// Open a home category in the Categories tab, the same flow as picking
  /// it there. Falls back to the products grid outside the tab shell.
  void _openCategoryProducts(BuildContext context, HomeCategory category) {
    final categoryId = category.numericId ?? 0;
    if (categoryId <= 0) return;
    if (AppNavigator.maybeOf(context) != null) {
      context.read<CategoryBloc>().add(ShowCategory(categoryId));
      AppNavigator.goCategories(context);
      return;
    }
    _openCategoryGrid(context, categoryId, category.name, category.slug);
  }

  void _openCategoryGrid(
    BuildContext context,
    int categoryId,
    String name,
    String slug,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: RepositoryProvider.of<CategoryRepository>(context),
          child: CategoryProductsGridPage(
            categoryId: categoryId,
            categoryName: name,
            categorySlug: slug,
          ),
        ),
      ),
    );
  }

  /// Follow an admin-configured home link (banner, collection, button).
  /// The link's last path segment is matched against category slugs; a
  /// top-level category opens in the Categories tab, a sub-category in its
  /// products grid, and anything else is treated as a product URL key.
  Future<void> _openLink(BuildContext context, String link) async {
    final slug = homeLinkSlug(link);
    if (slug == null) return;

    final homeCategory = context
        .read<HomeBloc>()
        .state
        .categories
        .where((c) => c.slug == slug)
        .firstOrNull;
    if (homeCategory != null) {
      _openCategoryProducts(context, homeCategory);
      return;
    }

    final repository = RepositoryProvider.of<CategoryRepository>(context);
    try {
      final categories = await repository.getCategoryTabCategories();
      if (!context.mounted) return;
      for (final top in categories) {
        final topId = top.numericId ?? 0;
        if (top.slug == slug && topId > 0) {
          _openCategoryProducts(
            context,
            HomeCategory(
              id: top.id,
              numericId: topId,
              name: top.name,
              slug: top.slug,
              position: top.position ?? 0,
            ),
          );
          return;
        }
        for (final child in top.children) {
          final childId = child.numericId ?? 0;
          if (child.slug == slug && childId > 0) {
            _openCategoryGrid(context, childId, child.name, child.slug);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[HomePage] link category lookup failed: $e');
    }
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailPage(urlKey: slug)),
    );
  }

  /// Quick-add a product to cart (for simple products only).
  void _addProductToCart(BuildContext context, HomeProduct product) {
    final l10n = AppLocalizations.of(context)!;
    final productId = int.tryParse(product.id) ?? 0;
    if (productId <= 0) return;

    // For configurable products, navigate to detail page instead
    if (product.type == 'configurable') {
      _openProductDetail(context, product);
      return;
    }

    context.read<CartBloc>().add(AddToCart(productId: productId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.homeAddedToCartMessage(product.name)),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: l10n.homeViewCart,
          textColor: AppColors.white,
          onPressed: () => AppNavigator.goCart(context),
        ),
      ),
    );
  }

  /// Toggle wishlist for a product (add/remove).
  void _toggleWishlist(BuildContext context, HomeProduct product) async {
    final l10n = AppLocalizations.of(context)!;
    final productId =
        product.numericId ?? int.tryParse(product.id.split('/').last) ?? 0;
    if (productId <= 0) return;

    try {
      final result = await context.read<WishlistCubit>().toggleWishlist(
        productId: productId,
      );
      if (!context.mounted) return;

      if (result == null) {
        // Not authenticated
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.homeLoginToManageWishlist),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result ? l10n.homeAddedToWishlist : l10n.homeRemovedFromWishlist,
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorMapper.getUserMessage(e, context: 'updating wishlist'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Navigate to catalog page showing all products with sort/filter.
  /// [title] is used as the page header (e.g. "Featured Products").
  /// [filters] is the raw filter map from themeCustomization options
  /// (e.g. {"new": 1, "sort": "created_at-desc", "limit": 10}).
  /// We extract the product-level filters (new, featured, category_id, etc.)
  /// and pass them to the catalog page as the initial filter JSON.
  void _openViewAll(
    BuildContext context,
    String title, {
    Map<String, dynamic> filters = const {},
  }) {
    // Build the API filter JSON from themeCustomization filters,
    // excluding UI-only keys like "sort" and "limit".
    // API requires all values to be strings.
    final apiFilter = <String, String>{};
    for (final entry in filters.entries) {
      if (entry.key == 'sort' || entry.key == 'limit') continue;
      if (entry.value != null) {
        apiFilter[entry.key] = entry.value.toString();
      }
    }

    final initialFilter = apiFilter.isNotEmpty ? json.encode(apiFilter) : null;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: RepositoryProvider.of<CategoryRepository>(context),
          child: CategoryProductsGridPage(
            categoryId: 0,
            categoryName: title,
            initialFilter: initialFilter,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.neutral900 : AppColors.white,
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) {
          if (current.status == HomeStatus.refreshing) return false;
          return true;
        },
        builder: (context, state) {
          return Column(
            children: [
              // ── Quick-commerce header filling status bar ──
              _buildTopBar(context, state.categories),

              // ── Scrollable content ──
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    // Show full-screen loader only on first load (no data yet).
    if (state.status == HomeStatus.loading &&
        state.customizations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary500,
        ),
      );
    }

    if (state.status == HomeStatus.error &&
        state.customizations.isEmpty) {
      return _buildError(context, state);
    }

    // Show content for loaded/initial states, or when
    // data exists even during a background refresh.
    if (state.customizations.isNotEmpty || state.categories.isNotEmpty) {
      return _buildContent(context, state);
    }

    // Fallback: initial state with no data yet.
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary500,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // TOP BAR — Quick-Commerce Header & Category Tabs
  // ──────────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, List<HomeCategory> categories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? AppColors.headerGradientDark
              : AppColors.headerGradientLight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shop name: small bold orange text at top-left above row 1
              Text(
                companyName,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.primary600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),

              // Row 1: small text "Delivery in" and large bold "15 minutes"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$deliveryPrefixText ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.neutral300
                              : AppColors.neutral800,
                        ),
                      ),
                      Text(
                        deliveryTimeText,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: -0.4,
                          color: isDark ? AppColors.white : AppColors.neutral900,
                        ),
                      ),
                    ],
                  ),
                  // User avatar / channel logo
                  ChannelLogo(
                    height: 36,
                    fallback: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.neutral800 : AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: isDark
                            ? AppColors.neutral200
                            : AppColors.neutral800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Row 2: location line "Home - Mangaluru" with dropdown arrow
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    deliveryLocationText,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? AppColors.neutral200 : AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: isDark ? AppColors.neutral200 : AppColors.neutral900,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 3: rounded white search bar with search icon and placeholder text
              GestureDetector(
                onTap: () => _openSearchPage(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.neutral800 : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.neutral700
                          : AppColors.neutral200,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 20,
                        color: isDark
                            ? AppColors.neutral400
                            : AppColors.neutral800,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          searchPlaceholderText,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: isDark
                                ? AppColors.neutral400
                                : AppColors.neutral500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.mic_none_outlined,
                        size: 20,
                        color: isDark
                            ? AppColors.neutral400
                            : AppColors.neutral800,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Category tabs: "All" first, then every top-level category.
              // Prefer CategoryBloc list (uncapped). HomeBloc categories are
              // limited by theme category_carousel filters.limit.
              BlocBuilder<CategoryBloc, CategoryState>(
                buildWhen: (previous, current) =>
                    previous.categories != current.categories,
                builder: (context, categoryState) {
                  final tabCategories = categoryState.categories.isNotEmpty
                      ? categoryState.categories
                            .map(_homeCategoryFromTabCategory)
                            .toList()
                      : categories;
                  return _buildCategoryTabsRow(context, tabCategories);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Map Categories-tab model → HomeCategory for tab row display only.
  HomeCategory _homeCategoryFromTabCategory(CategoryModel category) {
    return HomeCategory(
      id: category.id,
      numericId: category.numericId,
      name: category.name,
      slug: category.slug,
      logoUrl: category.logoUrl ?? category.logoPath,
      position: category.position ?? 0,
    );
  }

  Widget _buildCategoryTabsRow(
    BuildContext context,
    List<HomeCategory> categories,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Index 0 is the mock "All" tab (selected by default).
    final totalTabs = 1 + categories.length;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalTabs,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryTabIndex == index;
          final String label = index == 0 ? 'All' : categories[index - 1].name;
          final String? logoUrl =
              index == 0 ? null : categories[index - 1].logoUrl;

          return GestureDetector(
            onTap: () {
              // Mock only: update selected tab; no filtering.
              setState(() {
                _selectedCategoryTabIndex = index;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? AppColors.primary500.withValues(alpha: 0.22)
                        : const Color(0xFFFFF1E6))
                    : (isDark ? AppColors.neutral800 : AppColors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary500
                      : (isDark
                          ? AppColors.neutral700
                          : const Color(0xFFE2E4E8)),
                  width: isSelected ? 1.4 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon or network category logo
                  if (index == 0)
                    Icon(
                      Icons.grid_view_rounded,
                      size: 15,
                      color: isSelected
                          ? AppColors.primary500
                          : (isDark
                              ? AppColors.neutral300
                              : AppColors.neutral700),
                    )
                  else if (logoUrl != null && logoUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        logoUrl,
                        width: 15,
                        height: 15,
                        fit: BoxFit.contain,
                        errorBuilder: (_, error, stackTrace) => Icon(
                          Icons.category_outlined,
                          size: 15,
                          color: isSelected
                              ? AppColors.primary500
                              : (isDark
                                  ? AppColors.neutral400
                                  : AppColors.neutral700),
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.category_outlined,
                      size: 15,
                      color: isSelected
                          ? AppColors.primary500
                          : (isDark
                              ? AppColors.neutral400
                              : AppColors.neutral700),
                    ),
                  const SizedBox(width: 6),
                  // Label
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark
                              ? AppColors.primary500
                              : AppColors.primary600)
                          : (isDark
                              ? AppColors.neutral200
                              : AppColors.neutral800),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // ERROR STATE
  // ──────────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, HomeState state) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: isDark ? AppColors.neutral500 : AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(l10n.homeFailedToLoad, style: AppTextStyles.text3(context)),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? l10n.commonUnknownError,
              style: AppTextStyles.text5(context),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<HomeBloc>().add(const LoadHome()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.white,
              ),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // MAIN CONTENT — section order (under header/tabs):
  //  1. Server-driven banner carousel (image_carousel)
  //  2. Bestsellers grid
  //  3. Remaining server-driven sections (product carousels, static, services)
  //  4. Recently Viewed Products
  //  5. Back to Top
  // ──────────────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, HomeState state) {
    final l10n = AppLocalizations.of(context)!;
    final List<Widget> sections = [];

    // 1. Banner carousels directly under header/tabs (before Bestsellers)
    for (final tc in state.customizations) {
      if (tc.type != 'image_carousel') continue;
      final imagesRaw = tc.options['images'] as List? ?? [];
      final bannerImages = imagesRaw
          .map(
            (e) => BannerImage.fromJson(
              e is Map<String, dynamic> ? e : <String, dynamic>{},
            ),
          )
          .where((b) => b.imageUrl.isNotEmpty)
          .toList();
      if (bannerImages.isNotEmpty) {
        sections.add(
          ImageCarousel(
            images: bannerImages,
            onBannerTap: (banner) => _openLink(context, banner.link),
          ),
        );
      }
    }

    // 2. "Bestsellers" section (horizontal scrolling cards)
    if (state.categories.isNotEmpty) {
      sections.add(
        CategoryCarousel(
          categories: state.categories,
          onCategoryTap: (category) =>
              _openCategoryProducts(context, category),
          onSeeAll: () {
            if (AppNavigator.maybeOf(context) != null) {
              AppNavigator.goCategories(context);
            }
          },
        ),
      );
    }

    // 3. Remaining server-driven sections (skip banners + category_carousel)
    for (final tc in state.customizations) {
      switch (tc.type) {
        case 'image_carousel':
          // Already placed above Bestsellers
          break;

        case 'product_carousel':
          final products = state.productSections[tc.id] ?? [];
          if (products.isNotEmpty) {
            final filters =
                tc.options['filters'] as Map<String, dynamic>? ?? {};
            final title = tc.name.isNotEmpty
                ? tc.name
                : l10n.homeDefaultProducts;
            sections.add(
              _buildHorizontalProductSection(
                title: title,
                products: products,
                filters: filters,
              ),
            );
          }
          break;

        case 'static_content':
          final htmlRaw = tc.options['html'] as String? ?? '';
          final cssRaw = tc.options['css'] as String?;
          if (htmlRaw.isNotEmpty) {
            sections.add(
              StaticContentWidget(
                html: htmlRaw,
                css: cssRaw,
                baseUrl: Uri.parse(bagistoEndpoint).origin,
                onViewAllPressed: () => _openViewAll(context, tc.name),
                onLinkTap: (link) => _openLink(context, link),
              ),
            );
          }
          break;

        case 'services_content':
          final services = HomeService.listFromOptions(tc.options);
          if (services.isNotEmpty) {
            sections.add(ServicesContentSection(services: services));
          }
          break;

        case 'category_carousel':
          // Bestsellers already placed after banners
          break;
      }
    }

    // 4. Recently viewed
    sections.add(
      RecentlyViewedProductsSection(
        onProductTap: (product) => _openProductDetail(context, product),
      ),
    );

    // Add Back to Top button
    sections.add(_buildBackToTopButton());
    sections.add(const SizedBox(height: 16));

    return RefreshIndicator(
      color: AppColors.primary500,
      onRefresh: () async {
        final bloc = context.read<HomeBloc>();

        // Subscribe BEFORE dispatching to avoid missing the loaded emission
        final future = bloc.stream
            .firstWhere(
              (s) =>
                  s.status == HomeStatus.loaded || s.status == HomeStatus.error,
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => bloc.state, // fallback to current state
            );

        bloc.add(const RefreshHome());
        await future;
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        itemCount: sections.length,
        separatorBuilder: (context, index) => const SizedBox(height: 32),
        itemBuilder: (context, index) => sections[index],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // SECTION BUILDERS
  // ──────────────────────────────────────────────────────────────────────

  /// Featured Products grid section with 6 products in random order.
  /// Uses Wrap instead of GridView to avoid fixed-height overflow.
  /// Matches Figma node 86:976 flex-wrap layout.
  Widget _buildFeaturedProductsGridSection({
    required BuildContext context,
    required String title,
    required List<HomeProduct> products,
  }) {
    // Shuffle products randomly
    final random = Random();
    final shuffledProducts = List<HomeProduct>.from(products)..shuffle(random);

    // Take first 6 products (or less if not enough)
    final displayProducts = shuffledProducts.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeAll: () =>
              _openViewAll(context, title, filters: const {'featured': 1}),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth > 0
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;
            // 3 columns: 20px padding each side + 2×12px gaps → available / 3
            final cardWidth = (screenWidth - 40 - 24) / 3;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 12, // horizontal gap between cards (Figma 12px)
                runSpacing: 18, // vertical gap between rows (Figma 18px)
                children: displayProducts.map((product) {
                  return BlocBuilder<WishlistCubit, WishlistCubitState>(
                    builder: (context, wishlistState) {
                      final pid =
                          product.numericId ??
                          int.tryParse(product.id.split('/').last) ??
                          0;
                      return ProductCardSmall(
                        key: ValueKey('featured_${product.id}'),
                        product: product,
                        cardWidth: cardWidth,
                        onTap: () => _openProductDetail(context, product),
                        onAddToCart: () => _addProductToCart(context, product),
                        isWishlisted:
                            pid > 0 && wishlistState.isWishlisted(pid),
                        isWishlistProcessing:
                            pid > 0 && wishlistState.isProcessing(pid),
                        onWishlistTap: () => _toggleWishlist(context, product),
                      );
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Horizontal scrolling product section (Featured Products, Recently Viewed).
  Widget _buildHorizontalProductSection({
    required String title,
    required List<HomeProduct> products,
    Map<String, dynamic> filters = const {},
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeAll: () => _openViewAll(context, title, filters: filters),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth > 0
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;
            // 20px padding each side, 12px gaps, two cards plus a peek of
            // the third so the row reads as horizontally scrollable.
            final cardWidth = (screenWidth - 40 - 24) / 2.3;
            // Add a little extra space for price/rating and ADD button on all devices.
            final listHeight = cardWidth + 104;
            return SizedBox(
              height: listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return BlocBuilder<WishlistCubit, WishlistCubitState>(
                    builder: (context, wishlistState) {
                      final pid =
                          product.numericId ??
                          int.tryParse(product.id.split('/').last) ??
                          0;
                      return ProductCardLarge(
                        key: ValueKey('prod_large_${product.id}'),
                        product: product,
                        cardWidth: cardWidth,
                        onTap: () => _openProductDetail(context, product),
                        onAddToCart: () => _addProductToCart(context, product),
                        isWishlisted:
                            pid > 0 && wishlistState.isWishlisted(pid),
                        isWishlistProcessing:
                            pid > 0 && wishlistState.isProcessing(pid),
                        onWishlistTap: () => _toggleWishlist(context, product),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  /// "Back to Top" pill button.
  Widget _buildBackToTopButton() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: GestureDetector(
        onTap: _scrollToTop,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral700 : AppColors.neutral200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.homeBackToTop,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? AppColors.neutral200 : AppColors.neutral800,
            ),
          ),
        ),
      ),
    );
  }
}
