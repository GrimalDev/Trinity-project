import 'package:flutter/material.dart';
import 'package:trinity/screens/cart_page.dart';
import 'package:trinity/screens/home_page.dart';
import 'package:trinity/screens/login_page.dart';
import 'package:trinity/screens/order_history.dart';
import 'package:trinity/screens/scan_page.dart';
import 'package:trinity/screens/user_page.dart';

class AppRoutes {
  AppRoutes._();

  // Navigator key for global navigation
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Routes names
  static const String home = '/';
  static const String cart = '/cart';
  static const String scan = '/scan';
  static const String orderHistory = '/order-history';
  static const String profile = '/profile';
  static const String login = '/login';

  static const String initialRoute = home;

  // Current route state
  static String _currentPath = home;
  // Instance getter that returns the static value
  String get currentPath => AppRoutes._currentPath;

  // Listeners for path changes
  static final List<Function(String)> _pathChangeListeners = [];

  // Add listener for path changes
  static void addPathChangeListener(Function(String) listener) {
    _pathChangeListeners.add(listener);
  }

  // Remove listener
  static void removePathChangeListener(Function(String) listener) {
    _pathChangeListeners.remove(listener);
  }

  // Update current path when navigating
  static void _updateCurrentPath(String path) {
    if (_currentPath != path) {
      _currentPath = path;
      // Notify all listeners
      for (var listener in _pathChangeListeners) {
        listener(path);
      }
    }
  }

  // Access AppRoutes from context
  static AppRoutes of(BuildContext context) {
    return _AppRoutesProvider.of(context);
  }

  // Navigation method by route name
  void navigateTo(String routeName) {
    // Update current path when navigating
    AppRoutes._updateCurrentPath(routeName);
    navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  static void navigateToLogin() {
    AppRoutes._updateCurrentPath(login);
    navigatorKey.currentState?.pushReplacementNamed(login);
  }

  // Route generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Update current path when route is generated
    if (settings.name != null) {
      _updateCurrentPath(settings.name!);
    }

    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case cart:
        return MaterialPageRoute(builder: (_) => CartPage());
      case scan:
        return MaterialPageRoute(builder: (_) => BarcodeScannerApp());
      case orderHistory:
        return MaterialPageRoute(builder: (_) => OrderHistoryPage());
      case profile:
        return MaterialPageRoute(builder: (_) => UserPage());
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      default:
        return MaterialPageRoute(builder: (_) => HomePage());
    }
  }
}

// Provider to access AppRoutes from context
class _AppRoutesProvider extends InheritedWidget {
  final AppRoutes routes = AppRoutes._();

  _AppRoutesProvider({required super.child});

  static AppRoutes of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_AppRoutesProvider>();
    if (provider == null) {
      throw Exception('No _AppRoutesProvider found in context');
    }
    return provider.routes;
  }

  @override
  bool updateShouldNotify(_AppRoutesProvider oldWidget) => false;
}

// Wrap MaterialApp with this provider
class AppRoutesWrapper extends StatelessWidget {
  final Widget child;

  const AppRoutesWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return _AppRoutesProvider(child: child);
  }
}
