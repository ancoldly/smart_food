import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:smart_food_frontend/data/models/order_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const _hereApiKey = "51ru5JzC0eFeBprRpVdOz7lFuvwhoXhWVZhquWaA5ME";
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  bool _routeLoading = false;

  LatLng? get _store =>
      (widget.order.storeLatitude != null && widget.order.storeLongitude != null)
          ? LatLng(widget.order.storeLatitude!, widget.order.storeLongitude!)
          : null;
  LatLng? get _dest =>
      (widget.order.destLatitude != null && widget.order.destLongitude != null)
          ? LatLng(widget.order.destLatitude!, widget.order.destLongitude!)
          : null;

  @override
  void initState() {
    super.initState();
    if (_store != null && _dest != null) {
      _fetchRoute();
    }
  }

  Future<void> _fetchRoute() async {
    setState(() => _routeLoading = true);
    final origin = "${_store!.latitude},${_store!.longitude}";
    final dest = "${_dest!.latitude},${_dest!.longitude}";

    // Try OSRM first (public free routing)
    final osrmUrl =
        "https://router.project-osrm.org/route/v1/driving/${_store!.longitude},${_store!.latitude};${_dest!.longitude},${_dest!.latitude}?overview=full&geometries=geojson";
    final hereUrl =
        "https://router.hereapi.com/v8/routes?transportMode=car&origin=$origin&destination=$dest&return=polyline,summary&apiKey=$_hereApiKey";

    bool ok = await _tryFetchRoute(osrmUrl, parseGeoJson: true);
    if (!ok) {
      ok = await _tryFetchRoute(hereUrl, parseGeoJson: false);
    }

    setState(() => _routeLoading = false);
    if (!ok && _store != null && _dest != null) {
      setState(() => _routePoints = [_store!, _dest!]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _routePoints.isNotEmpty
        ? LatLngBounds.fromPoints(_routePoints)
        : (_store != null && _dest != null)
            ? LatLngBounds(_store!, _dest!)
            : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Theo dõi đơn hàng",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: bounds?.center ??
                      _store ??
                      _dest ??
                      const LatLng(16.047079, 108.206230),
                  initialZoom: 14,
                  // ignore: deprecated_member_use
                  bounds: bounds,
                  // ignore: deprecated_member_use
                  boundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(40)),
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 6,
                          gradientColors: const [
                            Color(0xFF1F7A52),
                            Color(0xFFE67E22),
                          ],
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (_store != null)
                        Marker(
                          point: _store!,
                          width: 40,
                          height: 40,
                          child: _markerIcon(Colors.orange, Icons.storefront),
                        ),
                      if (_dest != null)
                        Marker(
                          point: _dest!,
                          width: 40,
                          height: 40,
                          child: _markerIcon(const Color(0xFF1F7A52), Icons.location_pin),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _bottomInfo(),
        ],
      ),
    );
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

  Widget _bottomInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.order.storeAvatar.isNotEmpty
                  ? _absoluteImageUrl(widget.order.storeAvatar)
                  : "https://via.placeholder.com/60x60.png?text=Store",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: _showOrderDetailSheet,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.storeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.order.storeAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.order.itemCount} món • ${widget.order.total.toStringAsFixed(0)}đ",
                    style: const TextStyle(
                      color: Color(0xFF1F7A52),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_routeLoading) const SizedBox(width: 12),
          if (_routeLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
        ],
      ),
    );
  }

  String _absoluteImageUrl(String url) {
    if (url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    final normalized = url.startsWith("/") ? url : "/$url";
    return "http://10.0.2.2:8000$normalized";
  }

  void _showOrderDetailSheet() {
    final status = (widget.order.status).toLowerCase();
    final steps = [
      "Đang chờ cửa hàng xác nhận",
      "Đang tìm shipper",
      "Đang trên đường đến cửa hàng",
      "Shipper đã nhận hàng",
      "Đang trên đường đến bạn",
      "Giao hàng thành công",
    ];
    int activeIndex = 0;
    if (status == "pending") activeIndex = 0;
    if (status == "preparing") activeIndex = 1;
    if (status == "delivering") activeIndex = 4;
    if (status == "completed") activeIndex = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.order.storeAvatar.isNotEmpty
                          ? _absoluteImageUrl(widget.order.storeAvatar)
                          : "https://via.placeholder.com/70x70.png?text=Store",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.storeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.order.storeAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${widget.order.itemCount} món • ${widget.order.total.toStringAsFixed(0)}đ",
                          style: const TextStyle(
                            color: Color(0xFF1F7A52),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Sẽ giao trong ít phút nữa.",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...List.generate(steps.length, (i) {
                final active = i <= activeIndex;
                final color = active ? const Color(0xFFE67E22) : Colors.grey.shade400;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.radio_button_checked, size: 18, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          steps[i],
                          style: TextStyle(
                            color: color,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),
              if (widget.order.shipperName.isNotEmpty || widget.order.shipperId != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8E0D7)),
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
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFE8F3EB),
                        child: Icon(Icons.delivery_dining, color: Color(0xFF1F7A52)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order.shipperName.isNotEmpty
                                  ? widget.order.shipperName
                                  : "Tài xế đang cập nhật",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            if (widget.order.shipperId != null)
                              Text(
                                "ID: ${widget.order.shipperId}",
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.call, color: Color(0xFFE67E22)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
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
        final sections = (routes.first is Map ? routes.first["sections"] : null) as List<dynamic>? ?? [];
        if (sections.isEmpty) return false;
        final poly = (sections.first as Map)["polyline"];
        points = _decodePolyline(poly);
      }

      if (points.length >= 2) {
        setState(() => _routePoints = points);
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  List<LatLng> _decodePolyline(dynamic poly) {
    // HERE v8 returns a flexible polyline string
    if (poly is String) {
      return _decodeFlexiblePolyline(poly);
    }
    // geojson coordinates fallback
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

  // Flexible polyline decoder (HERE) for 2D/3D, returns LatLng list
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
    final scale = math.pow(10, precision).toDouble();

    double lat = 0;
    double lon = 0;
    final points = <LatLng>[];

    while (index < encoded.length) {
      lat += _decodeSigned() / scale;
      lon += _decodeSigned() / scale;
      if (thirdDim != 0) {
      }
      points.add(LatLng(lat, lon));
    }
    return points;
  }
}
