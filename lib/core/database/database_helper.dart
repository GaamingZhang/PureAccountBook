import 'dart:developer' as developer;
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations/migrations.dart';
import 'tables.dart';
import '../../features/category/data/default_categories.dart';

typedef UpgradeProgressCallback = void Function(String message);

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String databaseName = 'account_book.db';
  static const int databaseVersion = 5;

  Database? _database;
  String? _databasePath;
  static UpgradeProgressCallback? _upgradeProgressCallback;

  static void setUpgradeProgressCallback(UpgradeProgressCallback? callback) {
    _upgradeProgressCallback = callback;
  }

  static void _reportProgress(String message) {
    _upgradeProgressCallback?.call(message);
    developer.log(message, name: 'DatabaseHelper');
  }

  Future<bool> needsUpgrade() async {
    final path = await databasePath;
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    try {
      final db = await openDatabase(path, version: 1);
      final result = await db.rawQuery('PRAGMA user_version');
      final currentVersion = result.first['user_version'] as int? ?? 0;
      await db.close();
      return currentVersion < databaseVersion;
    } catch (e) {
      developer.log(
        'Error checking database version: $e',
        name: 'DatabaseHelper',
      );
      return false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get databasePath async {
    if (_databasePath != null) return _databasePath!;
    final dbPath = await getDatabasesPath();
    _databasePath = join(dbPath, databaseName);
    return _databasePath!;
  }

  Future<Database> _initDatabase() async {
    final path = await databasePath;
    developer.log('Database path: $path', name: 'DatabaseHelper');

    try {
      final db = await openDatabase(
        path,
        version: databaseVersion,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onConfigure: onConfigure,
      );
      developer.log('Database opened successfully', name: 'DatabaseHelper');
      return db;
    } catch (e) {
      developer.log(
        'Database init failed: $e, attempting to recreate',
        name: 'DatabaseHelper',
      );
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          developer.log(
            'Deleted corrupted database file',
            name: 'DatabaseHelper',
          );
        }
      } catch (deleteError) {
        developer.log(
          'Error deleting database file: $deleteError',
          name: 'DatabaseHelper',
        );
      }

      final db = await openDatabase(
        path,
        version: databaseVersion,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onConfigure: onConfigure,
      );
      developer.log('Database recreated successfully', name: 'DatabaseHelper');
      return db;
    }
  }

  static Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> onCreate(Database db, int version) async {
    developer.log(
      'Creating database tables for version $version',
      name: 'DatabaseHelper',
    );

    try {
      await db.execute('PRAGMA foreign_keys = ON');

      await db.execute(createCategoriesTable);
      developer.log('Created categories table', name: 'DatabaseHelper');

      await db.execute(createTransactionsTable);
      developer.log('Created transactions table', name: 'DatabaseHelper');

      await db.execute(createBudgetsTable);
      developer.log('Created budgets table', name: 'DatabaseHelper');

      await db.execute(createMonthlyBudgetsTable);
      developer.log('Created monthly_budgets table', name: 'DatabaseHelper');

      await _insertDefaultCategories(db);

      await db.execute('PRAGMA user_version = $databaseVersion');
      developer.log(
        'Database created successfully with version $databaseVersion',
        name: 'DatabaseHelper',
      );
    } catch (e) {
      developer.log('Error creating database: $e', name: 'DatabaseHelper');
      rethrow;
    }
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    final migrationsToRun = allMigrations
        .where((m) => m.version > oldVersion && m.version <= newVersion)
        .toList();

    if (migrationsToRun.isEmpty) return;

    _reportProgress('开始数据库升级 v$oldVersion → v$newVersion');

    try {
      int currentMigration = 0;
      await db.transaction((txn) async {
        for (final migration in migrationsToRun) {
          currentMigration++;
          _reportProgress(
            '执行迁移 ${migration.version} ($currentMigration/${migrationsToRun.length})',
          );
          await migration.up(txn);
        }
      });
      _reportProgress('数据库升级完成');
    } catch (e) {
      _reportProgress('升级失败: $e');
      rethrow;
    }
  }

  static Future<void> _insertDefaultCategories(Database db) async {
    try {
      final batch = db.batch();
      for (final category in DefaultCategories.all) {
        batch.insert(tableCategories, category.toMap());
      }
      await batch.commit(noResult: true);
      developer.log(
        'Inserted ${DefaultCategories.totalCount} default categories',
        name: 'DatabaseHelper',
      );
    } catch (e) {
      developer.log(
        'Error inserting default categories: $e',
        name: 'DatabaseHelper',
      );
      rethrow;
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<int> getDatabaseVersion() async {
    final db = await database;
    final result = await db.rawQuery('PRAGMA user_version');
    return result.first['user_version'] as int? ?? 0;
  }

  Future<bool> hasDefaultCategories() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM $tableCategories WHERE is_default = 1',
    );
    final count = (result.first['cnt'] as int?) ?? 0;
    return count > 0;
  }

  Future<void> ensureDefaultCategories() async {
    if (!await hasDefaultCategories()) {
      final db = await database;
      await _insertDefaultCategories(db);
    }
  }
}
