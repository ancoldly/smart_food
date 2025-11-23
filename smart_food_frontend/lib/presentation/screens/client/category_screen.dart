import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/widgets/item_category.dart';

class Category {
  final String title;
  final String image;

  const Category(this.title, this.image);
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  final List<Category> _categories = const [
    Category('Trà sữa', './assets/categories/Milk_Tea.png'),
    Category('Cơm', './assets/categories/Rice_Dishes.png'),
    Category('Đồ ăn vặt', './assets/categories/Snacks.png'),
    Category('Gà', './assets/categories/Chicken_Dishes.png'),
    Category('Cà phê', './assets/categories/Coffee.png'),
    Category('Tráng miệng', './assets/categories/Desserts.png'),
    Category('Bún', './assets/categories/Rice_Noodles.png'),
    Category('Trà', './assets/categories/Tea.png'),
    Category('Bánh Âu Á', './assets/categories/Pastries.png'),
    Category('Bún/Mì/Phở', './assets/categories/Noodles&Pho.png'),
    Category('Nước ép', './assets/categories/Juices.png'),
    Category('Bánh tráng', './assets/categories/Rice_Paper_Rolls.png'),
    Category('Cháo/Soup', './assets/categories/Porridge&Soup.png'),
    Category('Đồ ăn nhanh', './assets/categories/Fast_Food.png'),
    Category('Hải sản', './assets/categories/Seafood.png'),
    Category('Bánh mì', './assets/categories/BanhMi.png'),
    Category('Heo', './assets/categories/Pork_Dishes.png'),
    Category('Lẩu', './assets/categories/Hotpot.png'),
    Category('Mì cay', './assets/categories/Spicy_Noodles.png'),
    Category('Gà rán', './assets/categories/Fried_Chicken.png'),
    Category('Bò', './assets/categories/Beef_Dishes.png'),
    Category('Bánh cuốn', './assets/categories/Steamed_Rice_Rolls.png'),
    Category('Cá', './assets/categories/Fish_Dishes.png'),
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
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
