import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/screens/add_address_screen.dart';
import 'package:smart_food_frontend/presentation/screens/address_screen.dart';
import 'package:smart_food_frontend/presentation/screens/profile_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/profile_screen.dart';

import 'package:smart_food_frontend/presentation/screens/splash_screen.dart';
import 'package:smart_food_frontend/presentation/screens/error_screen.dart';
import 'package:smart_food_frontend/presentation/screens/login_screen.dart';
import 'package:smart_food_frontend/presentation/screens/register_screen.dart';
import 'package:smart_food_frontend/presentation/screens/home_screen.dart';
import 'package:smart_food_frontend/presentation/screens/main_bottom_nav.dart';

class AppRoutes {
  static const String splash = "/splash";
  static const String login = "/login";
  static const String register = "/register";
  static const String main = "/main";
  static const String home = "/home";
  static const String profile = "/profile";
  static const String profileDetail = "/profile_detail";
  static const String address = "/address";
  static const String addAddress = "/add_address";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainBottomNav());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case profileDetail:
        return MaterialPageRoute(builder: (_) => const ProfileDetailScreen());
      
      case address:
        return MaterialPageRoute(builder: (_) => const AddressScreen());

      case addAddress:
        return MaterialPageRoute(builder: (_) => const AddAddressScreen());

      default:
        return MaterialPageRoute(builder: (_) => const ErrorScreen());
    }
  }
}
