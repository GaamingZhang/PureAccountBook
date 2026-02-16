import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../providers/category_notifier_provider.dart';
import '../providers/category_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/theme_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/localization_utils.dart';

class CategoryManagePage extends ConsumerStatefulWidget {
  const CategoryManagePage({super.key});

  @override
  ConsumerState<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends ConsumerState<CategoryManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(themeColorProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOf(context).withValues(alpha: 0.9),
        elevation: 0,
        title: Text(
          l10n.categoryManage,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecOf(context),
              tabs: [
                Tab(text: l10n.expenseCategory),
                Tab(text: l10n.incomeCategory),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CategoryList(type: 'expense'),
          _CategoryList(type: 'income'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final type = _tabController.index == 0 ? 'expense' : 'income';
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => AddCategoryPage(type: type),
            ),
          );
          if (result == true) {
            ref.invalidate(expenseCategoriesProvider);
            ref.invalidate(incomeCategoriesProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final String type;

  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = type == 'expense'
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);
    final l10n = AppLocalizations.of(context)!;

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(child: Text(l10n.noCategories));
        }

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryListTile(category: category);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.loadFailed}: $e')),
    );
  }
}

class _CategoryListTile extends ConsumerWidget {
  final Category category;

  const _CategoryListTile({required this.category});

  IconData _getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'directions_bus': Icons.directions_bus,
      'home': Icons.home,
      'sports_esports': Icons.sports_esports,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'phone': Icons.phone,
      'checkroom': Icons.checkroom,
      'face': Icons.face,
      'apartment': Icons.apartment,
      'more_horiz': Icons.more_horiz,
      'account_balance_wallet': Icons.account_balance_wallet,
      'card_giftcard': Icons.card_giftcard,
      'trending_up': Icons.trending_up,
      'work': Icons.work,
      'receipt': Icons.receipt,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteCategory),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Dismissible(
      key: Key('category_${category.id}'),
      direction: category.isDefault
          ? DismissDirection.none
          : DismissDirection.endToStart,
      confirmDismiss: category.isDefault
          ? null
          : (direction) => _confirmDelete(context),
      onDismissed: category.isDefault
          ? null
          : (direction) async {
              await ref
                  .read(categoryNotifierProvider.notifier)
                  .deleteCategory(category.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.categoryDeleted)));
              }
            },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Icon(_getIconData(category.icon))),
        title: Text(
          LocalizationUtils.getLocalizedCategoryName(context, category),
        ),
        subtitle: category.isDefault ? Text(l10n.defaultCategory) : null,
        trailing: category.isDefault
            ? null
            : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (context) =>
                          EditCategoryPage(category: category),
                    ),
                  );
                  if (result == true) {
                    ref.invalidate(expenseCategoriesProvider);
                    ref.invalidate(incomeCategoriesProvider);
                  }
                },
              ),
      ),
    );
  }
}

class AddCategoryPage extends ConsumerStatefulWidget {
  final String type;

  const AddCategoryPage({super.key, required this.type});

  @override
  ConsumerState<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends ConsumerState<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = 'category';
  bool _isLoading = false;

  final List<String> _availableIcons = [
    'restaurant',
    'shopping_bag',
    'directions_bus',
    'home',
    'sports_esports',
    'local_hospital',
    'school',
    'phone',
    'checkroom',
    'face',
    'apartment',
    'more_horiz',
    'account_balance_wallet',
    'card_giftcard',
    'trending_up',
    'work',
    'receipt',
    'category',
    'star',
    'favorite',
    'book',
    'movie',
    'music_note',
    'flight',
    'hotel',
    'pets',
    'child_care',
    'fitness_center',
    'smoking_rooms',
    'wine_bar',
  ];

  IconData _getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'directions_bus': Icons.directions_bus,
      'home': Icons.home,
      'sports_esports': Icons.sports_esports,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'phone': Icons.phone,
      'checkroom': Icons.checkroom,
      'face': Icons.face,
      'apartment': Icons.apartment,
      'more_horiz': Icons.more_horiz,
      'account_balance_wallet': Icons.account_balance_wallet,
      'card_giftcard': Icons.card_giftcard,
      'trending_up': Icons.trending_up,
      'work': Icons.work,
      'receipt': Icons.receipt,
      'category': Icons.category,
      'star': Icons.star,
      'favorite': Icons.favorite,
      'book': Icons.book,
      'movie': Icons.movie,
      'music_note': Icons.music_note,
      'flight': Icons.flight,
      'hotel': Icons.hotel,
      'pets': Icons.pets,
      'child_care': Icons.child_care,
      'fitness_center': Icons.fitness_center,
      'smoking_rooms': Icons.smoking_rooms,
      'wine_bar': Icons.wine_bar,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = Category(
        name: _nameController.text,
        icon: _selectedIcon,
        type: widget.type,
        isDefault: false,
        sortOrder: 100,
      );

      await ref.read(categoryNotifierProvider.notifier).addCategory(category);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addSuccess)));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.addFailed}: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: CommonAppBar(title: l10n.addCategory),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterCategoryName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectIcon,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final iconName = _availableIcons[index];
                final isSelected = _selectedIcon == iconName;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconName;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Icon(
                      _getIconData(iconName),
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class EditCategoryPage extends ConsumerStatefulWidget {
  final Category category;

  const EditCategoryPage({super.key, required this.category});

  @override
  ConsumerState<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends ConsumerState<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedIcon;
  bool _isLoading = false;

  final List<String> _availableIcons = [
    'restaurant',
    'shopping_bag',
    'directions_bus',
    'home',
    'sports_esports',
    'local_hospital',
    'school',
    'phone',
    'checkroom',
    'face',
    'apartment',
    'more_horiz',
    'account_balance_wallet',
    'card_giftcard',
    'trending_up',
    'work',
    'receipt',
    'category',
    'star',
    'favorite',
    'book',
    'movie',
    'music_note',
    'flight',
    'hotel',
    'pets',
    'child_care',
    'fitness_center',
    'smoking_rooms',
    'wine_bar',
  ];

  IconData _getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'directions_bus': Icons.directions_bus,
      'home': Icons.home,
      'sports_esports': Icons.sports_esports,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'phone': Icons.phone,
      'checkroom': Icons.checkroom,
      'face': Icons.face,
      'apartment': Icons.apartment,
      'more_horiz': Icons.more_horiz,
      'account_balance_wallet': Icons.account_balance_wallet,
      'card_giftcard': Icons.card_giftcard,
      'trending_up': Icons.trending_up,
      'work': Icons.work,
      'receipt': Icons.receipt,
      'category': Icons.category,
      'star': Icons.star,
      'favorite': Icons.favorite,
      'book': Icons.book,
      'movie': Icons.movie,
      'music_note': Icons.music_note,
      'flight': Icons.flight,
      'hotel': Icons.hotel,
      'pets': Icons.pets,
      'child_care': Icons.child_care,
      'fitness_center': Icons.fitness_center,
      'smoking_rooms': Icons.smoking_rooms,
      'wine_bar': Icons.wine_bar,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = widget.category.copyWith(
        name: _nameController.text,
        icon: _selectedIcon,
      );

      await ref
          .read(categoryNotifierProvider.notifier)
          .updateCategory(category);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.updateSuccess)));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.updateFailed}: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: CommonAppBar(title: l10n.editCategory),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterCategoryName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectIcon,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final iconName = _availableIcons[index];
                final isSelected = _selectedIcon == iconName;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconName;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Icon(
                      _getIconData(iconName),
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
