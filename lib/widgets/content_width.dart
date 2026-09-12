import 'package:flutter/material.dart';

/// Keeps page content readable on wide desktop/web viewports by centering it
/// in a max-width column, instead of stretching every card and grid edge to
/// edge on a 1500px-wide browser window.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
