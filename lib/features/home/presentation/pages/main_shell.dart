import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../category/presentation/pages/category_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../auth/presentation/pages/account_page.dart';
import 'home_page.dart';

/// Main Shell with 5 bottom navigation tabs:
/// Home(0) | Order Again(1) | Categories(2) | Cart(3) | Account(4)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// GlobalKey for accessing MainShellState from anywhere in the app
  static final GlobalKey<MainShellState> navigatorKey = GlobalKey<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0; // Start on Home

  /// Tab history stack for proper back navigation.
  final List<int> _tabHistory = [0]; // initial tab

  void switchToTab(int index) {
    // Map legacy 4-tab AppNavigator indices if coming from AppNavigator callers:
    // 0: home -> 0
    // 1: categories -> 2
    // 2: cart -> 3
    // 3: account -> 4
    int targetIndex = index;
    if (index == AppNavigator.categoriesTab) {
      targetIndex = 2;
    } else if (index == AppNavigator.cartTab) {
      targetIndex = 3;
    } else if (index == AppNavigator.accountTab) {
      targetIndex = 4;
    }

    _selectTab(targetIndex);
  }

  void _selectTab(int targetIndex) {
    if (targetIndex < 0 || targetIndex > 4) return;

    if (_currentIndex != targetIndex) {
      setState(() {
        if (_tabHistory.isEmpty || _tabHistory.last != _currentIndex) {
          _tabHistory.add(_currentIndex);
        }
        _currentIndex = targetIndex;
      });
    }

    // Cart is now tab 3
    if (targetIndex == 3) {
      context.read<CartBloc>().add(LoadCart());
    }
  }

  int get currentTab => _currentIndex;

  /// Handle Android/iOS back button: go to previous tab, then exit
  Future<bool> _onWillPop() async {
    if (_tabHistory.isNotEmpty) {
      final previousTab = _tabHistory.removeLast();
      setState(() => _currentIndex = previousTab);
      return false; // Don't exit app
    }
    return true; // Exit app
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AppNavigator(
        switchToTab: switchToTab,
        currentTab: () => _currentIndex,
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              const HomePage(),
              const _OrderAgainPlaceholderScreen(),
              const CategoryPage(),
              const CartPage(),
              AccountPage(isActive: _currentIndex == 4),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context, isDark),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : AppColors.neutral50,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.transparent : AppColors.neutral100,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: l10n.mainTabHome,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.replay_outlined,
                activeIcon: Icons.replay,
                label: 'Order Again',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view,
                label: l10n.mainTabCategories,
              ),
              _buildNavItemWithBadge(
                index: 3,
                icon: Icons.shopping_cart_outlined,
                activeIcon: Icons.shopping_cart,
                label: l10n.mainTabCart,
                badgeCount: context.watch<CartBloc>().state.itemCount,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: l10n.mainTabAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _selectTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive
                  ? AppColors.primary500
                  : isDark
                      ? AppColors.neutral300
                      : AppColors.neutral800,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? AppColors.primary500
                    : isDark
                        ? AppColors.neutral300
                        : AppColors.neutral800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int badgeCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _selectTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive
                      ? AppColors.primary500
                      : isDark
                          ? AppColors.neutral300
                          : AppColors.neutral800,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? AppColors.primary500
                    : isDark
                        ? AppColors.neutral300
                        : AppColors.neutral800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MOCK tab screen for "Order Again"
class _OrderAgainPlaceholderScreen extends StatelessWidget {
  const _OrderAgainPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.neutral900 : AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Order Again',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppColors.neutral900 : AppColors.white,
        foregroundColor: isDark ? AppColors.neutral100 : AppColors.neutral900,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.replay_rounded,
                  size: 36,
                  color: AppColors.primary500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No previous orders',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Items you previously ordered will show up here for fast 1-tap reordering.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
