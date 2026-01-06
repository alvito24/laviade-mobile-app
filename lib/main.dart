import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'services/address_service.dart';
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
        // Auth Service - core authentication
        ChangeNotifierProvider(create: (_) => AuthService()),

        // Cart Service - depends on auth token
        ChangeNotifierProxyProvider<AuthService, CartService>(
          create: (ctx) => CartService(null, []),
          update: (ctx, auth, previous) =>
              CartService(auth.token, previous == null ? [] : previous.items),
        ),

        // Product Service - optionally uses auth token
        ProxyProvider<AuthService, ProductService>(
          update: (ctx, auth, _) => ProductService(auth.token),
        ),

        // Order Service - depends on auth token
        ProxyProvider<AuthService, OrderService>(
          update: (ctx, auth, _) => OrderService(auth.token),
        ),

        // Address Service - depends on auth token
        ProxyProvider<AuthService, AddressService>(
          update: (ctx, auth, _) => AddressService(auth.token),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'LAVIADE',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: auth.isAuthenticated
              ? const MainNavScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreen();
                    }
                    // After auto-login attempt, check if authenticated
                    if (auth.isAuthenticated) {
                      return const MainNavScreen();
                    }
                    return const LoginScreen();
                  },
                ),
        ),
      ),
    );
  }
}
