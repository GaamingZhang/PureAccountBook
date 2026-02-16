import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../transaction/providers/transaction_list_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../l10n/app_localizations.dart';

enum TimeRange { week, month, threeMonths, year, custom }

enum ChartDataType { expense, income, net }

final timeRangeProvider = StateProvider<TimeRange>((ref) => TimeRange.month);
final chartDataTypeProvider = StateProvider<ChartDataType>(
  (ref) => ChartDataType.expense,
);
final customStartDateProvider = StateProvider<DateTime?>((ref) => null);
final customEndDateProvider = StateProvider<DateTime?>((ref) => null);

class ChartPage extends ConsumerWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(timeRangeProvider);
    final dataType = ref.watch(chartDataTypeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: CommonAppBar(
        title: l10n.chartAnalysis,
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              size: 24,
              color: AppColors.textSecOf(context),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _TimeRangeSelector(),
          _DataTypeSelector(),
          Expanded(
            child: _ChartView(timeRange: timeRange, dataType: dataType),
          ),
        ],
      ),
    );
  }
}

class _TimeRangeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(timeRangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: TimeRange.values.map((range) {
          final isSelected = timeRange == range;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                ref.read(timeRangeProvider.notifier).state = range;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  _getLabel(range, l10n),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecOf(context),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(TimeRange range, AppLocalizations l10n) {
    switch (range) {
      case TimeRange.week:
        return l10n.week;
      case TimeRange.month:
        return l10n.month;
      case TimeRange.threeMonths:
        return l10n.threeMonths;
      case TimeRange.year:
        return l10n.year;
      case TimeRange.custom:
        return l10n.custom;
    }
  }
}

class _DataTypeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataType = ref.watch(chartDataTypeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ChartDataType.values.map((type) {
          final isSelected = dataType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(chartDataTypeProvider.notifier).state = type;
              },
              child: Container(
                margin: EdgeInsets.only(
                  left: type == ChartDataType.expense ? 0 : 8,
                  right: type == ChartDataType.net ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  _getTypeLabel(type, l10n),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecOf(context),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTypeLabel(ChartDataType type, AppLocalizations l10n) {
    switch (type) {
      case ChartDataType.expense:
        return l10n.expense;
      case ChartDataType.income:
        return l10n.income;
      case ChartDataType.net:
        return l10n.netIncome;
    }
  }
}

class _ChartView extends ConsumerWidget {
  final TimeRange timeRange;
  final ChartDataType dataType;

  const _ChartView({required this.timeRange, required this.dataType});

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();
    switch (timeRange) {
      case TimeRange.week:
        return (now.subtract(const Duration(days: 7)), now);
      case TimeRange.month:
        return (DateTime(now.year, now.month - 1, now.day), now);
      case TimeRange.threeMonths:
        return (DateTime(now.year, now.month - 3, now.day), now);
      case TimeRange.year:
        return (DateTime(now.year - 1, now.month, now.day), now);
      case TimeRange.custom:
        return (DateTime(now.year, now.month - 1, now.day), now);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (startDate, endDate) = _getDateRange();
    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final transactionsAsync = ref.watch(
      transactionsByMonthProvider(DateFormat('yyyy-MM').format(startDate)),
    );

    return transactionsAsync.when(
      data: (transactions) {
        final filtered = transactions.where((t) {
          final date = t.date;
          return date.compareTo(startStr) >= 0 && date.compareTo(endStr) <= 0;
        }).toList();

        final dailyData = _aggregateByDay(filtered);

        if (dailyData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 64,
                  color: AppColors.textSecOf(context).withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noData,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecOf(context),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSummaryCard(context, dailyData),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.08),
                    ),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '¥${value.toInt()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecOf(context),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= dailyData.length) {
                                return const SizedBox();
                              }
                              final date = dailyData.keys.elementAt(
                                value.toInt(),
                              );
                              return Text(
                                DateFormat(
                                  'MM/dd',
                                ).format(DateTime.parse(date)),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecOf(context),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1000,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: dailyData.entries.toList().asMap().entries.map(
                        (entry) {
                          final index = entry.key;
                          final data = entry.value.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: data.abs(),
                                color: dataType == ChartDataType.expense
                                    ? const Color(0xFFEF4444)
                                    : dataType == ChartDataType.income
                                    ? const Color(0xFF10B981)
                                    : data >= 0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.loadFailed}: $e')),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    Map<String, double> dailyData,
  ) {
    double total = 0;
    double max = 0;
    for (final value in dailyData.values) {
      total += value.abs();
      if (value.abs() > max) max = value.abs();
    }
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.total,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecOf(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "¥${total.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.maxDaily,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecOf(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "¥${max.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, double> _aggregateByDay(List<dynamic> transactions) {
    final map = <String, double>{};
    for (final t in transactions) {
      final date = t.date as String;
      final amount = (t.amount as num).toDouble();
      final type = t.type as String;

      double value = 0;
      switch (dataType) {
        case ChartDataType.expense:
          if (type == 'expense') value = amount;
          break;
        case ChartDataType.income:
          if (type == 'income') value = amount;
          break;
        case ChartDataType.net:
          value = type == 'income' ? amount : -amount;
          break;
      }

      map[date] = (map[date] ?? 0) + value;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}
