import 'package:sqflite/sqflite.dart';

abstract class Migration {
  final int version;
  final String description;

  Migration({required this.version, required this.description});

  Future<void> up(DatabaseExecutor db);

  Future<void> down(DatabaseExecutor db);
}

typedef MigrationCallback = Future<void> Function(DatabaseExecutor db);
