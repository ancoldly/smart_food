import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/auth_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await auth.logout();
    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.login);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã đăng xuất")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //───────────────────────────────
            //        QUICK MENU
            //───────────────────────────────

            const Text(
              "Quick Menu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1,
              children: [
                _menuItem(
                  icon: Icons.person,
                  label: "Users",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.usersPage),
                ),
                _menuItem(
                  icon: Icons.storefront,
                  label: "Merchants",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.merchantsAll),
                ),
                _menuItem(
                  icon: Icons.storefront,
                  label: "Merchants Pending",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.merchantsPending),
                ),
                _menuItem(
                  icon: Icons.delivery_dining,
                  label: "Shippers",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.shippersAll),
                ),
                
                _menuItem(
                  icon: Icons.delivery_dining,
                  label: "Shippers Pending",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.shippersPending),
                ),
                _menuItem(
                  icon: Icons.receipt_long,
                  label: "Orders",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.ordersPage),
                ),
                _menuItem(
                  icon: Icons.category,
                  label: "Categories",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.categoriesPage),
                ),
                _menuItem(
                  icon: Icons.local_offer,
                  label: "Vouchers",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.vouchersPage),
                ),
              ],
            ),

            const SizedBox(height: 30),

            //───────────────────────────────
            //         DASHBOARD STATS
            //───────────────────────────────

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.2,
              children: const [
                _StatCard(title: "Total Users", value: "1200", color: Colors.blue),
                _StatCard(title: "Merchants", value: "85", color: Colors.green),
                _StatCard(title: "Shippers", value: "40", color: Colors.orange),
                _StatCard(title: "Orders Today", value: "230", color: Colors.red),
              ],
            ),

            const SizedBox(height: 30),

            //───────────────────────────────
            //          RECENT ORDERS
            //───────────────────────────────

            const Text(
              "Recent Orders",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _orderCard("#1001", "Nguyen Van A", "Bún bò", "Completed"),
            _orderCard("#1002", "Tran Thi B", "Trà sữa", "Preparing"),
            _orderCard("#1003", "Le Van C", "Cơm gà", "Pending"),
            _orderCard("#1004", "Pham Minh D", "Pizza", "Canceled"),
          ],
        ),
      ),
    );
  }

  //────────────────────────────────────────
  //          QUICK MENU ITEM
  //────────────────────────────────────────
  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  //────────────────────────────────────────
  //          ORDER CARD (LIST ITEM)
  //────────────────────────────────────────
  Widget _orderCard(String id, String user, String item, String status) {
    Color statusColor;

    switch (status) {
      case "Completed":
        statusColor = Colors.green;
        break;
      case "Preparing":
        statusColor = Colors.orange;
        break;
      case "Pending":
        statusColor = Colors.blue;
        break;
      case "Canceled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          id,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer: $user"),
            Text("Item: $item"),
            const SizedBox(height: 6),
            Chip(
              label: Text(status),
              backgroundColor: statusColor.withOpacity(0.15),
              labelStyle: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//────────────────────────────────────────
//               STAT CARD
//────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
