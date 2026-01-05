import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/services/admin_service.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/auth_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool loading = false;
  Map<String, dynamic> stats = {
    "users_total": 0,
    "merchants_total": 0,
    "shippers_total": 0,
    "vouchers_total": 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => loading = true);
    final data = await AdminService.fetchStats();
    setState(() {
      stats = {
        "users_total": data["users_total"] ?? 0,
        "merchants_total": data["merchants_total"] ?? 0,
        "shippers_total": data["shippers_total"] ?? 0,
        "vouchers_total": data["vouchers_total"] ?? 0,
      };
      loading = false;
    });
  }

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
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF5B7B56)),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF5B7B56)),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  icon: Icons.local_offer,
                  label: "Vouchers",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.vouchersPage),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.2,
              children: [
                _StatCard(
                    title: "Users",
                    value: loading ? "..." : "${stats["users_total"]}",
                    color: Colors.blue),
                _StatCard(
                    title: "Merchants",
                    value: loading ? "..." : "${stats["merchants_total"]}",
                    color: Colors.green),
                _StatCard(
                    title: "Shippers",
                    value: loading ? "..." : "${stats["shippers_total"]}",
                    color: Colors.orange),
                _StatCard(
                    title: "Vouchers",
                    value: loading ? "..." : "${stats["vouchers_total"]}",
                    color: Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
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
}

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
