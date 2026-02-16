import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../providers/category_notifier_provider.dart';
import '../providers/category_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/theme_provider.dart';
import '../../../shared/widgets/widgets.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOf(context).withValues(alpha: 0.9),
        elevation: 0,
        title: const Text(
          '类型管理',
          style: TextStyle(
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
              tabs: const [
                Tab(text: '支出类型'),
                Tab(text: '收入类型'),
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

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('暂无类型'));
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
      error: (e, _) => Center(child: Text('加载失败: $e')),
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
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个类型吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                ).showSnackBar(const SnackBar(content: Text('类型已删除')));
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
        title: Text(category.name),
        subtitle: category.isDefault ? const Text('默认类型') : null,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('添加成功')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('添加失败: $e')));
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
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: CommonAppBar(
        title: '添加${widget.type == 'expense' ? '支出' : '收入'}类型',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '类型名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入类型名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '选择图标',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  : const Text('保存'),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('更新成功')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: const CommonAppBar(title: '编辑类型'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '类型名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入类型名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '选择图标',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  : const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
