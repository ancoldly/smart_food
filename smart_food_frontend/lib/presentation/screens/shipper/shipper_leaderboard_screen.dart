import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/leaderboard_provider.dart';

class ShipperLeaderboardScreen extends StatefulWidget {
  const ShipperLeaderboardScreen({super.key});

  @override
  State<ShipperLeaderboardScreen> createState() => _ShipperLeaderboardScreenState();
}

class _ShipperLeaderboardScreenState extends State<ShipperLeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<LeaderboardProvider>().fetchShipper());
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F1E6);
    final provider = context.watch<LeaderboardProvider>();
    final df = DateFormat("HH:mm dd/MM/yyyy");
    final updatedText =
        provider.updatedAt != null ? "Cập nhật vào ${df.format(provider.updatedAt!)}" : "";

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
          "Bảng xếp hạng",
          style: TextStyle(color: Color(0xFF1F7A52), fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchShipper(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _mySummary(provider),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Bảng xếp hạng TOP 10",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  updatedText,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                )
              ],
            ),
            const SizedBox(height: 10),
            _tableHeader(),
            const Divider(height: 1),
            if (provider.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text("Chưa có dữ liệu", style: TextStyle(color: Colors.black54))),
              )
            else
              ...provider.items.map((e) => _tableRow(e)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _mySummary(LeaderboardProvider p) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Số đơn của bạn tháng này",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                "${p.myCount} đơn",
                style: const TextStyle(
                  color: Color(0xFF1F7A52),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F7A52),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              p.myRank != null ? "Hạng #${p.myRank}" : "Chưa xếp hạng",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: const [
          SizedBox(width: 40, child: Text("STT", style: TextStyle(fontWeight: FontWeight.w700))),
          Expanded(
            child: Text("Tài xế", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            width: 140,
            child: Text(
              "Số đơn hàng\ntrong tháng",
              style: TextStyle(fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> e) {
    final rank = e["rank"] ?? "";
    final name = e["name"]?.toString() ?? "";
    final count = e["count"] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E0D7))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text("$rank", style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 14)),
          ),
          SizedBox(
            width: 140,
            child: Text(
              "$count đơn",
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
