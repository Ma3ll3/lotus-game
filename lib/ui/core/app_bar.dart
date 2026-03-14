import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:lotus/ui/theme.dart';

class AppBarStyle extends StatelessWidget implements PreferredSizeWidget {
  const AppBarStyle({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.primary,
      title: Text(title, style: context.texts.h2),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
