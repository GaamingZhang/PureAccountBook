import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../../category/providers/category_provider.dart';

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<void>>((ref) {
  return CategoryNotifier(ref);
});

class CategoryNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  CategoryNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<int> addCategory(Category category) async {
    state = const AsyncValue.loading();
    try {
      final repo = await _ref.read(categoryRepositoryProvider.future);
      final id = await repo.insert(category);
      state = const AsyncValue.data(null);
      _ref.invalidate(expenseCategoriesProvider);
      _ref.invalidate(incomeCategoriesProvider);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    state = const AsyncValue.loading();
    try {
      final repo = await _ref.read(categoryRepositoryProvider.future);
      await repo.update(category);
      state = const AsyncValue.data(null);
      _ref.invalidate(expenseCategoriesProvider);
      _ref.invalidate(incomeCategoriesProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    state = const AsyncValue.loading();
    try {
      final repo = await _ref.read(categoryRepositoryProvider.future);
      await repo.delete(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(expenseCategoriesProvider);
      _ref.invalidate(incomeCategoriesProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
