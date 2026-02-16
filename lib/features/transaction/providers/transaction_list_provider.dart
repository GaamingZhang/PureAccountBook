import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import 'transaction_provider.dart';

final transactionRefreshProvider = StateProvider<int>((ref) => 0);

final transactionsProvider = FutureProvider<List<TransactionRecord>>((ref) async {
  ref.watch(transactionRefreshProvider);
  final repo = await ref.watch(transactionRepositoryProvider.future);
  return repo.findAll();
});

final transactionsByDateProvider = FutureProvider.family<List<TransactionRecord>, String>((ref, date) async {
  ref.watch(transactionRefreshProvider);
  final repo = await ref.watch(transactionRepositoryProvider.future);
  return repo.findByDateRange(startDate: date, endDate: date);
});

final transactionsByMonthProvider = FutureProvider.family<List<TransactionRecord>, String>((ref, month) async {
  ref.watch(transactionRefreshProvider);
  final repo = await ref.watch(transactionRepositoryProvider.future);
  final startDate = '$month-01';
  final endDate = '$month-31';
  return repo.findByDateRange(startDate: startDate, endDate: endDate);
});
