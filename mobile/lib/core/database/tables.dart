import 'package:drift/drift.dart';

/// Local cache of children
class LocalChildren extends Table {
  TextColumn get id => text()();
  TextColumn get parentId => text().named('parent_id')();
  TextColumn get name => text()();
  TextColumn get ageBand => text().named('age_band')();
  TextColumn get skillLevel => text().named('skill_level')();
  IntColumn get totalStars => integer().named('total_stars').withDefault(const Constant(0))();
  IntColumn get availableStars => integer().named('available_stars').withDefault(const Constant(0))();
  TextColumn get avatarState => text().named('avatar_state').withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();
  BoolColumn get needsSync => boolean().named('needs_sync').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of drills
class LocalDrills extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get instructions => text()();
  TextColumn get ageBand => text().named('age_band')();
  TextColumn get skillCategory => text().named('skill_category')();
  IntColumn get durationMinutes => integer().named('duration_minutes')();
  TextColumn get equipmentNeeded => text().named('equipment_needed').nullable()();
  TextColumn get videoUrl => text().named('video_url').nullable()();
  TextColumn get imageUrl => text().named('image_url').nullable()();
  BoolColumn get isPremium => boolean().named('is_premium')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of sessions
class LocalSessions extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().named('child_id')();
  TextColumn get status => text()();
  IntColumn get totalStarsEarned => integer().named('total_stars_earned').withDefault(const Constant(0))();
  IntColumn get totalPossibleStars => integer().named('total_possible_stars')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get completedAt => dateTime().named('completed_at').nullable()();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();
  BoolColumn get needsSync => boolean().named('needs_sync').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of session drills
class LocalSessionDrills extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().named('session_id')();
  TextColumn get drillId => text().named('drill_id')();
  IntColumn get orderIndex => integer().named('order_index')();
  BoolColumn get isCompleted => boolean().named('is_completed').withDefault(const Constant(false))();
  IntColumn get starsEarned => integer().named('stars_earned').withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().named('completed_at').nullable()();
  BoolColumn get needsSync => boolean().named('needs_sync').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of avatar items (shop)
class LocalAvatarItems extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().named('image_url').nullable()();
  IntColumn get unlockStars => integer().named('unlock_stars')();
  TextColumn get rarity => text()();
  BoolColumn get isActive => boolean().named('is_active')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of child owned items
class LocalOwnedItems extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().named('child_id')();
  TextColumn get itemId => text().named('item_id')();
  DateTimeColumn get purchasedAt => dateTime().named('purchased_at')();
  BoolColumn get needsSync => boolean().named('needs_sync').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local user settings
class LocalSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get notificationsEnabled => boolean().named('notifications_enabled').withDefault(const Constant(true))();
  TextColumn get dailyReminderTime => text().named('daily_reminder_time').nullable()();
  BoolColumn get soundEnabled => boolean().named('sound_enabled').withDefault(const Constant(true))();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get streakGoal => text().named('streak_goal').withDefault(const Constant('THREE_PER_WEEK'))();
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();
  BoolColumn get needsSync => boolean().named('needs_sync').withDefault(const Constant(false))();
}

/// Sync queue for pending operations
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  IntColumn get retryCount => integer().named('retry_count').withDefault(const Constant(0))();
  TextColumn get lastError => text().named('last_error').nullable()();
}
