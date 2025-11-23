import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/categories_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/dashboard_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/merchants_all_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/merchants_pending_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/orders_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/shippers_all_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/shippers_pending_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/users_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/pages/vouchers_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/slidebar/admin_sidebar.dart';


class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    UsersPage(),
    MerchantsPendingPage(),
    MerchantsAllPage(),
    ShippersPendingPage(),
    ShippersAllPage(),
    VouchersPage(),
    CategoriesPage(),
    OrdersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey.shade100,
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
