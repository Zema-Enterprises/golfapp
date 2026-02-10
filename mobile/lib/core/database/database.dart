import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  LocalChildren,
  LocalDrills,
  LocalSessions,
  LocalSessionDrills,
  LocalAvatarItems,
  LocalOwnedItems,
  LocalSettings,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here
      },
    );
  }

  // ============================================
  // Children Operations
  // ============================================

  Future<List<LocalChildrenData>> getAllChildren() {
    return select(localChildren).get();
  }

  Stream<List<LocalChildrenData>> watchAllChildren() {
    return select(localChildren).watch();
  }

  Future<LocalChildrenData?> getChildById(String id) {
    return (select(localChildren)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertChild(LocalChildrenCompanion child) {
    return into(localChildren).insert(child, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteChild(String id) {
    return (delete(localChildren)..where((t) => t.id.equals(id))).go();
  }

  // ============================================
  // Drills Operations
  // ============================================

  Future<List<LocalDrill>> getAllDrills() {
    return select(localDrills).get();
  }

  Future<List<LocalDrill>> getDrillsByAgeBand(String ageBand) {
    return (select(localDrills)..where((t) => t.ageBand.equals(ageBand))).get();
  }

  Future<LocalDrill?> getDrillById(String id) {
    return (select(localDrills)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertDrill(LocalDrillsCompanion drill) {
    return into(localDrills).insert(drill, mode: InsertMode.insertOrReplace);
  }

  Future<void> insertDrills(List<LocalDrillsCompanion> drills) async {
    await batch((b) {
      b.insertAll(localDrills, drills, mode: InsertMode.insertOrReplace);
    });
  }

  // ============================================
  // Sessions Operations
  // ============================================

  Future<List<LocalSession>> getSessionsByChildId(String childId) {
    return (select(localSessions)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<LocalSession?> getInProgressSession(String childId) {
    return (select(localSessions)
          ..where((t) => t.childId.equals(childId) & t.status.equals('IN_PROGRESS')))
        .getSingleOrNull();
  }

  Future<LocalSession?> getSessionById(String id) {
    return (select(localSessions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertSession(LocalSessionsCompanion session) {
    return into(localSessions).insert(session, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateSessionStatus(String id, String status, {DateTime? completedAt, int? totalStarsEarned}) {
    return (update(localSessions)..where((t) => t.id.equals(id))).write(
      LocalSessionsCompanion(
        status: Value(status),
        completedAt: completedAt != null ? Value(completedAt) : const Value.absent(),
        totalStarsEarned: totalStarsEarned != null ? Value(totalStarsEarned) : const Value.absent(),
        needsSync: const Value(true),
      ),
    );
  }

  // ============================================
  // Session Drills Operations
  // ============================================

  Future<List<LocalSessionDrill>> getSessionDrills(String sessionId) {
    return (select(localSessionDrills)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  Future<int> insertSessionDrill(LocalSessionDrillsCompanion drill) {
    return into(localSessionDrills).insert(drill, mode: InsertMode.insertOrReplace);
  }

  Future<void> insertSessionDrills(List<LocalSessionDrillsCompanion> drills) async {
    await batch((b) {
      b.insertAll(localSessionDrills, drills, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> completeDrill(String id, int starsEarned) {
    return (update(localSessionDrills)..where((t) => t.id.equals(id))).write(
      LocalSessionDrillsCompanion(
        isCompleted: const Value(true),
        starsEarned: Value(starsEarned),
        completedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  // ============================================
  // Avatar Items Operations
  // ============================================

  Future<List<LocalAvatarItem>> getAllAvatarItems() {
    return select(localAvatarItems).get();
  }

  Future<void> insertAvatarItems(List<LocalAvatarItemsCompanion> items) async {
    await batch((b) {
      b.insertAll(localAvatarItems, items, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<LocalOwnedItem>> getOwnedItems(String childId) {
    return (select(localOwnedItems)..where((t) => t.childId.equals(childId))).get();
  }

  Future<int> insertOwnedItem(LocalOwnedItemsCompanion item) {
    return into(localOwnedItems).insert(item, mode: InsertMode.insertOrReplace);
  }

  // ============================================
  // Settings Operations
  // ============================================

  Future<LocalSetting?> getSettings() {
    return (select(localSettings)..limit(1)).getSingleOrNull();
  }

  Future<int> saveSettings(LocalSettingsCompanion settings) {
    return into(localSettings).insert(
      settings.copyWith(id: const Value(1)),
      mode: InsertMode.insertOrReplace,
    );
  }

  // ============================================
  // Sync Queue Operations
  // ============================================

  Future<List<SyncQueueData>> getPendingSyncItems() {
    return (select(syncQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(50))
        .get();
  }

  Future<int> addToSyncQueue(SyncQueueCompanion item) {
    return into(syncQueue).insert(item);
  }

  Future<int> removeSyncItem(int id) {
    return (delete(syncQueue)..where((t) => t.id.equals(id))).go();
  }

  Future<void> incrementRetryCount(int id, String error) async {
    final item = await (select(syncQueue)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (item != null) {
      await (update(syncQueue)..where((t) => t.id.equals(id))).write(
        SyncQueueCompanion(
          retryCount: Value(item.retryCount + 1),
          lastError: Value(error),
        ),
      );
    }
  }

  // ============================================
  // Utility
  // ============================================

  Future<void> clearAllData() async {
    await delete(localChildren).go();
    await delete(localDrills).go();
    await delete(localSessions).go();
    await delete(localSessionDrills).go();
    await delete(localAvatarItems).go();
    await delete(localOwnedItems).go();
    await delete(localSettings).go();
    await delete(syncQueue).go();
  }

  Future<int> getUnsyncedCount() async {
    final children = await (select(localChildren)..where((t) => t.needsSync.equals(true))).get();
    final sessions = await (select(localSessions)..where((t) => t.needsSync.equals(true))).get();
    final drills = await (select(localSessionDrills)..where((t) => t.needsSync.equals(true))).get();
    final items = await (select(localOwnedItems)..where((t) => t.needsSync.equals(true))).get();
    final settings = await (select(localSettings)..where((t) => t.needsSync.equals(true))).get();
    return children.length + sessions.length + drills.length + items.length + settings.length;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'junior_golf_playbook.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
