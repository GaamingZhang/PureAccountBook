import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? flexibleSpace;
  final double elevation;

  const CommonAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBack,
    this.flexibleSpace,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundOf(context).withValues(alpha: 0.9),
      elevation: elevation,
      flexibleSpace: flexibleSpace,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textMainOf(context),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: AppColors.divider(context), height: 1.0),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: AppColors.textSecOf(context),
        size: 20,
      ),
      onPressed: onBack ?? () => Navigator.of(context).pop(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

class CommonSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool floating;
  final bool pinned;
  final Widget? titleWidget;

  const CommonSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.floating = true,
    this.pinned = true,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundOf(context).withValues(alpha: 0.9),
      floating: floating,
      pinned: pinned,
      elevation: 0,
      titleSpacing: 16,
      title:
          titleWidget ??
          Text(
            title,
            style: TextStyle(
              color: AppColors.textMainOf(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: AppColors.divider(context), height: 1.0),
      ),
    );
  }
}
