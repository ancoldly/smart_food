import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/data/models/product_option_group_model.dart';
import 'package:smart_food_frontend/providers/option_group_template_provider.dart';
import 'package:smart_food_frontend/providers/product_option_group_provider.dart';

class ProductTemplateLinkScreen extends StatefulWidget {
  final ProductModel product;
  const ProductTemplateLinkScreen({super.key, required this.product});

  @override
  State<ProductTemplateLinkScreen> createState() => _ProductTemplateLinkScreenState();
}

class _ProductTemplateLinkScreenState extends State<ProductTemplateLinkScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Provider.of<OptionGroupTemplateProvider>(context, listen: false)
          .loadGroups();
      // ignore: use_build_context_synchronously
      await Provider.of<ProductOptionGroupProvider>(context, listen: false)
          .loadLinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = "Gắn nhóm chung - ${widget.product.name}";

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
        onPressed: _openAddLinkSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<ProductOptionGroupProvider>(
        builder: (context, provider, _) {
          final links = provider.links
              .where((l) => l.productId == widget.product.id)
              .toList();

          if (provider.loading && links.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (links.isEmpty) {
            return const Center(child: Text("Chưa gắn nhóm chung"));
          }

          return RefreshIndicator(
            onRefresh: provider.loadLinks,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: links.length,
              itemBuilder: (context, index) {
                final link = links[index];
                return _linkItem(link);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _linkItem(ProductOptionGroupModel link) {
    final tpl = link.template;
    final requiredText = (link.isRequired ?? tpl.isRequired) ? "Bắt buộc" : "Không bắt buộc";
    final maxSelect = link.maxSelect ?? tpl.maxSelect;

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
                  tpl.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$requiredText - Max: ${maxSelect == 0 ? "Không giới hạn" : maxSelect} - Pos: ${link.position}",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF391713)),
            onSelected: (val) async {
              if (val == "delete") {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Bỏ gắn nhóm"),
                    content: const Text("Bạn chắc muốn bỏ gắn nhóm này?"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Hủy")),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Bỏ",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  // ignore: use_build_context_synchronously
                  final ok = await Provider.of<ProductOptionGroupProvider>(
                    context,
                    listen: false,
                  ).deleteLink(link.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? "Đã bỏ" : "Thất bại")),
                  );
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "delete", child: Text("Bỏ gắn")),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openAddLinkSheet() async {
    final templateProvider =
        Provider.of<OptionGroupTemplateProvider>(context, listen: false);
    final linkProvider =
        Provider.of<ProductOptionGroupProvider>(context, listen: false);
    final existing = linkProvider.links
        .where((l) => l.productId == widget.product.id)
        .map((l) => l.template.id)
        .toSet();
    final available = templateProvider.groups
        .where((g) => !existing.contains(g.id))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không còn nhóm để gắn")),
      );
      return;
    }

    int? selectedId = available.first.id;
    bool isRequired = available.first.isRequired;
    int maxSelect = available.first.maxSelect;
    int position = available.first.position;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Gắn nhóm chung",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedId,
                    decoration: const InputDecoration(
                      labelText: "Chọn nhóm",
                      border: OutlineInputBorder(),
                    ),
                    items: available
                        .map((g) => DropdownMenuItem(
                              value: g.id,
                              child: Text(g.name),
                            ))
                        .toList(),
                    onChanged: (v) {
                      final g = available.firstWhere((e) => e.id == v);
                      setSheet(() {
                        selectedId = v;
                        isRequired = g.isRequired;
                        maxSelect = g.maxSelect;
                        position = g.position;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text("Bắt buộc"),
                    value: isRequired,
                    onChanged: (v) => setSheet(() => isRequired = v),
                  ),
                    TextFormField(
                      initialValue: maxSelect.toString(),
                      decoration: const InputDecoration(
                        labelText: "Max chọn (0 = không giới hạn)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          setSheet(() => maxSelect = int.tryParse(v) ?? 0),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: position.toString(),
                      decoration: const InputDecoration(
                        labelText: "Thứ tự",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          setSheet(() => position = int.tryParse(v) ?? 0),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedId == null) return;
                      final ok = await linkProvider.addLink({
                        "product": widget.product.id,
                        "option_group_template_id": selectedId,
                        "is_required": isRequired,
                        "max_select": maxSelect,
                        "position": position,
                      });
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(ok ? "Đã gắn" : "Gắn thất bại")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F7A52),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Gắn"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
