import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_exceptions.dart';
import '../database/database.dart';
import '../config/constants.dart';

/// Sync status
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
  offline,
}

/// Sync state
class SyncState {
  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncAt;
  final String? error;

  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingCount = 0,
    this.lastSyncAt,
    this.error,
  });

  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    DateTime? lastSyncAt,
    String? error,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      error: error,
    );
  }

  bool get isOnline => status != SyncStatus.offline;
  bool get isSyncing => status == SyncStatus.syncing;
  bool get hasPendingItems => pendingCount > 0;
}

/// Sync service for offline-first data management
class SyncService extends StateNotifier<SyncState> {
  final AppDatabase _db;
  final ApiClient _apiClient;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _autoSyncTimer;

  static const _maxOfflineDays = AppConstants.maxOfflineDays;
  static const _autoSyncInterval = Duration(minutes: 5);
  static const _maxRetries = 3;

  SyncService({
    required AppDatabase db,
    required ApiClient apiClient,
    Connectivity? connectivity,
  })  : _db = db,
        _apiClient = apiClient,
        _connectivity = connectivity ?? Connectivity(),
        super(const SyncState()) {
    _init();
  }

  void _init() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );

    // Check initial connectivity
    _checkConnectivity();

    // Start auto-sync timer
    _autoSyncTimer = Timer.periodic(_autoSyncInterval, (_) => syncIfNeeded());

    // Update pending count
    _updatePendingCount();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _autoSyncTimer?.cancel();
    super.dispose();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);

    if (hasConnection) {
      state = state.copyWith(status: SyncStatus.idle);
      syncIfNeeded();
    } else {
      state = state.copyWith(status: SyncStatus.offline);
    }
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);
  }

  Future<void> _updatePendingCount() async {
    final count = await _db.getUnsyncedCount();
    state = state.copyWith(pendingCount: count);
  }

  /// Sync if needed (called periodically and on connectivity change)
  Future<void> syncIfNeeded() async {
    if (state.status == SyncStatus.offline || state.status == SyncStatus.syncing) {
      return;
    }

    await _updatePendingCount();
    if (state.pendingCount > 0) {
      await sync();
    }
  }

  /// Perform full sync
  Future<bool> sync() async {
    if (state.status == SyncStatus.offline) {
      return false;
    }

    state = state.copyWith(status: SyncStatus.syncing, error: null);

    try {
      // Process sync queue
      await _processSyncQueue();

      // Sync data from server
      await _syncFromServer();

      state = state.copyWith(
        status: SyncStatus.synced,
        lastSyncAt: DateTime.now(),
        pendingCount: 0,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Sync failed: $e',
      );
      return false;
    }
  }

  /// Process pending items in sync queue
  Future<void> _processSyncQueue() async {
    final items = await _db.getPendingSyncItems();

    for (final item in items) {
      if (item.retryCount >= _maxRetries) {
        // Skip items that have exceeded max retries
        continue;
      }

      try {
        await _processQueueItem(item);
        await _db.removeSyncItem(item.id);
      } catch (e) {
        await _db.incrementRetryCount(item.id, e.toString());
      }
    }
  }

  Future<void> _processQueueItem(SyncQueueData item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.entityType) {
      case 'session':
        await _syncSession(item.entityId, item.operation, payload);
        break;
      case 'session_drill':
        await _syncSessionDrill(item.entityId, item.operation, payload);
        break;
      case 'owned_item':
        await _syncOwnedItem(item.entityId, item.operation, payload);
        break;
      case 'settings':
        await _syncSettings(item.operation, payload);
        break;
    }
  }

  Future<void> _syncSession(String id, String operation, Map<String, dynamic> payload) async {
    if (operation == 'complete') {
      await _apiClient.post('/sessions/$id/complete');
    }
  }

  Future<void> _syncSessionDrill(String id, String operation, Map<String, dynamic> payload) async {
    if (operation == 'complete') {
      final sessionId = payload['sessionId'];
      final drillId = payload['drillId'];
      final starsEarned = payload['starsEarned'];
      await _apiClient.patch(
        '/sessions/$sessionId/drills/$drillId',
        data: {'starsEarned': starsEarned},
      );
    }
  }

  Future<void> _syncOwnedItem(String id, String operation, Map<String, dynamic> payload) async {
    if (operation == 'purchase') {
      final childId = payload['childId'];
      final itemId = payload['itemId'];
      await _apiClient.post(
        '/avatar/$childId/purchase',
        data: {'itemId': itemId},
      );
    }
  }

  Future<void> _syncSettings(String operation, Map<String, dynamic> payload) async {
    if (operation == 'update') {
      await _apiClient.patch('/settings', data: payload);
    }
  }

  /// Sync data from server to local database
  Future<void> _syncFromServer() async {
    // Sync drills (read-only from server)
    await _syncDrillsFromServer();

    // Sync avatar items (read-only from server)
    await _syncAvatarItemsFromServer();

    // Children are synced via normal API calls
    // Sessions are created locally and synced to server
  }

  Future<void> _syncDrillsFromServer() async {
    try {
      final response = await _apiClient.get('/drills', queryParameters: {'limit': 100});
      final data = response.data['data'];
      final drillsList = data['drills'] as List;

      final companions = drillsList.map((json) {
        return LocalDrillsCompanion(
          id: Value(json['id'] as String),
          name: Value(json['name'] as String),
          description: Value(json['description'] as String),
          instructions: Value(json['instructions'] as String),
          ageBand: Value(json['ageBand'] as String),
          skillCategory: Value(json['skillCategory'] as String),
          durationMinutes: Value(json['durationMinutes'] as int),
          equipmentNeeded: Value(json['equipmentNeeded'] as String?),
          videoUrl: Value(json['videoUrl'] as String?),
          imageUrl: Value(json['imageUrl'] as String?),
          isPremium: Value(json['isPremium'] as bool),
          createdAt: Value(DateTime.parse(json['createdAt'] as String)),
          updatedAt: Value(DateTime.parse(json['updatedAt'] as String)),
          syncedAt: Value(DateTime.now()),
        );
      }).toList();

      await _db.insertDrills(companions);
    } catch (_) {
      // Drills sync is optional, don't fail the whole sync
    }
  }

  Future<void> _syncAvatarItemsFromServer() async {
    try {
      final response = await _apiClient.get('/avatar/shop');
      final data = response.data['data'];
      final itemsList = data['items'] as List;

      final companions = itemsList.map((json) {
        return LocalAvatarItemsCompanion(
          id: Value(json['id'] as String),
          type: Value(json['type'] as String),
          name: Value(json['name'] as String),
          imageUrl: Value(json['imageUrl'] as String?),
          unlockStars: Value(json['unlockStars'] as int),
          rarity: Value(json['rarity'] as String),
          isActive: Value(json['isActive'] as bool),
          createdAt: Value(DateTime.parse(json['createdAt'] as String)),
          syncedAt: Value(DateTime.now()),
        );
      }).toList();

      await _db.insertAvatarItems(companions);
    } catch (_) {
      // Avatar items sync is optional, don't fail the whole sync
    }
  }

  // ============================================
  // Queue Operations (called from other services)
  // ============================================

  /// Queue a session completion for sync
  Future<void> queueSessionComplete(String sessionId) async {
    await _db.addToSyncQueue(SyncQueueCompanion(
      entityType: const Value('session'),
      entityId: Value(sessionId),
      operation: const Value('complete'),
      payload: const Value('{}'),
      createdAt: Value(DateTime.now()),
    ));
    await _updatePendingCount();
  }

  /// Queue a drill completion for sync
  Future<void> queueDrillComplete({
    required String sessionId,
    required String drillId,
    required int starsEarned,
  }) async {
    await _db.addToSyncQueue(SyncQueueCompanion(
      entityType: const Value('session_drill'),
      entityId: Value('$sessionId-$drillId'),
      operation: const Value('complete'),
      payload: Value(jsonEncode({
        'sessionId': sessionId,
        'drillId': drillId,
        'starsEarned': starsEarned,
      })),
      createdAt: Value(DateTime.now()),
    ));
    await _updatePendingCount();
  }

  /// Queue a purchase for sync
  Future<void> queuePurchase({
    required String childId,
    required String itemId,
  }) async {
    await _db.addToSyncQueue(SyncQueueCompanion(
      entityType: const Value('owned_item'),
      entityId: Value('$childId-$itemId'),
      operation: const Value('purchase'),
      payload: Value(jsonEncode({
        'childId': childId,
        'itemId': itemId,
      })),
      createdAt: Value(DateTime.now()),
    ));
    await _updatePendingCount();
  }

  /// Queue settings update for sync
  Future<void> queueSettingsUpdate(Map<String, dynamic> settings) async {
    await _db.addToSyncQueue(SyncQueueCompanion(
      entityType: const Value('settings'),
      entityId: const Value('user'),
      operation: const Value('update'),
      payload: Value(jsonEncode(settings)),
      createdAt: Value(DateTime.now()),
    ));
    await _updatePendingCount();
  }

  /// Check if data is stale (offline too long)
  Future<bool> isDataStale() async {
    final settings = await _db.getSettings();
    if (settings?.syncedAt == null) {
      return false; // Never synced, not stale yet
    }

    final daysSinceSync = DateTime.now().difference(settings!.syncedAt!).inDays;
    return daysSinceSync > _maxOfflineDays;
  }

  /// Force refresh all data from server
  Future<void> forceRefresh() async {
    if (state.status == SyncStatus.offline) {
      throw Exception('Cannot refresh while offline');
    }

    state = state.copyWith(status: SyncStatus.syncing);

    try {
      await _syncFromServer();
      state = state.copyWith(
        status: SyncStatus.synced,
        lastSyncAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Refresh failed: $e',
      );
      rethrow;
    }
  }
}

/// Sync service provider
final syncServiceProvider = StateNotifierProvider<SyncService, SyncState>((ref) {
  return SyncService(
    db: ref.watch(databaseProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

/// Convenience providers
final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(syncServiceProvider).isSyncing;
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(syncServiceProvider).isOnline;
});

final pendingSyncCountProvider = Provider<int>((ref) {
  return ref.watch(syncServiceProvider).pendingCount;
});
