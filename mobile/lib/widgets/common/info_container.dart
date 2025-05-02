import 'package:flutter/material.dart';

/// A reusable container for information sections
class InfoContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hasBorder;

  const InfoContainer({
    super.key,
    required this.child,
    this.padding,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: hasBorder
            ? Border.all(color: Colors.grey.shade800, width: 1)
            : null,
      ),
      child: child,
    );
  }
}
