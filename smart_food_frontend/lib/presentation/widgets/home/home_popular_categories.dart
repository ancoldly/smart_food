import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class HomePopularCategories extends StatelessWidget {
  final List<Map<String, String>> items;

  const HomePopularCategories({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                "Phổ biến",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF391713),
                ),
              ),
              Icon(Icons.local_fire_department,
                  size: 18, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final title = item["title"] ?? "";
              final image = item["image"] ?? "";
              final key = item["key"] ?? title;
              final isDanhMuc = key.toLowerCase() == "danh mục";

              final card = Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE6E0D6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        image,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C2F2F),
                      ),
                    ),
                  ],
                ),
              );

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (isDanhMuc) {
                    Navigator.pushNamed(context, AppRoutes.category);
                  } else {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.storeByCategory,
                      arguments: {"name": key},
                    );
                  }
                },
                child: card,
              );
            },
          ),
        ],
      ),
    );
  }
}
