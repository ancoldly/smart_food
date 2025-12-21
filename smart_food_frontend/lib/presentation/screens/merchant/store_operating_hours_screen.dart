import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/store_operating_hour_model.dart';
import 'package:smart_food_frontend/providers/store_hours_provider.dart';

class StoreOperatingHoursScreen extends StatefulWidget {
  const StoreOperatingHoursScreen({super.key});

  @override
  State<StoreOperatingHoursScreen> createState() =>
      _StoreOperatingHoursScreenState();
}

class _StoreOperatingHoursScreenState extends State<StoreOperatingHoursScreen> {
  final List<String> _weekdayLabels = const [
    "Thứ 2",
    "Thứ 3",
    "Thứ 4",
    "Thứ 5",
    "Thứ 6",
    "Thứ 7",
    "Chủ nhật",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<StoreHoursProvider>(context, listen: false).loadHours();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StoreHoursProvider>(context);
    final hours = provider.hours;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Giờ hoạt động",
          style: TextStyle(
            color: Color(0xFF391713),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF391713)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (index >= hours.length) return const SizedBox.shrink();
                final hour = hours[index];
                return _HourCard(
                  label: _weekdayLabels[hour.dayOfWeek],
                  hour: hour,
                  onChanged: (data) => _updateHour(hour, data),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: hours.length,
            ),
    );
  }

  Future<void> _updateHour(
      StoreOperatingHourModel hour, Map<String, dynamic> data) async {
    final provider = Provider.of<StoreHoursProvider>(context, listen: false);
    await provider.updateHour(
      id: hour.id,
      isClosed: data["is_closed"] ?? hour.isClosed,
      openTime: data["open_time"] ?? hour.openTime,
      closeTime: data["close_time"] ?? hour.closeTime,
    );
  }
}

class _HourCard extends StatelessWidget {
  final String label;
  final StoreOperatingHourModel hour;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _HourCard({
    required this.label,
    required this.hour,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = !hour.isClosed;
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF391713),
                ),
              ),
              const Spacer(),
              Text(
                isOpen ? "Đang mở" : "Đóng cửa",
                style: TextStyle(
                  color: isOpen ? const Color(0xFF2C6B2F) : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                activeColor: const Color(0xFF2C6B2F),
                value: isOpen,
                onChanged: (value) {
                  final Map<String, dynamic> data = <String, dynamic>{
                    "is_closed": !value,
                  };
                  if (value && (hour.openTime == null || hour.closeTime == null)) {
                    data["open_time"] = "08:00";
                    data["close_time"] = "22:00";
                  }
                  onChanged(data);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _TimeButton(
                label: "Mở cửa",
                value: hour.openTime ?? "--:--",
                enabled: isOpen,
                onTap: () async {
                  final picked = await _pickTime(context, hour.openTime);
                  if (picked != null) {
                    onChanged({
                      "open_time": picked,
                      "is_closed": hour.isClosed,
                    });
                  }
                },
              ),
              const SizedBox(width: 12),
              _TimeButton(
                label: "Đóng cửa",
                value: hour.closeTime ?? "--:--",
                enabled: isOpen,
                onTap: () async {
                  final picked = await _pickTime(context, hour.closeTime);
                  if (picked != null) {
                    onChanged({
                      "close_time": picked,
                      "is_closed": hour.isClosed,
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _pickTime(BuildContext context, String? initial) async {
    final now = TimeOfDay.now();
    final initialTime = _parseTime(initial) ?? now;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) return null;
    final hh = picked.hour.toString().padLeft(2, "0");
    final mm = picked.minute.toString().padLeft(2, "0");
    return "$hh:$mm";
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null || !time.contains(":")) return null;
    final parts = time.split(":");
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final String value;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(
            color: enabled ? const Color(0xFF391713) : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: enabled ? const Color(0xFF391713) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: enabled ? const Color(0xFF391713) : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
