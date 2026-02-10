import '../../../core/api/api_client.dart';
import 'avatar.dart';

/// Avatar repository for API calls
class AvatarRepository {
  final ApiClient _apiClient;

  AvatarRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all shop items
  Future<ShopData> getShop() async {
    final response = await _apiClient.get('/avatar/shop');
    final data = response.data['data'];
    final itemsList = (data['items'] as List)
        .map((json) => AvatarItem.fromJson(json))
        .toList();

    return ShopData(
      items: itemsList,
      totalItems: data['total'] ?? itemsList.length,
    );
  }

  /// Get child's avatar state
  Future<AvatarState> getAvatar(String childId) async {
    final response = await _apiClient.get('/avatar/$childId');
    return AvatarState.fromJson(response.data['data']['avatar']);
  }

  /// Purchase an item (returns success message, caller should refresh avatar)
  Future<void> purchaseItem({
    required String childId,
    required String itemId,
  }) async {
    await _apiClient.post(
      '/avatar/$childId/purchase',
      data: {'itemId': itemId},
    );
  }

  /// Equip an item (returns avatar state map, caller should refresh full avatar)
  Future<Map<String, dynamic>> equipItem({
    required String childId,
    required String itemId,
  }) async {
    final response = await _apiClient.post(
      '/avatar/$childId/equip',
      data: {'itemId': itemId},
    );
    return Map<String, dynamic>.from(response.data['data']['avatarState'] ?? {});
  }

  /// Unequip an item by category
  /// Backend expects uppercase type names (HAT, SHIRT, etc.)
  Future<Map<String, dynamic>> unequipItem({
    required String childId,
    required ItemType category,
  }) async {
    const typeKeys = {
      ItemType.hat: 'HAT',
      ItemType.shirt: 'SHIRT',
      ItemType.shoes: 'SHOES',
      ItemType.accessory: 'ACCESSORY',
      ItemType.clubSkin: 'CLUB_SKIN',
    };
    final response = await _apiClient.delete(
      '/avatar/$childId/equip/${typeKeys[category]}',
    );
    return Map<String, dynamic>.from(response.data['data']['avatarState'] ?? {});
  }
}
