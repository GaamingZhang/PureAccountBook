import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/config/app_config.dart';
import '../providers/theme_provider.dart';
import '../features/transaction/providers/transaction_list_provider.dart';
import '../features/category/providers/category_provider.dart';
import '../features/category/models/category.dart';
import '../shared/widgets/widgets.dart';
import '../l10n/app_localizations.dart';

enum TimeRange { week, month, year, custom }

enum ChartDataType { expense, income, net }

enum RankingType { category, dailyExpense, dailyIncome }

final timeRangeProvider = StateProvider<TimeRange>((ref) => TimeRange.month);
final chartDataTypeProvider = StateProvider<ChartDataType>(
  (ref) => ChartDataType.expense,
);
final rankingTypeProvider = StateProvider<RankingType>(
  (ref) => RankingType.category,
);
final customStartDateProvider = StateProvider<DateTime?>((ref) => null);
final customEndDateProvider = StateProvider<DateTime?>((ref) => null);

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: const CommonAppBar(title: '数据统计', showBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _TimeRangeSelector(),
            const SizedBox(height: 16),
            const _SummaryCards(),
            const SizedBox(height: 24),
            const _ChartSection(),
            const SizedBox(height: 24),
            const _RankingSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _TimeRangeSelector extends ConsumerWidget {
  const _TimeRangeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(timeRangeProvider);
    final customStart = ref.watch(customStartDateProvider);
    final customEnd = ref.watch(customEndDateProvider);
    final primaryColor = ref.watch(themeColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: TimeRange.values.map((range) {
              final isSelected = timeRange == range;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (range == TimeRange.custom) {
                      final result = await _showDateRangePicker(context, ref);
                      if (result != null) {
                        ref.read(customStartDateProvider.notifier).state =
                            result.$1;
                        ref.read(customEndDateProvider.notifier).state =
                            result.$2;
                        ref.read(timeRangeProvider.notifier).state = range;
                      }
                    } else {
                      ref.read(timeRangeProvider.notifier).state = range;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      _getLabel(range),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecOf(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (timeRange == TimeRange.custom &&
            customStart != null &&
            customEnd != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${DateFormat('MM/dd').format(customStart)} - ${DateFormat('MM/dd').format(customEnd)}',
              style: TextStyle(
                color: AppColors.textSecOf(context),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  String _getLabel(TimeRange range) {
    switch (range) {
      case TimeRange.week:
        return '周';
      case TimeRange.month:
        return '月';
      case TimeRange.year:
        return '年';
      case TimeRange.custom:
        return '自定义';
    }
  }

  Future<(DateTime, DateTime)?> _showDateRangePicker(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final primaryColor = ref.read(themeColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!context.mounted) return null;

    final start = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: l10n.selectStartDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    surface: AppColors.surfaceDark,
                    onSurface: AppColors.textMainDark,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    surface: AppColors.surfaceLight,
                    onSurface: AppColors.textMainLight,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (start == null) return null;

    if (!context.mounted) return null;

    DateTime? end;
    while (true) {
      end = await showDatePicker(
        context: context,
        initialDate: start,
        firstDate: start,
        lastDate: now,
        helpText: l10n.selectEndDate,
        cancelText: l10n.back,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: isDark
                  ? ColorScheme.dark(
                      primary: primaryColor,
                      surface: AppColors.surfaceDark,
                      onSurface: AppColors.textMainDark,
                    )
                  : ColorScheme.light(
                      primary: primaryColor,
                      surface: AppColors.surfaceLight,
                      onSurface: AppColors.textMainLight,
                    ),
            ),
            child: child!,
          );
        },
      );

      if (end == null) {
        if (!context.mounted) return null;
        final restart = await showDatePicker(
          context: context,
          initialDate: start,
          firstDate: DateTime(2020),
          lastDate: now,
          helpText: l10n.selectStartDate,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? ColorScheme.dark(
                        primary: primaryColor,
                        surface: AppColors.surfaceDark,
                        onSurface: AppColors.textMainDark,
                      )
                    : ColorScheme.light(
                        primary: primaryColor,
                        surface: AppColors.surfaceLight,
                        onSurface: AppColors.textMainLight,
                      ),
              ),
              child: child!,
            );
          },
        );
        if (restart == null) return null;
        continue;
      }

      if (end.isBefore(start)) {
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.startDateAfterEndDate),
            backgroundColor: AppColors.rose,
          ),
        );
        continue;
      }

      break;
    }

    return (start, end);
  }
}

