import 'package:drift/drift.dart';

part 'app_database.g.dart';

// ─── Tables ───

class CleaningSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  TextColumn get status => text()();
  IntColumn get totalPhotos => integer()();
  IntColumn get reviewedCount => integer().withDefault(const Constant(0))();
  TextColumn get filterJson => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CleaningDecisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().references(CleaningSessions, #id)();
  TextColumn get photoId => text()();
  TextColumn get type => text()();
  DateTimeColumn get decidedAt => dateTime()();
}

class TrashItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get photoId => text()();
  TextColumn get sessionId => text().nullable()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  DateTimeColumn get trashedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();
}

class CleaningStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().references(CleaningSessions, #id)();
  IntColumn get photosReviewed => integer().withDefault(const Constant(0))();
  IntColumn get photosDeleted => integer().withDefault(const Constant(0))();
  IntColumn get photosKept => integer().withDefault(const Constant(0))();
  IntColumn get photosFavorited => integer().withDefault(const Constant(0))();
  IntColumn get bytesFreed => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime()();
}

class UserPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ─── Database ───

@DriftDatabase(
  tables: [
    CleaningSessions,
    CleaningDecisions,
    TrashItems,
    CleaningStats,
    UserPreferences,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
