import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';

class StoreInfoDetailScreen extends StatelessWidget {
  final StoreModel store;
  final String? distanceText;
  final String? etaText;

  const StoreInfoDetailScreen({
    super.key,
    required this.store,
    this.distanceText,
    this.etaText,
  });

  @override
  Widget build(BuildContext context) {
    final tagNames = store.tags.map((t) => t.name).toList();
    final hours = List.of(store.operatingHours)..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thông tin cửa hàng",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoCard(tagNames),
          const SizedBox(height: 12),
          _section("Về chúng tôi", [
            _row(Icons.access_time, "Giờ hoạt động", _hoursSummary(hours)),
            _row(Icons.place, "Địa chỉ", "${store.address} ${store.city}".trim()),
            _row(Icons.directions_walk, "Khoảng cách", distanceText ?? "Chưa rõ"),
            _row(Icons.timer, "Thời gian giao", etaText ?? "Chưa rõ"),
          ]),
          if (hours.isNotEmpty) ...[
            const SizedBox(height: 12),
            _hoursSection(hours),
          ],
          const SizedBox(height: 12),
          _section("Liên hệ", [
            _row(Icons.person, "Quản lý", store.managerName),
            _row(Icons.phone, "Điện thoại", store.managerPhone),
            _row(Icons.email, "Email", store.managerEmail),
          ]),
        ],
      ),
    );
  }

  Widget _infoCard(List<String> tags) {
    final statusText = store.status == 4 ? "Đang đóng cửa" : "Đang mở cửa";
    final statusColor =
        store.status == 4 ? Colors.red : const Color(0xFF2C6B2F);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              store.avatarImage ??
                  "https://via.placeholder.com/72.png?text=Logo",
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.storeName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _pill(statusText, color: statusColor),
                    if (tags.isNotEmpty)
                      ...tags.map((t) => _pill(t))
                    else
                      _pill("Ship nhanh"),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF5B7B56)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : "Chưa cập nhật",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, {Color color = Colors.orange}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _hoursSection(List<dynamic> hours) {
    const days = [
      "Thứ 2",
      "Thứ 3",
      "Thứ 4",
      "Thứ 5",
      "Thứ 6",
      "Thứ 7",
      "Chủ nhật",
    ];
    final rows = hours.map((h) {
      final label = days[h.dayOfWeek % 7];
      final value = h.isClosed
          ? "Đóng cửa"
          : "${h.openTime ?? '--:--'} - ${h.closeTime ?? '--:--'}";
      return _row(Icons.calendar_today, label, value);
    }).toList();

    return _section(
      "Lịch mở cửa",
      rows,
    );
  }

  String _hoursSummary(List<dynamic> hours) {
    if (hours.isEmpty) return "Chưa thiết lập";
    final openHour = hours.cast().where((h) => !h.isClosed).toList();
    if (openHour.isEmpty) return "Đang đóng cửa";
    final first = openHour.first;
    final open = first.openTime ?? "--:--";
    final close = first.closeTime ?? "--:--";
    return "$open - $close";
  }
}
