import 'package:flutter/material.dart';
import 'package:trinity/widgets/navbar.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final String currentPath;
  final Function(String) onNavigationChanged;

  const AppLayout({
    super.key,
    required this.child,
    required this.currentPath,
    required this.onNavigationChanged,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: CustomNavigationBar(
        currentPath: widget.currentPath,
        onTap: widget.onNavigationChanged,
      ),
    );
  }
}
