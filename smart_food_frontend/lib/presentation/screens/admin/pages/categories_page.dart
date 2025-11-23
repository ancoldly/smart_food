import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController nameCtrl = TextEditingController();

  final List<Map<String, String>> categories = [
    {"id": "1", "name": "Cơm"},
    {"id": "2", "name": "Trà Sữa"},
    {"id": "3", "name": "Đồ ăn vặt"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories Manager"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateSheet(context),
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final c = categories[index];
          return _categoryCard(context, c["id"]!, c["name"]!);
        },
      ),
    );
  }

  //────────────────────────────────────────────
  //                 CATEGORY CARD
  //────────────────────────────────────────────
  Widget _categoryCard(BuildContext context, String id, String name) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.teal.withOpacity(0.15),
          child: const Icon(Icons.category, color: Colors.teal, size: 26),
        ),

        title: Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),

        subtitle: Text("ID: $id"),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _openUpdateSheet(context, id, name),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showSnackbar(context, "Deleted $name"),
            ),
          ],
        ),
      ),
    );
  }

  //────────────────────────────────────────────
  //         BOTTOMSHEET CREATE CATEGORY
  //────────────────────────────────────────────
  void _openCreateSheet(BuildContext context) {
    nameCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return _categorySheet(
          title: "Add Category",
          buttonText: "Create",
          onSubmit: () {
            Navigator.pop(context);
            _showSnackbar(context, "Category created!");
          },
        );
      },
    );
  }

  //────────────────────────────────────────────
  //         BOTTOMSHEET UPDATE CATEGORY
  //────────────────────────────────────────────
  void _openUpdateSheet(BuildContext context, String id, String oldName) {
    nameCtrl.text = oldName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return _categorySheet(
          title: "Update Category",
          buttonText: "Update",
          onSubmit: () {
            Navigator.pop(context);
            _showSnackbar(context, "Category updated!");
          },
        );
      },
    );
  }

  //────────────────────────────────────────────
  //       REUSABLE SHEET UI (CREATE/UPDATE)
  //────────────────────────────────────────────
  Widget _categorySheet({
    required String title,
    required String buttonText,
    required VoidCallback onSubmit,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: "Category Name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
