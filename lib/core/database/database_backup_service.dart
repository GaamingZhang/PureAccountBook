import 'dart:developer' as developer;
import 'dart:io';
import 'package:sqflite/sqflite.dart';

class DatabaseBackupService {
  static const String backupExtension = '.bak';

  static void _log(String message, {bool isError = false}) {
    developer.log(message, name: 'DatabaseBackup', level: isError ? 1000 : 800);
  }

  static String getBackupPath(String dbPath) => '$dbPath$backupExtension';

  static Future<bool> backupExists(String dbPath) async {
    final backupPath = getBackupPath(dbPath);
    final file = File(backupPath);
    return await file.exists();
  }

  static Future<bool> createBackup(String dbPath) async {
    try {
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        _log('Database file does not exist: $dbPath', isError: true);
        return false;
      }

      final backupPath = getBackupPath(dbPath);
      final backupFile = File(backupPath);

      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      await dbFile.copy(backupPath);
      _log('Database backup created: $backupPath');
      return true;
    } catch (e) {
      _log('Failed to create database backup: $e', isError: true);
      return false;
    }
  }

  static Future<bool> restoreBackup(String dbPath) async {
    try {
      final backupPath = getBackupPath(dbPath);
      final backupFile = File(backupPath);

      if (!await backupFile.exists()) {
        _log('Backup file does not exist: $backupPath', isError: true);
        return false;
      }

      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      await backupFile.copy(dbPath);
      _log('Database restored from backup: $backupPath');
      return true;
    } catch (e) {
      _log('Failed to restore database from backup: $e', isError: true);
      return false;
    }
  }

  static Future<bool> deleteBackup(String dbPath) async {
    try {
      final backupPath = getBackupPath(dbPath);
      final backupFile = File(backupPath);

      if (await backupFile.exists()) {
        await backupFile.delete();
        _log('Database backup deleted: $backupPath');
      }
      return true;
    } catch (e) {
      _log('Failed to delete database backup: $e', isError: true);
      return false;
    }
  }

  static Future<Map<String, int>> getTableCounts(Database db) async {
    final counts = <String, int>{};
    final tables = ['categories', 'transactions', 'budgets', 'monthly_budgets'];

    for (final table in tables) {
      try {
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $table',
        );
        counts[table] = result.first['count'] as int? ?? 0;
      } catch (e) {
        _log('Failed to get count for table $table: $e', isError: true);
        counts[table] = -1;
      }
    }

    return counts;
  }

  static Future<bool> verifyIntegrity(Database db) async {
    try {
      final result = await db.rawQuery('PRAGMA integrity_check');
      final status = result.first['integrity_check'] as String?;
      if (status != 'ok') {
        _log('Database integrity check failed: $status', isError: true);
        return false;
      }
      _log('Database integrity check passed');
      return true;
    } catch (e) {
      _log('Failed to verify database integrity: $e', isError: true);
      return false;
    }
  }

  static Future<bool> verifyForeignKeys(Database db) async {
    try {
      final result = await db.rawQuery('PRAGMA foreign_key_check');
      if (result.isNotEmpty) {
        _log(
          'Foreign key check failed: ${result.length} violations',
          isError: true,
        );
        return false;
      }
      _log('Foreign key check passed');
      return true;
    } catch (e) {
      _log('Failed to verify foreign keys: $e', isError: true);
      return false;
    }
  }

  static bool compareTableCounts(
    Map<String, int> before,
    Map<String, int> after,
  ) {
    bool allMatch = true;
    for (final table in before.keys) {
      final beforeCount = before[table] ?? 0;
      final afterCount = after[table] ?? 0;
      if (beforeCount != afterCount) {
        _log(
          'Table $table count mismatch: before=$beforeCount, after=$afterCount',
          isError: true,
        );
        allMatch = false;
      }
    }
    return allMatch;
  }
}
