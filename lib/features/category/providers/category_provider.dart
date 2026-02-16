import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

final databaseProvider = FutureProvider<Database>((ref) async {
  return DatabaseHelper.instance.database;
});

final categoryRepositoryProvider = FutureProvider<CategoryRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return CategoryRepository(db);
});

final expenseCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = await ref.watch(categoryRepositoryProvider.future);
  return repo.findAll(type: 'expense');
});

final incomeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = await ref.watch(categoryRepositoryProvider.future);
  return repo.findAll(type: 'income');
});
