import 'package:trinity/utils/api/user.dart';
import 'package:trinity/utils/firebase_utils.dart';
import 'package:trinity/utils/jwt_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/stores/cart_store.dart';
import 'package:trinity/stores/user_store.dart';
import 'package:trinity/utils/http.dart';
import 'package:trinity/widgets/app_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TrinityApp());
}

class TrinityApp extends StatelessWidget {
  const TrinityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserStore()),
        ChangeNotifierProvider(create: (context) => CartStore()),
      ],
      child: Builder(
        builder: (providerContext) {
          // Initialize ApiClient after providers are available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ApiClient.initialize(providerContext);
          });

          return ShadTheme(
            data: ShadThemeData(
              brightness: Brightness.dark,
              colorScheme: const ShadZincColorScheme.dark(),
            ),
            child: AppRoutesWrapper(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Trinity App',
                theme: ThemeData(
                  colorScheme: const ColorScheme.dark(),
                  useMaterial3: true,
                ),
                builder: (context, child) {
                  return ShadToaster(child: child!);
                },
                home: const AppScaffold(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  String? jwtToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJwtToken();
  }

  Future<void> _loadJwtToken() async {
    // Schedule this after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      debugPrint("loading page");
      setState(() {
        isLoading = true;
      });

      final jwtHandler = JwtHandler();
      final jwt = await jwtHandler.getToken();

      if (!mounted) return;

      // Load cart data from storage regardless of authentication status
      try {
        final cartStore = Provider.of<CartStore>(context, listen: false);
        await cartStore.loadFromStorage();
        debugPrint("Cart loaded from storage");
      } catch (e) {
        debugPrint("Error loading cart from storage: $e");
      }

      if (jwt != null && jwt != "") {
        setState(() {
          jwtToken = jwt;
        });

        try {
          if (!mounted) return;
          // Access UserStore directly from this context
          final userStore = Provider.of<UserStore>(context, listen: false);
          final userApi = UserApi();

          // Load shopping list
          userStore.loadShoppingList();

          userApi
              .getUser()
              .then((user) {
                if (mounted) {
                  userStore.setUser(user);
                }
              })
              .catchError((e) {
                debugPrint("Error loading user: $e");
              });
        } catch (e) {
          debugPrint("Error accessing UserStore: $e");
        }
      } else {
        if (!mounted) return;
        // Load shopping list even if no user is authenticated
        Provider.of<UserStore>(context, listen: false).loadShoppingList();
      }

      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        await initFirebase(context);
        debugPrint("page loaded");
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Chargement...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        )
        : AppLayout(
          currentPath: AppRoutes.of(context).currentPath,
          onNavigationChanged:
              (routeName) => AppRoutes.of(context).navigateTo(routeName),
          child: Navigator(
            key: AppRoutes.navigatorKey,
            initialRoute: AppRoutes.initialRoute,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          ),
        );
  }
}
