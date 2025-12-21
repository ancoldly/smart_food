import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/employee_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  @override
  void initState() {
    super.initState();

    // Load employees from API
    Future.microtask(() {
      Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const green = Color(0xFF255B36);

    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: bg,

      // ======================
      //       APPBAR
      // ======================
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Quản lý nhân viên",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: green),
        ),
      ),

      body: Consumer<EmployeeProvider>(
        builder: (context, empProvider, _) {
          final employees = empProvider.employees;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            children: [
              // ==============================
              // OWNER SECTION
              // ==============================
              _employeeItem(
                name: user?.fullName ?? "Chủ cửa hàng",
                role: "Chủ cửa hàng",
                avatar: user?.avatar ?? "",
              ),

              const SizedBox(height: 24),

              // ==============================
              // TITLE: EMPLOYEE LIST
              // ==============================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nhân viên của bạn",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Quản lý quyền truy cập",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.addEmployee);
                    },
                    icon: const Icon(Icons.add_circle_outline,
                        color: green, size: 26),
                  )
                ],
              ),

              const SizedBox(height: 12),

              // ==============================
              // EMPLOYEE LIST
              // ==============================
              if (empProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (employees.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Center(
                    child: Text(
                      "Chưa có nhân viên nào",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              else
                ...employees.map((e) {
                  return _employeeItem(
                      name: e.fullName,
                      role: _convertRole(e.role),
                      avatar: e.avatarImage ?? "",
                      showArrow: true,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.detailEmployee,
                          arguments: e.id, 
                        );
                      });
                }).toList(),
            ],
          );
        },
      ),
    );
  }

  // Convert backend role → label VN
  String _convertRole(String role) {
    switch (role) {
      case "manager":
        return "Quản lý ca";
      case "cashier":
        return "Thu ngân";
      case "delivery":
        return "Giao hàng nội bộ";
      default:
        return "Nhân viên";
    }
  }

  // ------------------------
  // EMPLOYEE ITEM WIDGET
  // ------------------------
  Widget _employeeItem({
    required String name,
    required String role,
    required String avatar,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: avatar.isNotEmpty
                ? NetworkImage(avatar)
                : const AssetImage("assets/images/default_avatar.png")
                    as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          if (showArrow)
            IconButton(
              padding: EdgeInsets.zero, // không tạo khoảng trắng dư
              constraints: const BoxConstraints(), // thu nhỏ hitbox
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black45,
              ),
              onPressed: onTap, // bạn sẽ truyền hàm onTap khi gọi widget
            ),
        ],
      ),
    );
  }
}
