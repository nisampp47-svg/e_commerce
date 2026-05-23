import 'package:e_commerce/providers/auth_provider.dart';
import 'package:e_commerce/providers/cart_provider.dart';
import 'package:e_commerce/providers/navigation_viewmodel.dart';
import 'package:e_commerce/screen/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Warm up SharedPreferences before Supabase
    await SharedPreferences.getInstance();

    await Supabase.initialize(
      url: 'https://kdudyqnqoisngtyklixj.supabase.co',
      anonKey: 'sb_publishable_Yh95ta_K8Yi-Q4iG9badtQ_VVhfvqlr',
    );
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()),
        ChangeNotifierProvider(create: (_) => NavigationViewmodel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
