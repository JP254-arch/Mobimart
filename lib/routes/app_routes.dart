import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/products/screens/product_list_screen.dart';
import '../features/cart/screens/cart_screen.dart';


class AppRoutes {
static const login = '/login';
static const register = '/register';
static const products = '/products';
static const cart = '/cart';


static Map<String, WidgetBuilder> routes = {
login: (_) => const LoginScreen(),
register: (_) => const RegisterScreen(),
products: (_) => const ProductListScreen(),
cart: (_) => const CartScreen(),
};
}