import 'package:flutter/material.dart';
import 'package:lotus/ui/theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 1,
      color: context.colors.secondary.withValues(alpha: 0.3),
    );
  }
}

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.colors.primary),
    );
  }
}
