import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'controllers/store_controller.dart';
import 'theme/app_theme.dart';
import 'views/account_page.dart';
import 'views/cart_page.dart';
import 'views/catalog_page.dart';
import 'views/favorites_page.dart';
import 'views/home_page.dart';

class AuroraApp extends StatelessWidget {
  const AuroraApp({super.key, this.authEnabled = false});

  final bool authEnabled;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AURORA',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AuroraShell(authEnabled: authEnabled),
    );
  }
}

class AuroraShell extends StatefulWidget {
  const AuroraShell({super.key, this.authEnabled = false});

  final bool authEnabled;

  @override
  State<AuroraShell> createState() => _AuroraShellState();
}

class _AuroraShellState extends State<AuroraShell> {
  late final StoreController controller = StoreController(authEnabled: widget.authEnabled);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(controller: controller),
      CatalogPage(controller: controller),
      CartPage(controller: controller),
      FavoritesPage(controller: controller),
      AccountPage(controller: controller),
    ];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            titleSpacing: 18,
            title: GestureDetector(
              onTap: () => controller.setTab(0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/aurora-logo.svg', width: 30, height: 30),
                  const SizedBox(width: 10),
                  const Text(
                    'AURORA',
                    style: TextStyle(
                      letterSpacing: 3,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => controller.setTab(1),
                icon: const Icon(Icons.search_rounded),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _CartAction(
                  count: controller.cartCount,
                  onTap: () => controller.setTab(2),
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: controller.activeTab,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.activeTab,
            onDestinationSelected: controller.setTab,
            backgroundColor: AppColors.surface,
            elevation: 0,
            height: 64,
            indicatorColor: AppColors.textPrimary.withValues(alpha: 0.08),
            shadowColor: Colors.transparent,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Catégories',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag_rounded),
                label: 'Panier',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: 'Favoris',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Compte',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartAction extends StatelessWidget {
  const _CartAction({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary),
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
