import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:smart_food_frontend/presentation/screens/merchant/merchant_home_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_orders_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/menu_category_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_profile_screen.dart';

class MainBottomNavMerchant extends StatefulWidget {
  final int initialIndex;

  const MainBottomNavMerchant({super.key, this.initialIndex = 0});

  @override
  State<MainBottomNavMerchant> createState() => _MainBottomNavMerchantState();
}

class _MainBottomNavMerchantState extends State<MainBottomNavMerchant> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    MerchantHomeScreen(),
    MerchantOrdersScreen(),
    MenuCategoryScreen(),
    MerchantProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60,
        color: const Color(0xFFFFB347),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: const Color(0xFFFF914D),
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        items: const [
          Icon(Icons.store, size: 30, color: Colors.white),          // Dashboard
          Icon(Icons.receipt_long, size: 30, color: Colors.white),  // Orders
          Icon(Icons.restaurant_menu, size: 30, color: Colors.white), // Menu
          Icon(Icons.grid_view, size: 30, color: Colors.white), // Profile
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
