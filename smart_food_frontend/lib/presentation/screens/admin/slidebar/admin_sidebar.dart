import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<String> menuItems = const [
    "Dashboard",
    "Users",
    "Merchant Pending",
    "Merchant All",
    "Shipper Pending",
    "Shipper All",
    "Vouchers",
    "Categories",
    "Orders",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF1E1E2C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "ADMIN PANEL",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;

                return InkWell(
                  onTap: () => onItemSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blueAccent.withOpacity(0.6)
                          : Colors.transparent,
                    ),
                    child: Text(
                      menuItems[index],
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}