import 'package:go_router/go_router.dart';
import 'package:store_manager/core/services/storage_service.dart';
import 'package:store_manager/features/auth/screens/login_screen.dart';
import 'package:store_manager/features/auth/screens/splash_screen.dart';
import 'package:store_manager/features/categories/screens/categories_screen.dart';
import 'package:store_manager/features/categories/screens/category_form_screen.dart';
import 'package:store_manager/features/dashboard/screens/dashboard_screen.dart';
import 'package:store_manager/features/pos/screens/pos_screen.dart';
import 'package:store_manager/features/products/screens/product_form_screen.dart';
import 'package:store_manager/features/products/screens/products_screen.dart';

final _storage = StorageService();

final appRouter = GoRouter(
  initialLocation: '/',

  redirect: (context, state) async {
    final token = await _storage.getToken();
    final role = await _storage.getRole();

    final loggedIn = token != null;

    final isLogin = state.matchedLocation == '/login';
    final isSplash = state.matchedLocation == '/';

    // Not logged in → send to login.
    if (!loggedIn && !isLogin && !isSplash) {
      return '/login';
    }

    // Already logged in → don't go back to login.
    if (loggedIn && isLogin) {
      return role == 'ADMIN' ? '/dashboard' : '/pos';
    }

    // Cashiers cannot access admin pages.
    if (role == 'CASHIER') {
      if (state.matchedLocation == '/dashboard' ||
          state.matchedLocation == '/categories' ||
          state.matchedLocation == '/products' ||
          state.matchedLocation == '/categories/new' ||
          state.matchedLocation.contains('/categories/')) {
        return '/pos';
      }
    }

    return null;
  },

  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),

    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),

    GoRoute(
      path: '/categories/new',
      builder: (context, state) => const CategoryFormScreen(),
    ),

    GoRoute(
      path: '/categories/:id/edit',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);

        return CategoryFormScreen(categoryId: id);
      },
    ),

    // Temporary POS page until we build the real POS.
    GoRoute(path: '/pos', builder: (context, state) => const PosScreen()),

    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsScreen(),
    ),

    GoRoute(
      path: '/products/new',
      builder: (context, state) => const ProductFormScreen(),
    ),

    GoRoute(
      path: '/products/:id/edit',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);

        return ProductFormScreen(productId: id);
      },
    ),
  ],
);
