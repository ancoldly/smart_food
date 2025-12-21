import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/option_group_template_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/option_group_template_provider.dart';

class TemplateGroupScreen extends StatefulWidget {
  const TemplateGroupScreen({super.key});

  @override
  State<TemplateGroupScreen> createState() => _TemplateGroupScreenState();
}

class _TemplateGroupScreenState extends State<TemplateGroupScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OptionGroupTemplateProvider>(context, listen: false)
          .loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OptionGroupTemplateProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = provider.groups;
        if (list.isEmpty) {
          return const Center(child: Text("Chưa có nhóm chung"));
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
    );
  }

  Widget _groupItem(OptionGroupTemplateModel g) {
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
                AppRoutes.templateOptionList,
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
                  AppRoutes.editTemplateGroup,
                  arguments: g,
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
                  final ok = await Provider.of<OptionGroupTemplateProvider>(
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
