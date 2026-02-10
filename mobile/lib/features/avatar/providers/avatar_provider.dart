import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../data/avatar_data.dart';

/// Avatar repository provider
final avatarRepositoryProvider = Provider<AvatarRepository>((ref) {
  return AvatarRepository(apiClient: ref.watch(apiClientProvider));
});

/// Shop data provider
final shopDataProvider = FutureProvider<ShopData>((ref) async {
  final repository = ref.watch(avatarRepositoryProvider);
  return repository.getShop();
});

/// Avatar state for a child
class AvatarStateData {
  final AvatarState? avatarState;
  final bool isLoading;
  final String? error;

  const AvatarStateData({
    this.avatarState,
    this.isLoading = false,
    this.error,
  });

  AvatarStateData copyWith({
    AvatarState? avatarState,
    bool? isLoading,
    String? error,
  }) {
    return AvatarStateData(
      avatarState: avatarState ?? this.avatarState,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Avatar state notifier
class AvatarNotifier extends StateNotifier<AvatarStateData> {
  final AvatarRepository _repository;

  AvatarNotifier({required AvatarRepository repository})
      : _repository = repository,
        super(const AvatarStateData());

  /// Load avatar state for child
  Future<void> loadAvatar(String childId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final avatarState = await _repository.getAvatar(childId);
      state = state.copyWith(
        avatarState: avatarState,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load avatar');
    }
  }

  /// Purchase an item
  Future<bool> purchaseItem({
    required String childId,
    required String itemId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.purchaseItem(childId: childId, itemId: itemId);
      // Reload avatar state
      await loadAvatar(childId);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to purchase item');
      return false;
    }
  }

  /// Equip an item
  Future<bool> equipItem({
    required String childId,
    required String itemId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.equipItem(childId: childId, itemId: itemId);
      // Reload full avatar state
      await loadAvatar(childId);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to equip item');
      return false;
    }
  }

  /// Unequip an item
  Future<bool> unequipItem({
    required String childId,
    required ItemType category,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.unequipItem(childId: childId, category: category);
      // Reload full avatar state
      await loadAvatar(childId);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to unequip item');
      return false;
    }
  }

  /// Clear state
  void clear() {
    state = const AvatarStateData();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Avatar state provider
final avatarProvider =
    StateNotifierProvider<AvatarNotifier, AvatarStateData>((ref) {
  return AvatarNotifier(repository: ref.watch(avatarRepositoryProvider));
});

/// Child avatar provider (convenience)
final childAvatarProvider = FutureProvider.family<AvatarState, String>(
  (ref, childId) async {
    final repository = ref.watch(avatarRepositoryProvider);
    return repository.getAvatar(childId);
  },
);
