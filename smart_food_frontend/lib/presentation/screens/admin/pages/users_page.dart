import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';
import 'package:smart_food_frontend/data/models/user_model.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false).loadAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);

    // 🔥 CHỈ GIỮ 3 ROLE (LOẠI ADMIN)
    final users = provider.allUsers
        .where((u) =>
            u.role == "customer" ||
            u.role == "merchant" ||
            u.role == "shipper")
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Users Management",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: provider.loadingAllUsers
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B7B56)),
            )

          : users.isEmpty
              ? const Center(
                  child: Text("Không có người dùng nào."),
                )

              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,            // ✔ dùng users
                  itemBuilder: (_, i) {
                    return _buildUserCard(users[i]); // ✔ dùng users[i]
                  },
                ),
    );
  }

  // --------------------------------------------
  // USER CARD
  // --------------------------------------------
  Widget _buildUserCard(UserModel user) {
    final roleText = user.role.toLowerCase();
    final roleColor = _roleColor(roleText);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),

        leading: CircleAvatar(
          radius: 26,
          backgroundColor: roleColor.withOpacity(0.2),
          backgroundImage:
              user.avatar != null ? NetworkImage(user.avatar!) : null,
          child: user.avatar == null
              ? Text(
                  (user.fullName?.isNotEmpty ?? false)
                      ? user.fullName![0].toUpperCase()
                      : "?",
                  style: TextStyle(
                    fontSize: 20,
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        title: Text(
          user.fullName ?? "No Name",
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                roleText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case "customer":
        return Colors.blue;
      case "merchant":
        return Colors.green;
      case "shipper":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
