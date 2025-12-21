import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';

import 'package:smart_food_frontend/providers/auth_provider.dart';
import 'package:smart_food_frontend/providers/category_provider.dart';
import 'package:smart_food_frontend/providers/employee_provider.dart';
import 'package:smart_food_frontend/providers/payment_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/product_provider.dart';
import 'package:smart_food_frontend/providers/option_group_provider.dart';
import 'package:smart_food_frontend/providers/option_provider.dart';
import 'package:smart_food_frontend/providers/option_group_template_provider.dart';
import 'package:smart_food_frontend/providers/option_template_provider.dart';
import 'package:smart_food_frontend/providers/product_option_group_provider.dart';
import 'package:smart_food_frontend/providers/voucher_provider.dart';
import 'package:smart_food_frontend/providers/store_tag_provider.dart';
import 'package:smart_food_frontend/providers/favorite_provider.dart';
import 'package:smart_food_frontend/providers/store_menu_provider.dart';
import 'package:smart_food_frontend/providers/store_hours_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OptionGroupProvider()),
        ChangeNotifierProvider(create: (_) => OptionProvider()),
        ChangeNotifierProvider(create: (_) => OptionGroupTemplateProvider()),
        ChangeNotifierProvider(create: (_) => OptionTemplateProvider()),
        ChangeNotifierProvider(create: (_) => ProductOptionGroupProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => StoreTagProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => StoreMenuProvider()),
        ChangeNotifierProvider(create: (_) => StoreHoursProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,      
        title: 'Pushan Food',
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}
