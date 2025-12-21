import 'package:flutter/material.dart';

class HomeBanner extends StatelessWidget {
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final List<HomeBannerItem>? items;

  const HomeBanner({
    super.key,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    final data = (items != null && items!.isNotEmpty)
        ? items!
        : const [
            HomeBannerItem("assets/banners/banner1.jpg"),
            HomeBannerItem("assets/banners/banner2.jpg"),
            HomeBannerItem("assets/banners/banner3.jpg"),
            HomeBannerItem("assets/banners/banner4.jpg"),
          ];

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: item.isNetwork
                      ? InkWell(
                          onTap: item.onTap,
                          child: Image.network(
                            item.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(child: Icon(Icons.image)),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: item.onTap,
                          child: Image.asset(
                            item.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            data.length,
            (i) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == i
                    ? const Color(0xFFFF7043)
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeBannerItem {
  final String image;
  final VoidCallback? onTap;
  final bool isNetwork;
  final int? campaignId;

  const HomeBannerItem(
    this.image, {
    this.onTap,
    this.isNetwork = false,
    this.campaignId,
  });
}
