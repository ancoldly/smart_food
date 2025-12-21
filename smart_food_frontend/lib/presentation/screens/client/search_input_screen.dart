import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class SearchInputScreen extends StatefulWidget {
  const SearchInputScreen({super.key});

  @override
  State<SearchInputScreen> createState() => _SearchInputScreenState();
}

class _SearchInputScreenState extends State<SearchInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _history = [
    "Trà sữa",
    "Bánh cuốn",
    "Bún đậu mắm tôm",
    "Gà rán",
    "Jollibee",
    "Bánh cuốn tây sơn",
  ];

  final List<Map<String, String>> _suggestions = const [
    {"title": "Trà sữa", "image": "assets/categories/Milk_Tea.png"},
    {"title": "Gà rán", "image": "assets/categories/Fried_Chicken.png"},
    {"title": "Cơm", "image": "assets/categories/Rice_Dishes.png"},
    {"title": "Đồ ăn nhanh", "image": "assets/categories/Fast_Food.png"},
    {"title": "Cà phê", "image": "assets/categories/Coffee.png"},
    {"title": "Ăn vặt", "image": "assets/categories/Snacks.png"},
  ];

  void _submit(String value) {
    final kw = value.trim();
    if (kw.isEmpty) return;
    Navigator.pushNamed(
      context,
      AppRoutes.searchStore,
      arguments: {"keyword": kw},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        centerTitle: true,
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(child: _buildSearchBar()),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHistory(),
              const SizedBox(height: 16),
              _buildSuggestions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1E7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Hôm nay bạn muốn ăn, uống gì nào?",
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
            ),
          ),
          IconButton(
            onPressed: () => _submit(_controller.text),
            icon: const Icon(Icons.search, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lịch sử tìm kiếm",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _history.clear());
                },
                child: const Text("Xóa", style: TextStyle(color: Colors.red)),
              )
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _history
                .map(
                  (h) => ActionChip(
                    label: Text(h),
                    onPressed: () => _submit(h),
                    backgroundColor: const Color(0xFFF3F3F3),
                    labelStyle: const TextStyle(color: Colors.black87),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gợi ý tìm kiếm",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _suggestions.length, 
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final item = _suggestions[index];
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _submit(item["title"] ?? ""),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item["image"] ?? "",
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item["title"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
