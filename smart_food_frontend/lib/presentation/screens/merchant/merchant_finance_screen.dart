import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/earnings_provider.dart';

class MerchantFinanceScreen extends StatefulWidget {
  const MerchantFinanceScreen({super.key});

  @override
  State<MerchantFinanceScreen> createState() => _MerchantFinanceScreenState();
}

class _MerchantFinanceScreenState extends State<MerchantFinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _range = "today";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => context.read<EarningsProvider>().fetchMerchant(range: _range));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const green = Color(0xFF2C6B2F);
    final earnings = context.watch<EarningsProvider>();
    final currency = NumberFormat.currency(locale: "vi_VN", symbol: "đ", decimalDigits: 0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Tài chính",
          style: TextStyle(color: Color(0xFF2C6B2F), fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: bg,
            child: TabBar(
              controller: _tabController,
              indicatorColor: green,
              labelColor: green,
              unselectedLabelColor: Colors.black54,
              tabs: const [
                Tab(text: "Tóm tắt"),
                Tab(text: "Giao dịch"),
                Tab(text: "Số tiền thu về"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _summaryTab(earnings, currency),
                _transactionTab(earnings, currency),
                _settleTab(earnings, currency, green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String key, String label) {
    final active = _range == key;
    return InkWell(
      onTap: () async {
        setState(() => _range = key);
        await context.read<EarningsProvider>().fetchMerchant(range: key);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE8F3EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFCED6CF)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF2C6B2F) : Colors.black87,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _summaryTab(EarningsProvider earnings, NumberFormat currency) {
    final total = earnings.merchantTotal;
    final today = DateFormat("dd/MM/yyyy").format(DateTime.now());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined),
              const SizedBox(width: 8),
              const Text("Hôm nay"),
              const Spacer(),
              _chip("today", "Hôm nay"),
              const SizedBox(width: 8),
              _chip("week", "Tuần này"),
              const SizedBox(width: 8),
              _chip("month", "Tháng này"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Doanh thu ròng", style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(
                      "+ ${currency.format(total)}",
                      style: const TextStyle(
                        color: Color(0xFF2C6B2F),
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Thu nhập", style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(
                      "+ ${currency.format(total)}",
                      style: const TextStyle(
                        color: Color(0xFF2C6B2F),
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Image.network(
                "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Tóm tắt",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Color(0xFFFFF0D9),
                      child: Icon(Icons.restaurant, color: Color(0xFFCA7A0A)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Ăn uống",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 12),
                _summaryRow("Doanh thu ròng", currency.format(total)),
                _summaryRow("Khấu trừ", currency.format(0)),
                const Divider(),
                _summaryRow("Thu nhập ròng", "+ ${currency.format(total)}",
                    bold: true, color: const Color(0xFF2C6B2F)),
                const SizedBox(height: 6),
                Text("Cập nhật: $today", style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool bold = false, Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.black54, fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTab(EarningsProvider earnings, NumberFormat currency) {
    final txs = earnings.merchantTransactions;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined),
              const SizedBox(width: 8),
              _chip("today", "Hôm nay"),
              const SizedBox(width: 8),
              _chip("week", "Tuần này"),
              const SizedBox(width: 8),
              _chip("month", "Tháng này"),
            ],
          ),
        ),
        Expanded(
          child: earnings.loadingMerchant
              ? const Center(child: CircularProgressIndicator())
              : txs.isEmpty
                  ? const Center(child: Text("Chưa có giao dịch", style: TextStyle(color: Colors.black54)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (_, i) {
                        final tx = txs[i];
                        final amount = (tx["amount"] as num?)?.toDouble() ?? 0;
                        final note = tx["note"]?.toString() ?? "Giao dịch";
                        final created = tx["created_at"]?.toString() ?? "";
                        final isPositive = amount >= 0;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.receipt_long,
                            color: isPositive ? const Color(0xFF2C6B2F) : const Color(0xFFE76F51),
                          ),
                          title: Text(note, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(created),
                          trailing: Text(
                            "${isPositive ? '+' : '-'}${currency.format(amount.abs())}",
                            style: TextStyle(
                              color: isPositive ? const Color(0xFF2C6B2F) : const Color(0xFFE76F51),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: txs.length,
                    ),
        ),
      ],
    );
  }

  Widget _settleTab(EarningsProvider earnings, NumberFormat currency, Color green) {
    final total = earnings.merchantTotal;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined),
              const SizedBox(width: 8),
              _chip("today", "Hôm nay"),
              const SizedBox(width: 8),
              _chip("week", "Tuần này"),
              const SizedBox(width: 8),
              _chip("month", "Tháng này"),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Còn thiếu Pushan", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          const Text(
            "0đ",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 10),
          const Text("Số dư", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            "+ ${currency.format(total)}",
            style: const TextStyle(
              color: Color(0xFF2C6B2F),
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Image.network(
                  "https://cdn-icons-png.flaticon.com/512/2927/2927744.png",
                  width: 140,
                  height: 140,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.merchantWithdraw),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                    label: const Text(
                      "Rút tiền",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
