import 'package:flutter/foundation.dart';
import 'package:smart_food_frontend/data/models/favorite_store_model.dart';
import 'package:smart_food_frontend/data/services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final List<FavoriteStoreModel> _favorites = [];
  bool _loading = false;
  bool get loading => _loading;

  List<int> get favoriteStoreIds => _favorites.map((f) => f.storeId).toList();

  bool isFavorite(int storeId) {
    return _favorites.any((f) => f.storeId == storeId);
  }

  Future<void> loadFavorites() async {
    _loading = true;
    notifyListeners();
    final ids = await FavoriteService.fetchFavoriteStoreIds();
    _favorites
      ..clear()
      ..addAll(ids.map((id) => FavoriteStoreModel(id: 0, storeId: id)));
    _loading = false;
    notifyListeners();
  }

  Future<bool?> toggleFavorite(int storeId) async {
    final result = await FavoriteService.toggleFavorite(storeId);
    if (result == null) return null;
    if (result) {
      if (!isFavorite(storeId)) {
        _favorites.add(FavoriteStoreModel(id: 0, storeId: storeId));
      }
    } else {
      _favorites.removeWhere((f) => f.storeId == storeId);
    }
    notifyListeners();
    return result;
  }
}
