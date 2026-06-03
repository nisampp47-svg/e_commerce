import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../screen/auth/auth_toggle_page.dart';
import '../screen/main_navigation_screen.dart';
import '../screen/home_screen.dart';
import '../screen/Catelog_screen.dart';
import '../screen/cart_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/product_screen.dart';
import '../model/product_model.dart';
import '../data/repositories/product_data.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _router;

  static GoRouter router(AuthController authController) {
    _router ??= GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authController,
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final isLoggingIn = state.matchedLocation == '/auth';

        if (session == null) {
          return isLoggingIn ? null : '/auth';
        }

        if (isLoggingIn) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => const LoginRegister(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainNavigationScreen(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MyHomeScreen(),
              ),
            ),
            GoRoute(
              path: '/catalog',
              name: 'catalog',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CatalogScreen(),
              ),
            ),
            GoRoute(
              path: '/cart',
              name: 'cart',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CartScreen(),
              ),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/product/:id',
          name: 'product_detail',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id'];
            final product = state.extra as ProductModel? ??
                products.firstWhere((p) => p.id == id,
                    orElse: () => products.first);
            return ProductHeroScreen(product: product);
          },
        ),
      ],
    );
    return _router!;
  }
}
