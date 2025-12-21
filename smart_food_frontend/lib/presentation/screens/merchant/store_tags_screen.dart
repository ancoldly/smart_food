import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/store_tag_provider.dart';

class StoreTagsScreen extends StatefulWidget {
  const StoreTagsScreen({super.key});

  @override
  State<StoreTagsScreen> createState() => _StoreTagsScreenState();
}

class _StoreTagsScreenState extends State<StoreTagsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<StoreTagProvider>(context, listen: false).loadTags();
    });
  }

  void _openDialog({int? id, String? name, String? slug}) {
    final nameCtrl = TextEditingController(text: name ?? "");
    final slugCtrl = TextEditingController(text: slug ?? "");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? "Thêm tag" : "Sửa tag"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Tên"),
            ),
            TextField(
              controller: slugCtrl,
              decoration: const InputDecoration(labelText: "Slug (tùy chọn)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final p = Provider.of<StoreTagProvider>(context, listen: false);
              if (id == null) {
                await p.addTag(nameCtrl.text.trim(), slug: slugCtrl.text.trim());
              } else {
                await p.updateTag(id, nameCtrl.text.trim(), slug: slugCtrl.text.trim());
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Phân loại kinh doanh",
          style: TextStyle(
            color: Color(0xFF391713),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF391713)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF255B36),
        onPressed: () => _openDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<StoreTagProvider>(
        builder: (_, provider, __) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.tags.isEmpty) {
            return const Center(child: Text("Chưa có tag nào"));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.tags.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final t = provider.tags[i];
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                title: Text(t.name),
                subtitle: Text(t.slug),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _openDialog(id: t.id, name: t.name, slug: t.slug),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final ok = await provider.deleteTag(t.id);
                        if (!ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Xóa thất bại")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
