import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/cart_item_model.dart';
import 'package:smart_food_frontend/data/models/option_group_model.dart';
import 'package:smart_food_frontend/data/models/option_model.dart';
import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/providers/cart_provider.dart';
import 'package:smart_food_frontend/providers/product_option_provider.dart';

Future<void> showAddToCartBottomSheet(
  BuildContext context,
  ProductModel product, {
  int? presetQuantity,
  Map<int, List<OptionModel>>? presetSelections,
  int? cartItemId,
  bool isUpdate = false,
}) async {
  final optionProvider = context.read<ProductOptionProvider>();
  await optionProvider.load(product.id);

  // ignore: use_build_context_synchronously
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: optionProvider,
      child: _AddToCartSheet(
        product: product,
        presetQuantity: presetQuantity,
        presetSelections: presetSelections,
        cartItemId: cartItemId,
        isUpdate: isUpdate,
      ),
    ),
  );
}

class _AddToCartSheet extends StatefulWidget {
  final ProductModel product;
  final int? presetQuantity;
  final Map<int, List<OptionModel>>? presetSelections;
  final int? cartItemId;
  final bool isUpdate;
  const _AddToCartSheet({
    required this.product,
    this.presetQuantity,
    this.presetSelections,
    this.cartItemId,
    this.isUpdate = false,
  });

  @override
  State<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<_AddToCartSheet> {
  final Map<int, List<OptionModel>> _selectedByGroup = {};
  int _qty = 1;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.presetQuantity != null && widget.presetQuantity! > 0) {
      _qty = widget.presetQuantity!;
    }
    if (widget.presetSelections != null) {
      _selectedByGroup.addAll(widget.presetSelections!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final optionProvider = context.watch<ProductOptionProvider>();
    final groups = optionProvider.groups(widget.product.id);
    final loading = optionProvider.isLoading(widget.product.id);

    final optionTotal = _selectedByGroup.values
        .expand((e) => e)
        .fold<double>(0, (s, o) => s + o.price);
    final basePrice =
        widget.product.discountPrice != null && widget.product.discountPrice! > 0
            ? widget.product.discountPrice!
            : widget.product.price;
    final lineTotal = (basePrice + optionTotal) * _qty;

    final allRequiredSelected = groups.every((g) {
      if (!g.isRequired) return true;
      final selected = _selectedByGroup[g.id] ?? [];
      return selected.isNotEmpty;
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7EF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isUpdate ? "Cập nhật món" : "Thêm món mới",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF391713),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const SizedBox(height: 8),
              _headerCard(basePrice),
              const SizedBox(height: 12),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: controller,
                        itemCount: groups.length,
                        itemBuilder: (_, i) => _optionGroup(groups[i]),
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F7A52),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: allRequiredSelected && !_submitting
                      ? () async {
                          setState(() => _submitting = true);
                          final selections = _selectedByGroup.entries.expand(
                            (e) => e.value.map(
                              (o) => CartOptionSelection(
                                optionGroupId: e.key,
                                option: o,
                              ),
                            ),
                          );
                          bool ok = true;
                          if (widget.cartItemId != null) {
                            ok = await context.read<CartProvider>().removeItem(
                                  storeId: widget.product.storeId,
                                  itemId: widget.cartItemId!,
                                );
                          }
                          if (ok) {
                            ok = await context.read<CartProvider>().addItem(
                                  widget.product,
                                  _qty,
                                  selections.toList(),
                                );
                          }
                          if (mounted && ok) Navigator.of(context).pop();
                          if (mounted) setState(() => _submitting = false);
                        }
                      : null,
                  child: Text(
                    "Thêm vào giỏ hàng - ${lineTotal.toStringAsFixed(0)}đ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _headerCard(double basePrice) {
    final image = widget.product.imageUrl ?? widget.product.image ?? "";
    final priceText = "${basePrice.toStringAsFixed(0)}đ";
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image.isNotEmpty ? image : "https://via.placeholder.com/100",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(
                    color: Color(0xFF9A1B1D),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          _qtyStepper(),
        ],
      ),
    );
  }

  Widget _qtyStepper() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
            icon: const Icon(Icons.remove, color: Colors.red),
          ),
          Text(
            _qty.toString(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          IconButton(
            onPressed: () => setState(() => _qty++),
            icon: const Icon(Icons.add, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _optionGroup(OptionGroupModel group) {
    final selected = _selectedByGroup[group.id] ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 6),
          ...group.options.map((option) {
            final isChecked = selected.any((o) => o.id == option.id);
            final singleSelect = group.maxSelect == 1;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(option.name),
              subtitle: Text("${option.price.toStringAsFixed(0)}đ"),
              trailing: singleSelect
                  ? Radio<bool>(
                      value: true,
                      groupValue: isChecked ? true : null,
                      onChanged: (_) => _toggleSingle(group.id, option),
                      activeColor: const Color(0xFF1F7A52),
                    )
                  : Checkbox(
                      value: isChecked,
                      activeColor: const Color(0xFF1F7A52),
                      onChanged: (_) =>
                          _toggleMulti(group.id, option, group.maxSelect),
                    ),
              onTap: () => singleSelect
                  ? _toggleSingle(group.id, option)
                  : _toggleMulti(group.id, option, group.maxSelect),
            );
          }),
        ],
      ),
    );
  }

  void _toggleSingle(int groupId, OptionModel option) {
    setState(() {
      _selectedByGroup[groupId] = [option];
    });
  }

  void _toggleMulti(int groupId, OptionModel option, int maxSelect) {
    final list = List<OptionModel>.from(_selectedByGroup[groupId] ?? []);
    final exists = list.any((o) => o.id == option.id);
    if (exists) {
      list.removeWhere((o) => o.id == option.id);
    } else {
      if (maxSelect > 0 && list.length >= maxSelect) {
        list.removeAt(0);
      }
      list.add(option);
    }
    setState(() {
      _selectedByGroup[groupId] = list;
    });
  }
}
