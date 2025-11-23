import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users Management"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserCard("1", "Nguyen Van A", "a@gmail.com", "customer"),
          _buildUserCard("2", "Tran Thi B", "b@gmail.com", "merchant"),
          _buildUserCard("3", "Le Van C", "c@gmail.com", "shipper"),
          _buildUserCard("4", "Pham Minh D", "d@gmail.com", "customer"),
        ],
      ),
    );
  }

  Widget _buildUserCard(String id, String name, String email, String role) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),

        leading: CircleAvatar(
          radius: 26,
          backgroundColor: _roleColor(role).withOpacity(0.2),
          child: Text(
            name[0],
            style: TextStyle(
              fontSize: 20,
              color: _roleColor(role),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                color: _roleColor(role).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _roleColor(role),
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
