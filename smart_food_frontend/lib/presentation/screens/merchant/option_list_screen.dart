import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/option_group_model.dart';
import 'package:smart_food_frontend/data/models/option_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/option_provider.dart';

class OptionListScreen extends StatefulWidget {
  final OptionGroupModel group;
  const OptionListScreen({super.key, required this.group});

  @override
  State<OptionListScreen> createState() => _OptionListScreenState();
}

class _OptionListScreenState extends State<OptionListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OptionProvider>(context, listen: false).loadOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = "Lựa chọn - ${widget.group.name}";
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
            AppRoutes.addOption,
            arguments: widget.group,
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<OptionProvider>(
        builder: (context, provider, _) {
          final list = provider.options
              .where((o) => o.optionGroupId == widget.group.id)
              .toList();

          if (provider.loading && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (list.isEmpty) {
            return const Center(child: Text("Chưa có lựa chọn"));
          }

          return RefreshIndicator(
            onRefresh: provider.loadOptions,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final o = list[index];
                return _optionItem(o);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _optionItem(OptionModel o) {
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
                  o.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Gia: ${o.price}",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF391713)),
            onSelected: (val) async {
              if (val == "edit") {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editOption,
                  arguments: {"group": widget.group, "option": o},
                );
              } else if (val == "delete") {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Xóa lựa chọn"),
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
                  final ok = await Provider.of<OptionProvider>(
                    context,
                    listen: false,
                  ).deleteOption(o.id);
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
