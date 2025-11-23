import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final MapController _mapController = MapController();
  final TextEditingController searchCtrl = TextEditingController();

  final String hereApiKey = "51ru5JzC0eFeBprRpVdOz7lFuvwhoXhWVZhquWaA5ME";
  LatLng currentCenter = const LatLng(16.047079, 108.206230);

  List<dynamic> searchResults = [];
  bool _isLoadingAddress = false;
  Timer? _debounce;

  @override
  void dispose() {
    searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Chọn vị trí trên bản đồ",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentCenter,
              initialZoom: 16,
              onPositionChanged: (pos, _) {
                if (pos.center != null) {
                  currentCenter = pos.center!;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://maps.hereapi.com/v3/base/mc/{z}/{x}/{y}/png?apiKey=$hereApiKey",
                userAgentPackageName: "smart_food_frontend",
              ),
            ],
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              size: 40,
              color: Colors.red,
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: searchCtrl,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Nhập địa chỉ, đường, phường...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (searchResults.isNotEmpty)
            Positioned(
              top: 70,
              left: 12,
              right: 12,
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchResults.length,
                  itemBuilder: (_, i) {
                    final item = searchResults[i];
                    final title = item["title"] ?? "Không có tên";
                    final address =
                        item["address"]?["label"] ?? item["title"] ?? "";
                    final position = item["position"];
                    final lat = position?["lat"];
                    final lng = position?["lng"];

                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: address.isNotEmpty
                          ? Text(
                              address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        if (lat != null && lng != null) {
                          _mapController.move(LatLng(lat, lng), 17);
                          searchCtrl.text =
                              address.isNotEmpty ? address : title;
                          setState(() => searchResults = []);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isLoadingAddress ? null : _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B7B56),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isLoadingAddress
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Dùng vị trí này",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchLocation(value.trim());
    });
  }

  Future<void> _searchLocation(String query) async {
    try {
      final lat = currentCenter.latitude;
      final lng = currentCenter.longitude;

      final url = "https://autosuggest.search.hereapi.com/v1/autosuggest"
          "?q=${Uri.encodeQueryComponent(query)}"
          "&at=$lat,$lng"
          "&limit=8"
          "&lang=vi"
          "&apiKey=$hereApiKey";

      final res = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final items = (data["items"] as List?)
                ?.where((e) => e["position"] != null)
                .toList() ??
            [];

        setState(() {
          searchResults = items;
        });
      } else {
        setState(() => searchResults = []);
      }
    } catch (_) {
      if (mounted) {
        setState(() => searchResults = []);
      }
    }
  }

  Future<void> _confirmLocation() async {
    setState(() => _isLoadingAddress = true);

    final lat = currentCenter.latitude;
    final lng = currentCenter.longitude;

    String street = "";
    String ward = "";
    String fullAddress = "";

    try {
      final url = "https://revgeocode.search.hereapi.com/v1/revgeocode"
          "?at=$lat,$lng"
          "&lang=vi"
          "&apiKey=$hereApiKey";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));

        if (data["items"] != null && data["items"].isNotEmpty) {
          final item = data["items"][0];
          final addr = item["address"];

          fullAddress = addr["label"] ?? "";

          street = [
            addr["houseNumber"],
            addr["street"],
          ].where((e) => e != null && e.toString().isNotEmpty).join(" ");

          ward = [
            addr["district"],
            addr["city"],
            addr["state"],
            addr["countryName"],
          ].where((e) => e != null && e.toString().isNotEmpty).join(", ");
        }
      }
    } catch (_) {}

    if (!mounted) return;

    setState(() => _isLoadingAddress = false);

    Navigator.pop(context, {
      "lat": lat,
      "lng": lng,
      "address": fullAddress,
      "street": street,
      "ward": ward,
    });
  }
}
