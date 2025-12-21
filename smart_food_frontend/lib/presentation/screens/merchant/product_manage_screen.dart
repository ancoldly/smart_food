import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/providers/product_provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class ProductManageScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const ProductManageScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<ProductManageScreen> createState() => _ProductManageScreenState();
}

class _ProductManageScreenState extends State<ProductManageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.categoryName != null
        ? "Sản phẩm - ${widget.categoryName}"
        : "Quản lí sản phẩm";

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
            AppRoutes.addProduct,
            arguments: widget.categoryId,
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ProductModel> list = provider.products;
          if (widget.categoryId != null) {
            list = list.where((p) => p.categoryId == widget.categoryId).toList();
          }

          if (list.isEmpty) {
            return const Center(child: Text("Chưa có sản phẩm"));
          }

          return RefreshIndicator(
            onRefresh: provider.loadProducts,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final p = list[index];
                return _productItem(p);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _productItem(ProductModel p) {
    final priceText = p.discountPrice != null
        ? "${p.discountPrice} (gốc ${p.price})"
        : p.price.toString();

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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (p.imageUrl ?? p.image) != null && (p.imageUrl ?? p.image)!.isNotEmpty
                ? Image.network(
                    p.imageUrl ?? p.image!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFFEFE2CE),
                    child: const Icon(Icons.image, color: Color(0xFF391713)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.description ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Giá: $priceText",
                  style: const TextStyle(color: Color(0xFF255B36), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: p.isAvailable ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF391713)),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.optionGroups,
                    arguments: p,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.link, color: Color(0xFF391713)),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.productTemplateLink,
                    arguments: p,
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (val) async {
                  if (val == "edit") {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editProduct,
                      arguments: p,
                    );
                  } else if (val == "delete") {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Xóa sản phẩm"),
                        content: const Text("Bạn chắc muốn xóa?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Huy")),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      // ignore: use_build_context_synchronously
                      final ok = await Provider.of<ProductProvider>(context, listen: false)
                          .deleteProduct(p.id);
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
                icon: const Icon(Icons.more_vert, color: Color(0xFF391713)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
