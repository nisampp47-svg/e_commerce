import 'package:e_commerce/core/app_router.dart';
import 'package:e_commerce/core/apptheme.dart';
import 'package:e_commerce/providers/auth_provider.dart';
import 'package:e_commerce/providers/cart_provider.dart';
import 'package:e_commerce/providers/navigation_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");







    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Missing Supabase credentials in .env file');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    final authController = AuthController();
    // Initialize router ONCE to prevent black screen on rebuilds
    final router = AppRouter.router(authController);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authController),
          ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()),
          ChangeNotifierProvider(create: (_) => NavigationViewmodel()),
        ],
        child: MyApp(router: router),
      ),
    );
  } catch (e) {
    debugPrint("Critical Initialization Error: $e");
  }
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'E-Commerce',
          themeMode: currentMode,
          // Using your AppThemes for a professional look
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          routerConfig: router,
        );
      },
    );
  }
}
