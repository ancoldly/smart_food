import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/category_provider.dart';
import 'package:smart_food_frontend/data/models/category_model.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/template_group_screen.dart';

class MenuCategoryScreen extends StatefulWidget {
  const MenuCategoryScreen({super.key});

  @override
  State<MenuCategoryScreen> createState() => _MenuCategoryScreenState();
}

class _MenuCategoryScreenState extends State<MenuCategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (_currentTab != _tab.index) {
        setState(() => _currentTab = _tab.index);
      }
    });
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),

      // ======================
      //     APP BAR CUSTOM
      // ======================
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Thực đơn",
          style: TextStyle(
            color: Color(0xFF391713),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),

      // ======================
      //      FLOAT BUTTON
      // ======================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F7A52),
        onPressed: () {
          if (_currentTab == 0) {
            Navigator.pushNamed(context, AppRoutes.addCategory);
          } else {
            Navigator.pushNamed(context, AppRoutes.addTemplateGroup);
          }
        },
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),

      // ======================
      //      BODY
      // ======================
      body: Column(
        children: [
          // ---------- TAB BAR ----------
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF1F7A52), width: 1.4),
              ),
            ),
            child: TabBar(
              controller: _tab,
              indicatorColor: const Color(0xFF1F7A52),
              indicatorWeight: 2.5,
              labelColor: const Color(0xFF1F7A52),
              unselectedLabelColor: Colors.black54,
              labelStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: "Danh mục"),
                Tab(text: "Tùy chọn nhóm"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ---------- SEARCH BOX ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ---------- TAB CONTENT ----------
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // TAB 1: show category list
                _buildCategoryList(),

                // TAB 2: template option groups
                const TemplateGroupScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================================
  //                            UI DANH SACH DANH MUC
  // ===================================================================================
  Widget _buildCategoryList() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.categories.isEmpty) {
          return const Center(child: Text("Chưa có danh mục"));
        }

        return RefreshIndicator(
          onRefresh: provider.loadCategories,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final item = provider.categories[index];
              return _categoryItem(
                category: item,
                imageUrl: item.imageUrl ?? item.image,
                title: item.name,
                subtitle: item.description ?? "",
                isActive: item.isActive,
              );
            },
          ),
        );
      },
    );
  }

  // ===================================================================================
  //                            CARD CATEGORY ITEM
  // ===================================================================================
  Widget _categoryItem({
    required CategoryModel category,
    String? imageUrl,
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDDC7A3),
          width: 1.2,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          // ICON
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "./assets/images/tea.png",
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(width: 12),

          // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.productManage,
                      arguments: {
                        "categoryId": category.id,
                        "categoryName": category.name,
                      },
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF391713),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // STATUS DOT (center vertically)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ACTION MENU
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF391713)),
            onSelected: (value) async {
              if (value == "edit") {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editCategory,
                  arguments: category,
                );
              } else if (value == "delete") {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Xóa danh mục"),
                    content:
                        const Text("Bạn có chắc muốn xóa danh mục này không?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Hủy"),
                      ),
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
                  final ok = await Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  ).deleteCategory(category.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok ? "Đã xóa danh mục" : "Xóa thất bại",
                      ),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "edit",
                child: Text("Sửa"),
              ),
              const PopupMenuItem(
                value: "delete",
                child: Text("Xóa"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
