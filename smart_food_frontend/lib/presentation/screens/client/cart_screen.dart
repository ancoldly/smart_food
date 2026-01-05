import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/cart_item_model.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/presentation/widgets/cart/edit_cart_item_bottom_sheet.dart';
import 'package:smart_food_frontend/providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  final StoreModel store;
  const CartScreen({super.key, required this.store});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CartProvider>().loadCart(widget.store.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartP = context.watch<CartProvider>();
    final items = cartP.itemsFor(widget.store.id);
    final total = cartP.totalFor(widget.store.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Giỏ hàng của bạn",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFF7EF),
      body: items.isEmpty
          ? const Center(child: Text("Chưa có món trong giỏ"))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.store.storeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF1F7A52),
                        ),
                      ),
                      Text(
                        "${items.length} món",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (_, i) => _cartItemTile(context, items[i]),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: items.length,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tổng cộng",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            _price(total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Color(0xFF1F7A52),
                            ),
                          )
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F7A52),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.checkout,
                            arguments: widget.store,
                          );
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          "Đặt hàng",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _cartItemTile(BuildContext context, CartItemModel item) {
    final cartP = context.read<CartProvider>();
    final image = item.product.imageUrl ?? item.product.image ?? "";
    final optionText = _optionSummary(item);
    final displayPrice = item.product.discountPrice != null &&
            item.product.discountPrice! > 0
        ? item.product.discountPrice!
        : item.product.price;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  image.isNotEmpty
                      ? image
                      : "https://via.placeholder.com/80x80.png?text=Item",
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF2F1C14),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (optionText.isNotEmpty)
                                Text(
                                  optionText,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12.5,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () =>
                                    showEditCartItemBottomSheet(context, item),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                ),
                                child: const Text(
                                  "Chỉnh sửa",
                                  style: TextStyle(
                                    color: Color(0xFF1F7A52),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _price(displayPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F7A52),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _quantityStepper(context, item, cartP),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityStepper(
      BuildContext context, CartItemModel item, CartProvider cartP) {
    Future<void> _decrease() async {
      final newQty = item.quantity - 1;
      if (newQty <= 0) {
        final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Xóa món khỏi giỏ?"),
                content: const Text(
                    "Bạn có chắc muốn xóa món này khỏi giỏ hàng?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Huỷ"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Xóa"),
                  ),
                ],
              ),
            ) ??
            false;
        if (confirm && item.cartItemId != null) {
          await cartP.removeItem(
            storeId: widget.store.id,
            itemId: item.cartItemId!,
          );
          if (cartP.itemCountFor(widget.store.id) == 0 && mounted) {
            Navigator.of(context).pop();
          }
        }
      } else if (item.cartItemId != null) {
        await cartP.updateItemQuantity(
          storeId: widget.store.id,
          itemId: item.cartItemId!,
          quantity: newQty,
        );
      }
    }

    Future<void> _increase() async {
      if (item.cartItemId != null) {
        await cartP.updateItemQuantity(
          storeId: widget.store.id,
          itemId: item.cartItemId!,
          quantity: item.quantity + 1,
        );
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1F7A52)),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepIcon(
            icon: Icons.remove,
            onTap: _decrease,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          _stepIcon(
            icon: Icons.add,
            onTap: _increase,
          ),
        ],
      ),
    );
  }

  Widget _stepIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 16,
          color: const Color(0xFF1F7A52),
        ),
      ),
    );
  }

  String _optionSummary(CartItemModel item) {
    if (item.selections.isEmpty) return "";
    final names = item.selections.map((s) => s.option.name).toList();
    return names.join(", ");
  }

  String _price(num value) => "${value.toStringAsFixed(0)}đ";
}
