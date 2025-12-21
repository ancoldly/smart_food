import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/option_group_model.dart';
import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/option_group_provider.dart';

class OptionGroupScreen extends StatefulWidget {
  final ProductModel product;
  const OptionGroupScreen({super.key, required this.product});

  @override
  State<OptionGroupScreen> createState() => _OptionGroupScreenState();
}

class _OptionGroupScreenState extends State<OptionGroupScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OptionGroupProvider>(context, listen: false).loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = "Tùy chọn - ${widget.product.name}";
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF391713)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF391713),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F7A52),
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addOptionGroup,
            arguments: widget.product,
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<OptionGroupProvider>(
        builder: (context, provider, _) {
          final list = provider.groups
              .where((g) => g.productId == widget.product.id)
              .toList();

          if (provider.loading && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (list.isEmpty) {
            return const Center(child: Text("Chưa có nhóm tùy chọn"));
          }

          return RefreshIndicator(
            onRefresh: provider.loadGroups,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final g = list[index];
                return _groupItem(g);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _groupItem(OptionGroupModel g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDC7A3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  g.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Bắt buộc: ${g.isRequired ? "Có" : "Không"} - Max: ${g.maxSelect == 0 ? "Không giới hạn" : g.maxSelect}",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.list, color: Color(0xFF391713)),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.optionList,
                arguments: g,
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF391713)),
            onSelected: (val) async {
              if (val == "edit") {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editOptionGroup,
                  arguments: {"product": widget.product, "group": g},
                );
              } else if (val == "delete") {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Xóa nhóm"),
                    content: const Text("Bạn chắc muốn xóa?"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Hủy")),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Xóa",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  // ignore: use_build_context_synchronously
                  final ok = await Provider.of<OptionGroupProvider>(
                    context,
                    listen: false,
                  ).deleteGroup(g.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? "Đã xóa" : "Xóa thất bại")),
                  );
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "edit", child: Text("Sửa")),
              PopupMenuItem(value: "delete", child: Text("Xóa")),
            ],
          ),
        ],
      ),
    );
  }
}
