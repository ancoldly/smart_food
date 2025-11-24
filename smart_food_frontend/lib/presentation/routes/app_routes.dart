import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/categories_page.dart';

//admin
import 'package:smart_food_frontend/presentation/screens/admin/pages/dashboard_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/merchants_all_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/merchants_pending_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/orders_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/shippers_all_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/shippers_pending_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/users_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/vouchers_page.dart';

//client
import 'package:smart_food_frontend/presentation/screens/client/add_address_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/add_bank_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/address_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/category_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/help_center_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/payment_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/profile_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/profile_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/splash_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/error_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/login_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/register_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/home_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/main_bottom_nav.dart';

//merchant
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_start_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/on_step_one_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_pending_screen.dart';

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
  static const String payment = "/payment";
  static const String addBank = "/add_bank";
  static const String category = "/category";
  static const String helpCenter = "/help_center";

  static const String merchantStart = "/merchant_start";
  static const String onStepOne = "/on_step_one";
  static const String merchantPending = "/merchant_pending";

  static const String adminDashboard = "/admin_dashboard";
  static const String usersPage = "/admin_users_page";
  static const String merchantsAll = "/admin_merchants_all";
  static const String merchantsPending = "/admin_merchants_pending";
  static const String shippersAll = "/admin_shippers_all";
  static const String shippersPending = "/admin_shippers_pending";
  static const String ordersPage = "/admin_orders_page";
  static const String categoriesPage = "/admin_categories_page";
  static const String vouchersPage = "/admin_vouchers_page";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case main:
        final int index = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => MainBottomNav(initialIndex: index),
        );

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

      case payment:
        return MaterialPageRoute(builder: (_) => const PaymentScreen());

      case addBank:
        return MaterialPageRoute(builder: (_) => const AddBankScreen());

      case category:
        return MaterialPageRoute(builder: (_) => const CategoryScreen());

      case helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpCenterScreen());

      case merchantStart:
        return MaterialPageRoute(builder: (_) => const MerchantStartScreen());

      case onStepOne:
        return MaterialPageRoute(builder: (_) => const OnStepOneScreen());

      case merchantPending:
        return MaterialPageRoute(builder: (_) => const MerchantPendingScreen());

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      case usersPage:
        return MaterialPageRoute(builder: (_) => const UsersPage());

      case merchantsAll:
        return MaterialPageRoute(builder: (_) => const MerchantsAllPage());

      case shippersAll:
        return MaterialPageRoute(builder: (_) => const ShippersAllPage());

      case merchantsPending:
        return MaterialPageRoute(builder: (_) => const MerchantsPendingPage());

      case shippersPending:
        return MaterialPageRoute(builder: (_) => const ShippersPendingPage());

      case ordersPage:
        return MaterialPageRoute(builder: (_) => const OrdersPage());

      case categoriesPage:
        return MaterialPageRoute(builder: (_) => const CategoriesPage());

      case vouchersPage:
        return MaterialPageRoute(builder: (_) => const VouchersPage());

      default:
        return MaterialPageRoute(builder: (_) => const ErrorScreen());
    }
  }
}
