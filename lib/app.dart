import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, theme, _) {  // <-- changed '__' to '_'
          return MaterialApp(
            title: 'Mobimart Shop',
            debugShowCheckedModeBanner: false,
            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,
            themeMode: theme.themeMode,
            initialRoute: AppRoutes.login,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
