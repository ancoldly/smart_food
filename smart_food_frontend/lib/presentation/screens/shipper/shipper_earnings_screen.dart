import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_food_frontend/providers/earnings_provider.dart';

class ShipperEarningsScreen extends StatefulWidget {
  const ShipperEarningsScreen({super.key});

  @override
  State<ShipperEarningsScreen> createState() => _ShipperEarningsScreenState();
}

class _ShipperEarningsScreenState extends State<ShipperEarningsScreen> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<EarningsProvider>().fetchShipper());
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F1E6);
    final provider = context.watch<EarningsProvider>();
    final items = _filtered(provider.shipperTransactions);
    final currency = NumberFormat.currency(locale: "vi_VN", symbol: "đ", decimalDigits: 0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F7A52)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thu nhập",
          style: TextStyle(color: Color(0xFF1F7A52), fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchShipper(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _summaryCard(provider, currency),
            const SizedBox(height: 12),
            _filterRow(context),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text("Chưa có giao dịch", style: TextStyle(color: Colors.black54)),
                ),
              )
            else
              ...items.map((e) => _earningTile(e, currency)).toList(),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> list) {
    return list.where((e) {
      final dt = e["created_at"] as DateTime?;
      if (dt == null) return false;
      if (_from != null && dt.isBefore(_from!)) return false;
      if (_to != null && dt.isAfter(_to!)) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        final da = a["created_at"] as DateTime?;
        final db = b["created_at"] as DateTime?;
        if (da == null || db == null) return 0;
        return db.compareTo(da);
      });
  }

  Widget _summaryCard(EarningsProvider p, NumberFormat currency) {
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
      child: Column(
        children: [
          const Text("Tổng thu nhập", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            p.loadingShipper ? "..." : currency.format(p.shipperTotal),
            style: const TextStyle(
              color: Color(0xFF1F7A52),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Số giao dịch: ${p.shipperCount}",
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _filterRow(BuildContext context) {
    String label(DateTime? d) => d == null ? "Chọn ngày" : DateFormat("dd/MM/yyyy").format(d);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(true),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF1F7A52)),
            ),
            child: Text("Từ: ${label(_from)}"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF1F7A52)),
            ),
            child: Text("Đến: ${label(_to)}"),
          ),
        ),
        IconButton(
          onPressed: () => setState(() {
            _from = null;
            _to = null;
          }),
          icon: const Icon(Icons.clear),
        )
      ],
    );
  }

  Widget _earningTile(Map<String, dynamic> e, NumberFormat currency) {
    final dt = e["created_at"] as DateTime?;
    final amount = (e["amount"] as num?)?.toDouble() ?? 0;
    final note = e["note"]?.toString() ?? "";
    final isPositive = amount >= 0;
    final dateText = dt != null ? DateFormat("dd/MM/yyyy HH:mm").format(dt) : "";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_downward : Icons.arrow_upward,
            color: isPositive ? const Color(0xFF1F7A52) : const Color(0xFFE76F51),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.isNotEmpty ? note : (isPositive ? "Nhận tiền" : "Trả tiền"),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            currency.format(amount),
            style: TextStyle(
              color: isPositive ? const Color(0xFF1F7A52) : const Color(0xFFE76F51),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDate: isFrom ? (_from ?? now) : (_to ?? now),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked.add(const Duration(hours: 23, minutes: 59));
        }
      });
    }
  }
}
