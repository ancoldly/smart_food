import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/address_model.dart';
import 'package:smart_food_frontend/data/models/cart_item_model.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/models/voucher_model.dart';
import 'package:smart_food_frontend/data/models/store_voucher_model.dart';
import 'package:smart_food_frontend/providers/cart_provider.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';
import 'package:smart_food_frontend/providers/voucher_provider.dart';
import 'package:smart_food_frontend/providers/order_provider.dart';
import 'package:smart_food_frontend/providers/payment_provider.dart';
import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/core/utils/location_utils.dart';

class CheckoutScreen extends StatefulWidget {
  final StoreModel store;
  const CheckoutScreen({super.key, required this.store});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentMethod = "cash"; // cash, card
  VoucherModel? selectedAppVoucher;
  StoreVoucherModel? selectedStoreVoucher;
  AddressModel? _defaultAddress;
  PaymentModel? _defaultPayment;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final paymentP = Provider.of<PaymentProvider>(context, listen: false);
      final voucherP = Provider.of<VoucherProvider>(context, listen: false);
      final addressP = Provider.of<AddressProvider>(context, listen: false);
      await Provider.of<CartProvider>(context, listen: false)
          .loadCart(widget.store.id);
      await paymentP.loadPayments();
      await voucherP.loadPublic();
      await addressP.loadAddresses();
      _pickDefaultAddress(addressP.addresses);
      _pickDefaultPayment(paymentP.payments);
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F1E6);
    final cartP = Provider.of<CartProvider>(context);
    final items = cartP.itemsFor(widget.store.id);
    final subtotal = cartP.totalFor(widget.store.id);
    final shipping = _calcShippingFee(widget.store, _defaultAddress);

    final discountApp = _calcAppVoucherDiscount(subtotal);
    final discountStore = _calcStoreVoucherDiscount(subtotal);
    final total = (subtotal + shipping - discountApp - discountStore)
        .clamp(0, double.infinity)
        .toDouble();

    final user = Provider.of<UserProvider>(context).user;
    final addresses = Provider.of<AddressProvider>(context).addresses;
    _pickDefaultAddress(addresses);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Xác nhận đơn hàng",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _addressCard(user),
            const SizedBox(height: 12),
            _storeCart(items),
            const SizedBox(height: 12),
            _paymentSection(),
            const SizedBox(height: 12),
            _voucherSection(subtotal, discountApp + discountStore),
            const SizedBox(height: 12),
            _summarySection(subtotal, shipping, discountApp + discountStore, total),
            const SizedBox(height: 24),
            _placeOrderButton(total, shipping),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  double _calcShippingFee(StoreModel store, AddressModel? address) {
    final slat = store.latitude;
    final slng = store.longitude;
    final dlat = address?.latitude;
    final dlng = address?.longitude;
    if (slat != null && slng != null && dlat != null && dlng != null) {
      final dist = distanceKm(slat, slng, dlat, dlng);
      const base = 15000.0;
      final perKm = 5000.0 * dist;
      final extraShort = dist < 2 ? 3000.0 : 0.0;
      return base + perKm + extraShort;
    }
    return 27000.0;
  }

  Widget _addressCard(user) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _defaultAddress?.receiverName ?? (user?.fullName ?? "Người nhận"),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _defaultAddress?.receiverPhone ?? (user?.phone ?? ""),
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  _defaultAddress?.addressLine ??
                      "Chưa có địa chỉ mặc định",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.address),
            child: const Text("Chỉnh sửa"),
          ),
        ],
      ),
    );
  }

  Widget _storeCart(List<CartItemModel> items) {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.store.storeName,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((i) => _cartItemRow(i)).toList(),
          if (widget.store.storeVouchers.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            const Text(
              "Mã giảm giá cửa hàng",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            ...widget.store.storeVouchers.map(
              (v) => Row(
                children: [
                  const Icon(Icons.local_offer, size: 18, color: Color(0xFF1F7A52)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      v.description.isNotEmpty ? v.description : v.code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cartItemRow(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.image ?? "",
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: 64, height: 64, color: Colors.grey.shade200),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _price(item.unitPrice),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "x${item.quantity}",
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _paymentSection() {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Thông tin thanh toán",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("Xem tất cả"),
              ),
            ],
          ),
          RadioListTile<String>(
            value: "card",
            groupValue: paymentMethod,
            onChanged: (v) => setState(() => paymentMethod = v ?? "cash"),
            title: const Text("Thẻ"),
            subtitle: const Text("Thanh toán qua thẻ/banking"),
            secondary: const Icon(Icons.credit_card, color: Color(0xFF1F7A52)),
          ),
          RadioListTile<String>(
            value: "cash",
            groupValue: paymentMethod,
            onChanged: (v) => setState(() => paymentMethod = v ?? "cash"),
            title: const Text("Tiền mặt"),
            subtitle: const Text("Thanh toán khi nhận hàng"),
            secondary: const Icon(Icons.payments_outlined, color: Color(0xFF1F7A52)),
          ),
          if (paymentMethod == "card") ...[
            const SizedBox(height: 8),
            _paymentInfoCard(),
          ]
        ],
      ),
    );
  }

  Widget _voucherSection(double subtotal, double discount) {
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
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.card_giftcard, color: Colors.black87),
        title: const Text(
          "Áp dụng ưu đãi và giảm giá",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _selectedVoucherLabel(),
          style: const TextStyle(color: Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black54),
        onTap: () => _openVoucherPicker(subtotal),
      ),
    );
  }

  Widget _summarySection(
      double subtotal, double shipping, double discount, double total) {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chi tiết thanh toán",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _row("Tổng tiền hàng", subtotal),
          _row("Phí vận chuyển", shipping),
          _row("Giảm giá", -discount),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tổng cộng",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                _price(total),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _row(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            _price(value),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeOrderButton(double total, double shipping) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tổng cộng:",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
            Text(
              _price(total),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.red,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _submitOrder(total, shipping),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F7A52),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Đặt đơn",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openVoucherPicker(double subtotal) {
    final voucherP = Provider.of<VoucherProvider>(context, listen: false);
    final appVouchers = voucherP.publicVouchers;
    final storeVouchers = widget.store.storeVouchers.isNotEmpty
        ? widget.store.storeVouchers
        : Provider.of<StoreProvider>(context, listen: false).storeVouchers;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Chọn mã giảm giá",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedAppVoucher = null;
                              selectedStoreVoucher = null;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Bỏ chọn"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Mã giảm giá",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (appVouchers.isEmpty)
                      const Text("Không có mã giảm giá"),
                    ...appVouchers
                        .map((v) => _voucherTile(voucher: v, subtotal: subtotal))
                        .toList(),
                    const SizedBox(height: 12),
                    const Text(
                      "Mã giảm giá cửa hàng",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (storeVouchers.isEmpty)
                      const Text("Không có mã giảm giá"),
                    ...storeVouchers
                        .map((v) => _storeVoucherTile(v, subtotal))
                        .toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _voucherTile({required VoucherModel voucher, required double subtotal}) {
    final isSelected = selectedAppVoucher?.id == voucher.id;
    final canUse = subtotal >= voucher.minOrderAmount;
    return ListTile(
      dense: true,
      leading: const Icon(Icons.local_offer, color: Color(0xFF1F7A52)),
      title: Text(voucher.title),
      subtitle: Text(
        "Tối thiểu ${voucher.minOrderAmount.toStringAsFixed(0)}đ",
      ),
      trailing: Radio<bool>(
        value: true,
        groupValue: isSelected && canUse,
        onChanged: canUse
            ? (_) {
                setState(() {
                  selectedAppVoucher = voucher;
                  selectedStoreVoucher = null;
                });
                Navigator.pop(context);
              }
            : null,
      ),
      enabled: canUse,
      onTap: canUse
          ? () {
              setState(() {
                selectedAppVoucher = voucher;
                selectedStoreVoucher = null;
              });
              Navigator.pop(context);
            }
          : null,
    );
  }

  Widget _storeVoucherTile(StoreVoucherModel v, double subtotal) {
    final isSelected = selectedStoreVoucher?.id == v.id;
    final canUse = subtotal >= v.minOrderValue;
    return ListTile(
      dense: true,
      leading: const Icon(Icons.store, color: Color(0xFF1F7A52)),
      title: Text(
        (v.description.isNotEmpty ? v.description : v.code),
      ),
      subtitle: Text(
        "Tối thiểu ${v.minOrderValue.toStringAsFixed(0)}đ",
      ),
      trailing: Radio<bool>(
        value: true,
        groupValue: isSelected && canUse,
        onChanged: canUse
            ? (_) {
                setState(() {
                  selectedStoreVoucher = v;
                  selectedAppVoucher = null;
                });
                Navigator.pop(context);
              }
            : null,
      ),
      enabled: canUse,
      onTap: canUse
          ? () {
              setState(() {
                selectedStoreVoucher = v;
                selectedAppVoucher = null;
              });
              Navigator.pop(context);
            }
          : null,
    );
  }

  double _calcAppVoucherDiscount(double subtotal) {
    final v = selectedAppVoucher;
    if (v == null) return 0;
    if (subtotal < v.minOrderAmount) return 0;
    final discount = v.discountType == "percent"
        ? subtotal * (v.discountValue / 100)
        : v.discountValue;
    if (v.maxDiscountAmount != null) {
      return discount.clamp(0, v.maxDiscountAmount!).toDouble();
    }
    return discount.toDouble();
  }

  double _calcStoreVoucherDiscount(double subtotal) {
    final v = selectedStoreVoucher;
    if (v == null) return 0;
    if (subtotal < v.minOrderValue) return 0;
    final discount = v.discountType == "percent"
        ? subtotal * (v.discountValue / 100)
        : v.discountValue;
    if (v.maxDiscountValue != null) {
      return discount.clamp(0, v.maxDiscountValue!).toDouble();
    }
    return discount.toDouble();
  }

  String _price(num value) => "${value.toStringAsFixed(0)}đ";

  void _pickDefaultAddress(List<AddressModel> list) {
    if (list.isEmpty) return;
    final def = list.firstWhere(
      (a) => a.isDefault,
      orElse: () => list.first,
    );
    if (_defaultAddress?.id != def.id) {
      setState(() => _defaultAddress = def);
    }
  }

  void _pickDefaultPayment(List<PaymentModel> list) {
    if (list.isEmpty) return;
    final def = list.firstWhere(
      (p) => p.isDefault,
      orElse: () => list.first,
    );
    if (_defaultPayment?.id != def.id) {
      setState(() => _defaultPayment = def);
    }
  }

  String _selectedVoucherLabel() {
    if (selectedAppVoucher != null) {
      final v = selectedAppVoucher!;
      final name = v.title.isNotEmpty ? v.title : v.code;
      return _trim(name);
    }
    if (selectedStoreVoucher != null) {
      final v = selectedStoreVoucher!;
      final name = v.description.isNotEmpty ? v.description : v.code;
      return _trim(name);
    }
    return "Chưa chọn mã giảm giá.";
  }

  Widget _paymentInfoCard() {
    if (_defaultPayment == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text("Chưa có tài khoản thanh toán. Vui lòng thêm trong mục Thanh toán."),
      );
    }
    final p = _defaultPayment!;
    final tail = p.accountNumber.length >= 4
        ? p.accountNumber.substring(p.accountNumber.length - 4)
        : p.accountNumber;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE6F3EC),
            child: Text(
              p.bankName.isNotEmpty ? p.bankName[0] : "?",
              style: const TextStyle(color: Color(0xFF1F7A52)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.bankName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "**** $tail",
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  p.accountHolder,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF1F7A52))
        ],
      ),
    );
  }

  Future<void> _submitOrder(double total, double shipping) async {
    final addressId = _defaultAddress?.id;
    if (addressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn địa chỉ giao hàng")),
      );
      return;
    }
    final body = {
      "store_id": widget.store.id,
      "address_id": addressId,
      "payment_method": paymentMethod,
      "shipping_fee": shipping,
      "app_voucher_code": selectedAppVoucher?.code,
      "store_voucher_id": selectedStoreVoucher?.id,
    };

    final orderP = Provider.of<OrderProvider>(context, listen: false);
    final order = await orderP.createOrder(body);
    if (!mounted) return;
    if (order != null) {
      // refresh cart/draft
      final cartP = Provider.of<CartProvider>(context, listen: false);
      await cartP.loadCart(widget.store.id);
      await cartP.loadDraftCarts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đặt đơn thành công")),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (route) => false,
        arguments: 1, // tab Đơn hàng trong bottom nav
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đặt đơn thất bại")),
      );
    }
  }

  String _trim(String text, {int max = 36}) {
    if (text.length <= max) return text;
    return "${text.substring(0, max)}...";
  }
}
