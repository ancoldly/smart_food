import 'dart:math' as math;
import 'package:smart_food_frontend/data/models/store_model.dart';

double _deg2rad(double deg) => deg * (math.pi / 180);

Map<String, double> normalizeLatLng(double lat, double lng) {
  double nLat = lat;
  double nLng = lng;
  final latLooksWrong = nLat.abs() > 90;
  final lngLooksWrong = nLng.abs() > 180;
  final lngLooksLikeLat = nLng.abs() <= 90 && nLat.abs() > nLng.abs();
  if (latLooksWrong || lngLooksWrong || lngLooksLikeLat) {
    final tmp = nLat;
    nLat = nLng;
    nLng = tmp;
  }
  return {"lat": nLat, "lng": nLng};
}

/// Haversine distance (km)
double distanceKm(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  const R = 6371.0; // Earth radius (km)

  final dLat = _deg2rad(lat2 - lat1);
  final dLng = _deg2rad(lng2 - lng1);

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_deg2rad(lat1)) *
          math.cos(_deg2rad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);

  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return R * c;
}

/// Distance from user to store (km)
double? distanceFromUser(
  StoreModel store,
  double? userLat,
  double? userLng,
) {
  if (userLat == null || userLng == null) return null;
  if (store.latitude == null || store.longitude == null) return null;

  // Ignore invalid GPS (0,0)
  if (userLat.abs() < 1 && userLng.abs() < 1) return null;

  final d = distanceKm(
    userLat,
    userLng,
    store.latitude!,
    store.longitude!,
  );

  // Filter out abnormal values (safety)
  if (!d.isFinite || d > 100) return null;

  return d;
}

/// Filter nearby stores (for Home)
List<StoreModel> filterNearby(
  List<StoreModel> stores,
  double? userLat,
  double? userLng,
  double radiusKm, {
  int take = 4,
}) {
  if (userLat == null || userLng == null) {
    return stores.take(take).toList();
  }

  final nearby = stores
      .where((s) {
        final d = distanceFromUser(s, userLat, userLng);
        return d != null && d <= radiusKm;
      })
      .toList();

  return nearby.take(take).toList();
}

/// ETA text for UI card
String formatEta(double? distanceKm) {
  if (distanceKm == null) return "";

  // Average city speed ~25 km/h
  final minutes = (distanceKm / 25) * 60;

  // Clamp for UX
  final minMinutes = math.max(minutes, 5);
  final total = minMinutes.round();

  if (total >= 60) {
    final h = total ~/ 60;
    final m = total % 60;
    return m == 0 ? "$h giờ" : "$h giờ $m phút";
  }

  return "$total phút";
}

/// Distance text for UI
String formatDistance(double? distanceKm) {
  if (distanceKm == null) return "";
  if (distanceKm < 1) {
    return "${(distanceKm * 1000).round()} m";
  }
  return "${distanceKm.toStringAsFixed(1)} km";
}
