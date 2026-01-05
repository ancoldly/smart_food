import 'dart:async';

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/auth_provider.dart';
import 'package:smart_food_frontend/providers/shipper_order_provider.dart';
import 'package:smart_food_frontend/providers/notification_provider.dart';
import 'package:smart_food_frontend/providers/shipper_provider.dart';
import 'package:http/http.dart' as http;

class ShipperHomeScreen extends StatefulWidget {
  const ShipperHomeScreen({super.key});

  @override
  State<ShipperHomeScreen> createState() => _ShipperHomeScreenState();
}

class _ShipperHomeScreenState extends State<ShipperHomeScreen> {
  final MapController _mapController = MapController();
  final String hereApiKey = "51ru5JzC0eFeBprRpVdOz7lFuvwhoXhWVZhquWaA5ME";
  LatLng currentCenter = const LatLng(16.047079, 108.206230);
  double currentZoom = 16.0;
  List<LatLng> _routePoints = [];
  bool _routeLoading = false;
  int? _trackedOrderId;
  LatLngBounds? _currentBounds;

  bool waitingTab = true;
  bool showMenu = false;
  bool autoAccept = false;
  int? _suggestionOrderId;
  DateTime? _suggestionExpire;
  bool _suggestionDismissed = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final sp = context.read<ShipperProvider>();
      final op = context.read<ShipperOrderProvider>();
      await context.read<NotificationProvider>().fetchNotifications();
      await sp.fetchMe();
      await sp.updateLocation(currentCenter.latitude, currentCenter.longitude);
      await op.load();
      _startPolling();
    });
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      context.read<ShipperOrderProvider>().refresh();
      context.read<NotificationProvider>().fetchNotifications();
      _maybeUpdateRoute();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F1E6);
    const green = Color(0xFF1F7A52);
    const orange = Color(0xFFE76F51);

    final shipperProvider = context.watch<ShipperProvider>();
    final orderProvider = context.watch<ShipperOrderProvider>();
    final shipper = shipperProvider.me;
    final fullName = shipper?["full_name"] ?? "Shipper";
    final isOnline = (shipper?["status"] == 4);
    final statusText = isOnline ? "Đang nhận đơn" : "Ngoại tuyến";

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _header(fullName, statusText),
                _tabs(orange, orderProvider),
                Expanded(child: waitingTab ? _mapArea(orderProvider) : _ordersTab(orderProvider)),
                _actionBar(green, isOnline),
              ],
            ),
          ),
          if (showMenu) _menuOverlay(fullName, isOnline),
        ],
      ),
    );
  }

  Widget _header(String fullName, String statusText) {
    const bg = Color(0xFFF9F1E6);
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => showMenu = true),
            child: const CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(
                "https://cl-wpml.careerlink.vn/cam-nang-viec-lam/wp-content/uploads/2023/02/28141652/3692229-1-1024x1024.jpg",
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _tabs(Color activeColor, ShipperOrderProvider provider) {
    const bg = Color(0xFFF9F1E6);
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          _tabItem("ĐỢI ĐƠN", waitingTab, activeColor, () {
            setState(() => waitingTab = true);
          }),
          _tabItem("ĐƠN ĐANG NHẬN", !waitingTab, Colors.black54, () {
            setState(() => waitingTab = false);
            provider.refresh();
          }),
        ],
      ),
    );
  }

  Widget _tabItem(String label, bool active, Color activeColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: active ? activeColor : Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: 80,
              color: active ? activeColor : Colors.transparent,
            )
          ],
        ),
      ),
    );
  }

  Widget _mapArea(ShipperOrderProvider orderProvider) {
    final available = orderProvider.available;
    final activeAssigned = orderProvider.assigned
        .where((o) {
          final s = o.status.toLowerCase();
          return s != "completed" && s != "cancelled";
        })
        .toList();
    final tracked = activeAssigned.isNotEmpty
        ? activeAssigned.first
        : (available.isNotEmpty ? available.first : null);
    _maybeUpdateRoute(tracked: tracked);
    // Reset suggestion when top available changes
    if (available.isNotEmpty && available.first.id != _suggestionOrderId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _suggestionOrderId = available.first.id;
          _suggestionExpire = DateTime.now().add(const Duration(minutes: 2));
          _suggestionDismissed = false;
        });
      });
    }

    final showSuggestion = available.isNotEmpty &&
        !_suggestionDismissed &&
        (_suggestionExpire == null || DateTime.now().isBefore(_suggestionExpire!));

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: currentCenter,
            initialZoom: currentZoom,
            onPositionChanged: (pos, _) {
              if (pos.center != null) {
                currentCenter = pos.center!;
              }
              if (pos.zoom != null) {
                setState(() => currentZoom = pos.zoom!);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://maps.hereapi.com/v3/base/mc/{z}/{x}/{y}/png?apiKey=$hereApiKey",
              userAgentPackageName: "smart_food_frontend",
            ),
            if (_routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 6,
                    color: const Color(0xFF1F7A52),
                  ),
                ],
              ),
            if (tracked != null)
              MarkerLayer(
                markers: [
                  if (tracked.storeLatitude != null && tracked.storeLongitude != null)
                    Marker(
                      point: LatLng(tracked.storeLatitude!, tracked.storeLongitude!),
                      width: 36,
                      height: 36,
                      child: _markerIcon(Colors.orange, Icons.storefront),
                    ),
                  if (tracked.destLatitude != null && tracked.destLongitude != null)
                    Marker(
                      point: LatLng(tracked.destLatitude!, tracked.destLongitude!),
                      width: 36,
                      height: 36,
                      child: _markerIcon(const Color(0xFF1F7A52), Icons.location_pin),
                    ),
                ],
              ),
          ],
        ),
        if (showSuggestion) _suggestionCard(available.first),
        // Thông báo chỉ hiển thị trong menu -> không overlay ở map nữa
        Positioned(
          top: 16,
          left: 12,
          child: Column(
            children: [
              _zoomButton(Icons.add, () {
                currentZoom += 0.5;
                _mapController.move(currentCenter, currentZoom);
              }),
              const SizedBox(height: 12),
              Text(
                currentZoom.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const SizedBox(height: 12),
              _zoomButton(Icons.remove, () {
                currentZoom -= 0.5;
                _mapController.move(currentCenter, currentZoom);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ordersTab(ShipperOrderProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final assigned = provider.assigned
        .where((o) {
          final s = o.status.toLowerCase();
          return s != "completed" && s != "cancelled";
        })
        .toList();

    if (assigned.isEmpty) {
      return _emptyOrder();
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            "Đơn đang giao",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...assigned.map((o) => _orderCard(o, isAssigned: true, provider: provider)),
        ],
      ),
    );
  }

  Widget _emptyOrder() {
    return Container(
      color: const Color(0xFFF9F1E6),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            "https://cdn-icons-png.flaticon.com/512/5161/5161286.png",
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            "Chưa có đơn hàng nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Chờ chút nhé. PushanFood đang tìm đơn hàng cho bạn",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _maybeUpdateRoute({OrderModel? tracked}) async {
    final provider = context.read<ShipperOrderProvider>();
    tracked ??= provider.assigned.firstWhere(
      (o) => o.status.toLowerCase() != "completed" && o.status.toLowerCase() != "cancelled",
      orElse: () => provider.available.isNotEmpty ? provider.available.first : null as OrderModel,
    );
    if (tracked == null) return;
    if (_trackedOrderId == tracked.id && _routePoints.isNotEmpty) return;
    if (tracked.storeLatitude == null ||
        tracked.storeLongitude == null ||
        tracked.destLatitude == null ||
        tracked.destLongitude == null) {
      return;
    }

    _trackedOrderId = tracked.id;
    setState(() => _routeLoading = true);
    final storePoint = LatLng(tracked.storeLatitude!, tracked.storeLongitude!);
    final destPoint = LatLng(tracked.destLatitude!, tracked.destLongitude!);
    final osrmUrl =
        "https://router.project-osrm.org/route/v1/driving/${tracked.storeLongitude},${tracked.storeLatitude};${tracked.destLongitude},${tracked.destLatitude}?overview=full&geometries=geojson";
    bool ok = await _tryFetchRoute(osrmUrl, parseGeoJson: true);
    if (!ok) {
      final origin = "${tracked.storeLatitude},${tracked.storeLongitude}";
      final dest = "${tracked.destLatitude},${tracked.destLongitude}";
      final hereUrl =
          "https://router.hereapi.com/v8/routes?transportMode=car&origin=$origin&destination=$dest&return=polyline,summary&apiKey=$hereApiKey";
      ok = await _tryFetchRoute(hereUrl, parseGeoJson: false);
    }
    if (!ok) {
      final fallback = [storePoint, destPoint];
      setState(() => _routePoints = fallback);
      _fitToRoute(fallback);
    }
    setState(() => _routeLoading = false);
  }

  Future<bool> _tryFetchRoute(String url, {required bool parseGeoJson}) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return false;
      final decoded = json.decode(utf8.decode(res.bodyBytes));
      List<LatLng> points = [];

      if (parseGeoJson) {
        final routes = (decoded is Map ? decoded["routes"] : null) as List<dynamic>? ?? [];
        if (routes.isEmpty) return false;
        final geom =
            (routes.first is Map ? routes.first["geometry"] : null) as Map<String, dynamic>?;
        final coords = geom?["coordinates"] as List<dynamic>? ?? [];
        points = coords
            .map((c) => c is List && c.length >= 2
                ? LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())
                : null)
            .whereType<LatLng>() 
            .toList();
      } else {
        final routes = (decoded is Map ? decoded["routes"] : null) as List<dynamic>? ?? [];
        if (routes.isEmpty) return false;
        final sections =
            (routes.first is Map ? routes.first["sections"] : null) as List<dynamic>? ?? [];
        if (sections.isEmpty) return false;
        final poly = (sections.first as Map)["polyline"];
        points = _decodePolyline(poly);
      }

      if (points.length >= 2) {
        setState(() => _routePoints = points);
        _fitToRoute(points);
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  List<LatLng> _decodePolyline(dynamic poly) {
    if (poly is String) {
      return _decodeFlexiblePolyline(poly);
    }
    if (poly is Map && poly["coordinates"] is List) {
      final coords = poly["coordinates"] as List;
      return coords
          .map((c) => c is List && c.length >= 2
              ? LatLng((c[0] as num).toDouble(), (c[1] as num).toDouble())
              : null)
          .whereType<LatLng>()
          .toList();
    }
    return [];
  }

  List<LatLng> _decodeFlexiblePolyline(String encoded) {
    if (encoded.isEmpty) return [];
    int index = 0;

    int _decodeUnsigned() {
      int result = 0;
      int shift = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      return result;
    }

    int _decodeSigned() {
      final unsigned = _decodeUnsigned();
      return (unsigned & 1) != 0 ? ~(unsigned >> 1) : (unsigned >> 1);
    }

    final header = _decodeUnsigned();
    final precision = header & 0x0f;
    final thirdDim = (header >> 4) & 0x07;
    final thirdDimPrecision = (header >> 7) & 0x0f;
    final scale = math.pow(10, precision).toDouble();
    final thirdScale = math.pow(10, thirdDimPrecision).toDouble();

    double lat = 0;
    double lon = 0;
    double z = 0;
    final points = <LatLng>[];

    while (index < encoded.length) {
      lat += _decodeSigned() / scale;
      lon += _decodeSigned() / scale;
      if (thirdDim != 0) {
        z += _decodeSigned() / thirdScale;
      }
      points.add(LatLng(lat, lon));
    }
    return points;
  }

  Widget _markerIcon(Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void _fitToRoute(List<LatLng> points) {
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    _currentBounds = bounds;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(40)),
      );
    });
  }
  Widget _orderCard(OrderModel order,
      {required bool isAssigned, required ShipperOrderProvider provider}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: order);
      },
      child: Container(
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
            )
          ],
          border: Border.all(color: const Color(0xFFE8E0D7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.storeName.isNotEmpty ? order.storeName : "Đơn #${order.id}",
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              order.storeAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              "${_currency(order.total)} (${order.itemCount} món)",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAssigned ? const Color(0xFF2C6B2F) : const Color(0xFFE76F51),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      if (isAssigned) {
                        await provider.complete(order.id);
                        setState(() {
                          _routePoints = [];
                          _trackedOrderId = null;
                          _currentBounds = null;
                        });
                      } else {
                        await provider.accept(order.id);
                      }
                    },
                    child: Text(
                      isAssigned ? "Hoàn thành" : "Nhận đơn",
                      style:
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _actionBar(Color green, bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: isOnline
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Đang nhận đơn",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: () async {
                  final sp = context.read<ShipperProvider>();
                  final op = context.read<ShipperOrderProvider>();
                  await sp.toggleStatus(true);
                  await op.refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Bắt đầu nhận đơn",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _menuOverlay(String fullName, bool isOnline) {
    const bg = Color(0xFFF9F1E6);
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => setState(() => showMenu = false),
            child: Container(color: Colors.black45),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: double.infinity,
            color: bg,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(
                            "https://cl-wpml.careerlink.vn/cam-nang-viec-lam/wp-content/uploads/2023/02/28141652/3692229-1-1024x1024.jpg"),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Chúc bạn một ngày chạy thật\nnhiều đơn và an toàn",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _menuToggle("Trạng thái nhận đơn", isOnline, (v) async {
                  await context.read<ShipperProvider>().toggleStatus(v);
                  setState(() {});
                }),
                const SizedBox(height: 12),
                _menuToggle("Nhận đơn tự động", autoAccept, (v) {
                  setState(() => autoAccept = v);
                }),
                const SizedBox(height: 10),
                _menuItemRow("Thông báo", onTap: () {
                  setState(() => showMenu = false);
                  Navigator.pushNamed(context, AppRoutes.shipperNotifications);
                }),
                _menuItemRow("Thu nhập", onTap: () {
                  setState(() => showMenu = false);
                  Navigator.pushNamed(context, AppRoutes.shipperEarnings);
                }),
                _menuItemRow("Ví & giao dịch", onTap: () {
                  Navigator.pushNamed(context, AppRoutes.shipperWallet);
                }),
                _menuItemRow("Cập nhật thông tin", onTap: () {
                  Navigator.pushNamed(context, AppRoutes.shipperProfileEdit);
                }),
                _menuItemRow("Bảng xếp hạng", onTap: () {
                  setState(() => showMenu = false);
                  Navigator.pushNamed(context, AppRoutes.shipperLeaderboard);
                }),
                _menuItemRow("Đơn đã chạy", onTap: () {
                  setState(() => showMenu = false);
                  Navigator.pushNamed(context, AppRoutes.shipperHistory);
                }),
                _menuItemRow("Hỗ trợ & giải đáp", onTap: () {
                  Navigator.pushNamed(context, AppRoutes.shipperSupport);
                }),
                _menuItemRow("Cài đặt"),
                _menuItemRow(
                  "Đăng xuất",
                  onTap: () => _logout(context),
                  icon: Icons.logout,
                  color: Colors.red,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItemRow(String title,
      {VoidCallback? onTap, IconData icon = Icons.chevron_right, Color? color}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(icon, color: color ?? Colors.black54),
      onTap: onTap,
    );
  }

  Widget _menuToggle(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: const Color(0xFF2C6B2F),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F7A52)),
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  String _currency(double value) => "${value.toStringAsFixed(0)}đ";

  double? _distanceKm(OrderModel order) {
    final slat = order.storeLatitude;
    final slng = order.storeLongitude;
    final dlat = order.destLatitude;
    final dlng = order.destLongitude;
    if (slat == null || slng == null || dlat == null || dlng == null) return null;
    const R = 6371.0;
    double toRad(double deg) => deg * 3.1415926535 / 180;
    final dLat = toRad(dlat - slat);
    final dLng = toRad(dlng - slng);
    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(toRad(slat)) * math.cos(toRad(dlat)) * (math.sin(dLng / 2) * math.sin(dLng / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  Widget _suggestionCard(OrderModel order) {
    final dist = _distanceKm(order);
    final distanceText = dist != null ? "${dist.toStringAsFixed(1)}km" : "";
    // Chỉ hiển thị số tiền cần thu từ khách (tiền mặt = tổng, thẻ = 0)
    final collectText = order.paymentMethod == "cash" ? _currency(order.total) : "0đ";

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  distanceText,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  collectText,
                  style: const TextStyle(
                    color: Color(0xFFE64A19),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, color: Colors.red, size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Lấy hàng: ${order.storeName}",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        order.storeAddress,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Giao hàng: ${order.receiverName}",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        order.addressLine,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<ShipperOrderProvider>().accept(order.id);
                      setState(() {
                        _suggestionDismissed = true;
                        _trackedOrderId = order.id;
                        _routePoints = [];
                      });
                      await _maybeUpdateRoute(tracked: order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F7A52),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "Nhận đơn",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _suggestionDismissed = true),
                  icon: const Icon(Icons.close),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
