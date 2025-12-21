import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/providers/employee_provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;
  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<EmployeeProvider>(context, listen: false)
          .loadEmployee(widget.employeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const green = Color(0xFF255B36);
    const borderColor = Color(0xFFE1C59A);

    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final employee = employeeProvider.selectedEmployee;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chi tiết nhân viên",
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
      body: employee == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ============================
                  //        Avatar
                  // ============================
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    backgroundImage: employee.avatarImage != null
                        ? NetworkImage(employee.avatarImage!)
                        : const AssetImage("./assets/images/default_avatar.png")
                            as ImageProvider,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    employee.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    _convertRole(employee.role),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ============================
                  // INFO CARD
                  // ============================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _infoRow("Số điện thoại", employee.phone),
                        const Divider(),
                        _infoRow("Email", employee.email ?? "Không có"),
                        const Divider(),
                        _infoRow("Vai trò", _convertRole(employee.role)),
                        const Divider(),
                        _infoRow("Trạng thái", _convertStatus(employee.status)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ============================
                  //      BUTTON EDIT
                  // ============================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editEmployee,
                          arguments: employee.id,
                        ).then((_) {
                          Provider.of<EmployeeProvider>(context, listen: false)
                              .loadEmployee(employee.id);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        "Chỉnh sửa thông tin",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFBEFD8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ============================
                  //      DELETE BUTTON
                  // ============================
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _confirmDelete(context, employee.id),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        "Xóa nhân viên",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ============================
  // Info row widget
  // ============================
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ],
    );
  }

  // ============================
  //   Confirm Delete Popup
  // ============================
  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc muốn xóa nhân viên này?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                final provider =
                    Provider.of<EmployeeProvider>(context, listen: false);

                final ok = await provider.deleteEmployee(id);

                // ignore: use_build_context_synchronously
                Navigator.pop(context);

                if (ok) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Đã xóa nhân viên thành công")),
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Không thể xóa nhân viên")),
                  );
                }
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ============================
  // Convert backend role → text
  // ============================
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

  // ============================
  // Convert backend status → text
  // ============================
  String _convertStatus(int s) {
    switch (s) {
      case 1:
        return "Đang hoạt động";
      case 2:
        return "Tạm dừng";
      case 3:
        return "Đã nghỉ việc";
      default:
        return "Không rõ";
    }
  }
}