class _SummaryCards extends ConsumerWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(timeRangeProvider);
    final customStart = ref.watch(customStartDateProvider);
    final customEnd = ref.watch(customEndDateProvider);

    final (startDate, endDate) = _getDateRange(
      timeRange,
      customStart,
      customEnd,
    );
    final startMonth = DateFormat('yyyy-MM').format(startDate);

    final transactionsAsync = ref.watch(
      transactionsByMonthProvider(startMonth),
    );

    return transactionsAsync.when(
      data: (transactions) {
        final filtered = _filterByDateRange(transactions, startDate, endDate);
        final summary = _calculateSummary(filtered);

        return Row(
          children: [
            _buildSummaryCard(
              context,
              "总收入",
              "¥${_formatAmount(summary.income)}",
              AppColors.emerald,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              context,
              "总支出",
              "¥${_formatAmount(summary.expense)}",
              AppColors.rose,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              context,
              "净收入",
              "¥${_formatAmount(summary.net)}",
              AppColors.textMainOf(context),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          _buildSummaryCard(context, "总收入", "加载中...", AppColors.emerald),
          const SizedBox(width: 12),
          _buildSummaryCard(context, "总支出", "加载中...", AppColors.rose),
          const SizedBox(width: 12),
          _buildSummaryCard(
            context,
            "净收入",
            "加载中...",
            AppColors.textMainOf(context),
          ),
        ],
      ),
      error: (e, _) => Row(
        children: [
          _buildSummaryCard(context, "总收入", "错误", AppColors.emerald),
          const SizedBox(width: 12),
          _buildSummaryCard(context, "总支出", "错误", AppColors.rose),
          const SizedBox(width: 12),
          _buildSummaryCard(
            context,
            "净收入",
            "错误",
            AppColors.textMainOf(context),
          ),
        ],
      ),
    );
  }

  (DateTime, DateTime) _getDateRange(
    TimeRange timeRange,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final now = DateTime.now();
    switch (timeRange) {
      case TimeRange.week:
        return (now.subtract(const Duration(days: 7)), now);
      case TimeRange.month:
        return (DateTime(now.year, now.month, 1), now);
      case TimeRange.year:
        return (DateTime(now.year, 1, 1), now);
      case TimeRange.custom:
        if (customStart != null && customEnd != null) {
          return (customStart, customEnd);
        }
        return (DateTime(now.year, now.month, 1), now);
    }
  }

  List<dynamic> _filterByDateRange(
    List<dynamic> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate);
    return transactions.where((t) {
      final date = t.date as String;
      return date.compareTo(startStr) >= 0 && date.compareTo(endStr) <= 0;
    }).toList();
  }

  ({double income, double expense, double net}) _calculateSummary(
    List<dynamic> transactions,
  ) {
    double income = 0;
    double expense = 0;
    for (final t in transactions) {
      final amount = (t.amount as num).toDouble();
      if (t.type == 'income') {
        income += amount;
      } else {
        expense += amount;
      }
    }
    return (income: income, expense: expense, net: income - expense);
  }

  String _formatAmount(double amount) {
    if (amount.abs() >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}万';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String amount,
    Color amountColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecOf(context),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                color: amountColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSection extends ConsumerWidget {
  const _ChartSection();

  Color _getChartColor(ChartDataType dataType, Color primaryColor) {
    switch (dataType) {
      case ChartDataType.expense:
        return AppColors.rose;
      case ChartDataType.income:
        return primaryColor;
      case ChartDataType.net:
        return AppColors.emerald;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(timeRangeProvider);
    final dataType = ref.watch(chartDataTypeProvider);
    final customStart = ref.watch(customStartDateProvider);
    final customEnd = ref.watch(customEndDateProvider);
    final primaryColor = ref.watch(themeColorProvider);

    final (startDate, endDate) = _getDateRange(
      timeRange,
      customStart,
      customEnd,
    );
    final startMonth = DateFormat('yyyy-MM').format(startDate);

    final transactionsAsync = ref.watch(
      transactionsByMonthProvider(startMonth),
    );

    return transactionsAsync.when(
      data: (transactions) {
        final filtered = _filterByDateRange(transactions, startDate, endDate);
        final dailyData = _aggregateByDay(filtered, dataType);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "账单趋势 (${_getTrendLabel(timeRange)})",
                    style: TextStyle(
                      color: AppColors.textSecOf(context),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      _buildDataTypeChip(
                        context,
                        ref,
                        ChartDataType.income,
                        "收入",
                        primaryColor,
                      ),
                      const SizedBox(width: 8),
                      _buildDataTypeChip(
                        context,
                        ref,
                        ChartDataType.expense,
                        "支出",
                        AppColors.rose,
                      ),
                      const SizedBox(width: 8),
                      _buildDataTypeChip(
                        context,
                        ref,
                        ChartDataType.net,
                        "净收入",
                        Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: dailyData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 48,
                              color: AppColors.textSecOf(
                                context,
                              ).withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '暂无数据',
                              style: TextStyle(
                                color: AppColors.textSecOf(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _calculateYInterval(dailyData),
                            getDrawingHorizontalLine: (value) {
                              final isDark =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;
                              return FlLine(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                interval: _calculateYInterval(dailyData),
                                getTitlesWidget: (value, meta) {
                                  final maxY = _getMaxY(dailyData);
                                  if ((maxY - value).abs() < 0.01) {
                                    return const SizedBox();
                                  }
                                  return Text(
                                    _formatYAxisValue(value),
                                    style: TextStyle(
                                      color: AppColors.textSecOf(context),
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: _calculateXInterval(dailyData.length),
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= dailyData.length) {
                                    return const SizedBox();
                                  }
                                  if (index == dailyData.length - 1) {
                                    return const SizedBox();
                                  }
                                  final dateLabels = _getDateLabels(
                                    dailyData,
                                    startDate,
                                    endDate,
                                  );
                                  if (index >= dateLabels.length) {
                                    return const SizedBox();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      dateLabels[index],
                                      style: TextStyle(
                                        color: AppColors.textSecOf(context),
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (dailyData.length - 1).toDouble().clamp(
                            0,
                            double.infinity,
                          ),
                          minY: _getMinY(dailyData),
                          maxY: _getMaxY(dailyData),
                          lineBarsData: [
                            LineChartBarData(
                              spots: dailyData.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value);
                              }).toList(),
                              isCurved: true,
                              color: _getChartColor(dataType, primaryColor),
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: _getChartColor(
                                  dataType,
                                  primaryColor,
                                ).withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(height: 180, child: Center(child: Text('加载失败: $e'))),
      ),
    );
  }

  Widget _buildDataTypeChip(
    BuildContext context,
    WidgetRef ref,
    ChartDataType type,
    String label,
    Color color,
  ) {
    final isSelected = ref.watch(chartDataTypeProvider) == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        ref.read(chartDataTypeProvider.notifier).state = type;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecOf(context),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  (DateTime, DateTime) _getDateRange(
    TimeRange timeRange,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final now = DateTime.now();
    switch (timeRange) {
      case TimeRange.week:
        return (now.subtract(const Duration(days: 7)), now);
      case TimeRange.month:
        return (DateTime(now.year, now.month, 1), now);
      case TimeRange.year:
        return (DateTime(now.year, 1, 1), now);
      case TimeRange.custom:
        if (customStart != null && customEnd != null) {
          return (customStart, customEnd);
        }
        return (DateTime(now.year, now.month, 1), now);
    }
  }

  List<dynamic> _filterByDateRange(
    List<dynamic> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate);
    return transactions.where((t) {
      final date = t.date as String;
      return date.compareTo(startStr) >= 0 && date.compareTo(endStr) <= 0;
    }).toList();
  }

  List<double> _aggregateByDay(
    List<dynamic> transactions,
    ChartDataType dataType,
  ) {
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

    final sortedEntries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sortedEntries.map((e) => e.value.abs()).toList();
  }

  double _getMinY(List<double> data) {
    if (data.isEmpty) return 0;
    return 0;
  }

  double _getMaxY(List<double> data) {
    if (data.isEmpty) return 10000;
    final max = data.reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  double _calculateYInterval(List<double> data) {
    if (data.isEmpty) return 2000;
    final max = data.reduce((a, b) => a > b ? a : b);
    if (max <= 100) return 20;
    if (max <= 500) return 100;
    if (max <= 1000) return 200;
    if (max <= 5000) return 1000;
    if (max <= 10000) return 2000;
    if (max <= 50000) return 10000;
    return 20000;
  }

  String _formatYAxisValue(double value) {
    if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(0)}万';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }

  double _calculateXInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    return 7;
  }

  List<String> _getDateLabels(
    List<double> data,
    DateTime startDate,
    DateTime endDate,
  ) {
    final labels = <String>[];
    final interval = _calculateXInterval(data.length);

    for (int i = 0; i < data.length; i++) {
      if (i % interval == 0 || i == data.length - 1) {
        final date = startDate.add(Duration(days: i));
        labels.add('${date.month}/${date.day}');
      } else {
        labels.add('');
      }
    }
    return labels;
  }

  String _getTrendLabel(TimeRange timeRange) {
    switch (timeRange) {
      case TimeRange.week:
        return '本周';
      case TimeRange.month:
        return '本月';
      case TimeRange.year:
        return '本年';
      case TimeRange.custom:
        return '自定义';
    }
  }
}

class _RankingSection extends ConsumerWidget {
  const _RankingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingType = ref.watch(rankingTypeProvider);
    final primaryColor = ref.watch(themeColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.leaderboard, color: primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              "账单排行",
              style: TextStyle(
                color: AppColors.textMainOf(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: RankingType.values.map((type) {
              final isSelected = rankingType == type;
              return Padding(
                padding: EdgeInsets.only(
                  right: type == RankingType.dailyIncome ? 0 : 16,
                ),
                child: GestureDetector(
                  onTap: () {
                    ref.read(rankingTypeProvider.notifier).state = type;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? primaryColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _getRankingLabel(type),
                      style: TextStyle(
                        color: isSelected
                            ? primaryColor
                            : AppColors.textSecOf(context),
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Divider(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          height: 1,
        ),
        const SizedBox(height: 16),
        _RankingList(rankingType: rankingType),
      ],
    );
  }

  String _getRankingLabel(RankingType type) {
    switch (type) {
      case RankingType.category:
        return "类别排行";
      case RankingType.dailyExpense:
        return "日支出排行";
      case RankingType.dailyIncome:
        return "日收入排行";
    }
  }
}

class _RankingList extends ConsumerWidget {
  final RankingType rankingType;

  const _RankingList({required this.rankingType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(timeRangeProvider);
    final customStart = ref.watch(customStartDateProvider);
    final customEnd = ref.watch(customEndDateProvider);

    final (startDate, endDate) = _getDateRange(
      timeRange,
      customStart,
      customEnd,
    );
    final startMonth = DateFormat('yyyy-MM').format(startDate);

    final transactionsAsync = ref.watch(
      transactionsByMonthProvider(startMonth),
    );
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return transactionsAsync.when(
      data: (transactions) {
        final filtered = _filterByDateRange(transactions, startDate, endDate);

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.leaderboard,
                    size: 48,
                    color: AppColors.textSecOf(context).withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '暂无数据',
                    style: TextStyle(color: AppColors.textSecOf(context)),
                  ),
                ],
              ),
            ),
          );
        }

        switch (rankingType) {
          case RankingType.category:
            return categoriesAsync.when(
              data: (categories) =>
                  _buildCategoryRanking(context, filtered, categories),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载分类失败: $e')),
            );
          case RankingType.dailyExpense:
            return _buildDailyRanking(context, filtered, 'expense');
          case RankingType.dailyIncome:
            return _buildDailyRanking(context, filtered, 'income');
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }

  (DateTime, DateTime) _getDateRange(
    TimeRange timeRange,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final now = DateTime.now();
    switch (timeRange) {
      case TimeRange.week:
        return (now.subtract(const Duration(days: 7)), now);
      case TimeRange.month:
        return (DateTime(now.year, now.month, 1), now);
      case TimeRange.year:
        return (DateTime(now.year, 1, 1), now);
      case TimeRange.custom:
        if (customStart != null && customEnd != null) {
          return (customStart, customEnd);
        }
        return (DateTime(now.year, now.month, 1), now);
    }
  }

  List<dynamic> _filterByDateRange(
    List<dynamic> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate);
    return transactions.where((t) {
      final date = t.date as String;
      return date.compareTo(startStr) >= 0 && date.compareTo(endStr) <= 0;
    }).toList();
  }

  Widget _buildCategoryRanking(
    BuildContext context,
    List<dynamic> transactions,
    List<Category> categories,
  ) {
    final categoryTotals = <int, double>{};
    for (final t in transactions) {
      if (t.type == 'expense') {
        final categoryId = t.categoryId as int;
        final amount = (t.amount as num).toDouble();
        categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + amount;
      }
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '暂无支出数据',
            style: TextStyle(color: AppColors.textSecOf(context)),
          ),
        ),
      );
    }

    final maxAmount = sortedCategories.first.value;

    return Column(
      children: sortedCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final categoryId = entry.value.key;
        final amount = entry.value.value;
        final category = categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => Category(
            id: categoryId,
            name: '未知',
            icon: 'help',
            type: 'expense',
          ),
        );
        final percent = amount / maxAmount;

        return _buildRankingItem(
          context,
          index + 1,
          category.name,
          amount,
          percent,
          _getCategoryColor(index),
          _getCategoryIcon(category.icon),
        );
      }).toList(),
    );
  }

  Widget _buildDailyRanking(
    BuildContext context,
    List<dynamic> transactions,
    String type,
  ) {
    final dailyTotals = <String, double>{};
    for (final t in transactions) {
      if (t.type == type) {
        final date = t.date as String;
        final amount = (t.amount as num).toDouble();
        dailyTotals[date] = (dailyTotals[date] ?? 0) + amount;
      }
    }

    final sortedDays = dailyTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedDays.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            type == 'expense' ? '暂无支出数据' : '暂无收入数据',
            style: TextStyle(color: AppColors.textSecOf(context)),
          ),
        ),
      );
    }

    final maxAmount = sortedDays.first.value;
    final topDays = sortedDays.take(10).toList();

    return Column(
      children: topDays.asMap().entries.map((entry) {
        final index = entry.key;
        final date = entry.value.key;
        final amount = entry.value.value;
        final percent = amount / maxAmount;

        return _buildRankingItem(
          context,
          index + 1,
          DateFormat('MM/dd').format(DateTime.parse(date)),
          amount,
          percent,
          type == 'expense' ? AppColors.rose : AppColors.emerald,
          Icons.calendar_today,
        );
      }).toList(),
    );
  }

  Widget _buildRankingItem(
    BuildContext context,
    int rank,
    String name,
    double amount,
    double percent,
    Color color,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: rank <= 3
                        ? Colors.white
                        : isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceOf(context),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "$rank",
                      style: TextStyle(
                        color: rank <= 3
                            ? Colors.black
                            : isDark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textMainOf(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "¥${amount.toStringAsFixed(0)}",
                style: TextStyle(
                  color: AppColors.textMainOf(context),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${(percent * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                  color: AppColors.textSecOf(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    const colors = [
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
      Colors.blueGrey,
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(String iconName) {
    const iconMap = <String, IconData>{
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'directions_car': Icons.directions_car,
      'bolt': Icons.bolt,
      'sports_esports': Icons.sports_esports,
      'home': Icons.home,
      'medical_services': Icons.medical_services,
      'flight': Icons.flight,
      'school': Icons.school,
      'groups': Icons.groups,
      'shopping_cart': Icons.shopping_cart,
      'card_giftcard': Icons.card_giftcard,
      'payments': Icons.payments,
      'account_balance_wallet': Icons.account_balance_wallet,
      'work': Icons.work,
      'savings': Icons.savings,
      'attach_money': Icons.attach_money,
      'help': Icons.help_outline,
    };
    return iconMap[iconName] ?? Icons.help_outline;
  }
}
