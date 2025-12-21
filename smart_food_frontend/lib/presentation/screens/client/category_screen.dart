import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/presentation/widgets/item_category.dart';

class Category {
  final String title;
  final String image;
  final String key; 

  const Category(this.title, this.image, this.key);
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  final List<Category> _categories = const [
    Category('Trà sữa', './assets/categories/Milk_Tea.png', 'Trà sữa'),
    Category('Cơm', './assets/categories/Rice_Dishes.png', 'Cơm'),
    Category('Ăn vặt', './assets/categories/Snacks.png', 'Ăn vặt'),
    Category('Gà', './assets/categories/Chicken_Dishes.png', 'Gà'),
    Category('Cà phê', './assets/categories/Coffee.png', 'Cà phê'),
    Category('Tráng miệng', './assets/categories/Desserts.png', 'Tráng miệng'),
    Category('Bún/Phở', './assets/categories/Rice_Noodles.png', 'Bún, Phở'),
    Category('Trà', './assets/categories/Tea.png', 'Trà'),
    Category('Bánh Âu', './assets/categories/Pastries.png', 'Bánh Âu'),
    Category('Bún/Mì/Phở', './assets/categories/Noodles&Pho.png', 'Bún, Mì, Phở'),
    Category('Nước ép', './assets/categories/Juices.png', 'Nước ép'),
    Category('Bánh tráng', './assets/categories/Rice_Paper_Rolls.png', 'Bánh tráng'),
    Category('Cháo/Soup', './assets/categories/Porridge&Soup.png', 'Cháo, Soup'),
    Category('Đồ ăn nhanh', './assets/categories/Fast_Food.png', 'Đồ ăn nhanh'),
    Category('Hải sản', './assets/categories/Seafood.png', 'Hải sản'),
    Category('Bánh mì', './assets/categories/BanhMi.png', 'Bánh mì'),
    Category('Heo', './assets/categories/Pork_Dishes.png', 'Heo'),
    Category('Lẩu', './assets/categories/Hotpot.png', 'Lẩu'),
    Category('Mì cay', './assets/categories/Spicy_Noodles.png', 'Mì cay'),
    Category('Gà rán', './assets/categories/Fried_Chicken.png', 'Gà rán'),
    Category('Bò', './assets/categories/Beef_Dishes.png', 'Bò'),
    Category('Bánh cuốn', './assets/categories/Steamed_Rice_Rolls.png', 'Bánh cuốn'),
    Category('Cá', './assets/categories/Fish_Dishes.png', 'Cá'),
  ];

  static const backgroundColor = Color(0xFFFFF6EC);
  static const primaryGreen = Color(0xFF5B7B56);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Danh mục",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = _categories[index];
            return CategoryItem(
              title: item.title,
              image: item.image,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.storeByCategory,
                arguments: {"name": item.key},
              ),
            );
          },
        ),
      ),
    );
  }
}
