import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, CartService>(
          create: (ctx) => CartService(null, []),
          update: (ctx, auth, previous) => CartService(auth.token, previous == null ? [] : previous.items),
        ),
        ProxyProvider<AuthService, ProductService>( // Simple proxy for non-change notifier
          update: (ctx, auth, _) => ProductService(auth.token),
        ),
        ProxyProvider<AuthService, OrderService>(
          update: (ctx, auth, _) => OrderService(auth.token),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Laviade',
          theme: AppTheme.lightTheme,
          home: auth.isAuthenticated 
            ? const MainNavScreen() 
            : FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (ctx, snapshot) => 
                  snapshot.connectionState == ConnectionState.waiting 
                  ? const SplashScreen() 
                  : const LoginScreen(),
              ),
        ),
      ),
    );
  }
}
