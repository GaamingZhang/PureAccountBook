import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/theme_provider.dart';
import '../providers/monthly_budget_provider.dart';

class AddBudgetPage extends ConsumerStatefulWidget {
  final DateTime month;
  final double? initialAmount;

  const AddBudgetPage({super.key, required this.month, this.initialAmount});

  @override
  ConsumerState<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends ConsumerState<AddBudgetPage> {
  String _amount = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amount = widget.initialAmount!.toStringAsFixed(0);
    }
  }

  void _handleKeyPress(String key) {
    setState(() {
      if (key == 'backspace') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (key == '.') {
        if (!_amount.contains('.')) {
          _amount += key;
        }
      } else {
        if (_amount.length < 10) {
          _amount += key;
        }
      }
    });
  }

  Future<void> _saveBudget() async {
    if (_amount.isEmpty ||
        double.tryParse(_amount) == null ||
        double.parse(_amount) <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效金额')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(monthlyBudgetProvider.notifier)
          .setBudget(double.parse(_amount));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBudget() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceOf(dialogContext),
        title: Text(
          '清除预算',
          style: TextStyle(color: AppColors.textMainOf(dialogContext)),
        ),
        content: Text(
          '确定要清除本月预算吗？',
          style: TextStyle(color: AppColors.textSecOf(dialogContext)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              '取消',
              style: TextStyle(color: AppColors.textSecOf(dialogContext)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确定', style: TextStyle(color: AppColors.rose)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(monthlyBudgetProvider.notifier).deleteBudget();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthText = '${widget.month.year}年${widget.month.month}月';
    final isEditing = widget.initialAmount != null && widget.initialAmount! > 0;
    final primaryColor = ref.watch(themeColorProvider);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecOf(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecOf(context),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      isEditing ? '编辑预算' : '设置预算',
                      style: TextStyle(
                        color: AppColors.textMainOf(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  monthText,
                  style: TextStyle(
                    color: AppColors.textSecOf(context),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "预算金额",
                style: TextStyle(
                  color: AppColors.textSecOf(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "¥",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _amount.isEmpty ? '0' : _amount,
                    style: TextStyle(
                      color: _amount.isEmpty
                          ? AppColors.textSecOf(context).withValues(alpha: 0.5)
                          : AppColors.textMainOf(context),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOf(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider(context)),
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    ...['1', '2', '3'].map(_buildKey),
                    _buildIconKey(Icons.backspace, AppColors.rose, 'backspace'),
                    ...['4', '5', '6'].map(_buildKey),
                    if (isEditing)
                      _buildTextKey('清除', AppColors.rose, _deleteBudget)
                    else
                      const SizedBox(),
                    ...['7', '8', '9'].map(_buildKey),
                    _buildKey('.'),
                    const SizedBox(),
                    _buildKey('0'),
                    GestureDetector(
                      onTap: _isLoading ? null : _saveBudget,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "确认",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String label) {
    return GestureDetector(
      onTap: () => _handleKeyPress(label),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textMainOf(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIconKey(IconData icon, Color color, String action) {
    return GestureDetector(
      onTap: () => _handleKeyPress(action),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildTextKey(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundOf(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

Future<bool?> showAddBudgetPage(
  BuildContext context,
  DateTime month, {
  double? initialAmount,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AddBudgetPage(month: month, initialAmount: initialAmount),
  );
}
