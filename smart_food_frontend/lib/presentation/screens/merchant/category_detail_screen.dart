import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/category_provider.dart';

class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Chức năng product theo category sẽ làm sau, tạm bỏ qua detail
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Chi tiết danh mục",
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
        actions: [
          Consumer<CategoryProvider>(
            builder: (context, provider, _) {
              final c = provider.selectedCategory;
              if (c == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF391713)),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.editCategory,
                    arguments: c,
                  );
                },
              );
            },
          )
        ],
      ),

      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Hiện chưa có danh sách sản phẩm theo danh mục. Chức năng sẽ bổ sung sau.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF391713),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
