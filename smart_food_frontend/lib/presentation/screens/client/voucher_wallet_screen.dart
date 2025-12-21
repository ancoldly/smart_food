import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/voucher_model.dart';
import 'package:smart_food_frontend/providers/voucher_provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class VoucherWalletScreen extends StatefulWidget {
  const VoucherWalletScreen({super.key});

  @override
  State<VoucherWalletScreen> createState() => _VoucherWalletScreenState();
}

class _VoucherWalletScreenState extends State<VoucherWalletScreen> {
  final DateFormat _df = DateFormat("dd/MM");
  String _filter = "all";

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<VoucherProvider>(context, listen: false).loadPublic());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VoucherProvider>(context);
    final vouchers = _filterVouchers(provider.publicVouchers);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Ví voucher",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _filterTabs(),
          const SizedBox(height: 12),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vouchers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _voucherCard(vouchers[index]);
                    },
                  ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  Widget _filterTabs() {
    Widget tab(String label, String value) {
      final selected = _filter == value;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _filter = value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              border: Border.all(color: const Color(0xFFE0D5C8)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? const Color(0xFFE76E27) : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: Color(0xFFE76E27)),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          tab("Tất cả", "all"),
          const SizedBox(width: 8),
          tab("Giảm %", "percent"),
          const SizedBox(width: 8),
          tab("Giảm tiền", "fixed"),
        ],
      ),
    );
  }

  Widget _voucherCard(VoucherModel v) {
    final isFixed = v.discountType == "fixed";
    final leftColor =
        isFixed ? const Color(0xFF237B4B) : const Color(0xFFE76E27);

    final discountText = v.discountType == "percent"
        ? "Giảm ${v.discountValue.toStringAsFixed(0)}%"
        : "Giảm ${_formatMoney(v.discountValue)}đ";

    final minText = v.discountType == "percent"
        ? "Giảm tối đa ${_formatMoney(v.maxDiscountAmount ?? 0)}đ"
        : "Đơn tối thiểu ${_formatMoney(v.minOrderAmount)}đ";

    final desc = v.description?.isNotEmpty == true
        ? v.description!
        : "Đơn tối thiểu ${_formatMoney(v.minOrderAmount)}đ";

    final time =
        "${v.startAt != null ? _df.format(v.startAt!) : '-'} - ${v.endAt != null ? _df.format(v.endAt!) : '-'}";

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.voucherDetail,
        arguments: {"voucher": v},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEBAE5B)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 80,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: leftColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.confirmation_num,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        discountText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        minText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.black38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.orange,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<VoucherModel> _filterVouchers(List<VoucherModel> list) {
    if (_filter == "all") return list;
    if (_filter == "percent") {
      return list.where((v) => v.discountType == "percent").toList();
    }
    // fixed
    return list.where((v) => v.discountType == "fixed").toList();
  }

  String _formatMoney(double v) {
    return v
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.");
  }
}
