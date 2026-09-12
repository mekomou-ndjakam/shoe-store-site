import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a product asset regardless of its format (svg or raster) and
/// degrades gracefully to a placeholder if the path is empty or fails to
/// load, instead of crashing the page.
class AppImage extends StatelessWidget {
  const AppImage(
    this.path, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.backgroundColor = const Color(0xFFF3EFE8),
    this.iconColor = const Color(0xFFB9AFA0),
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return _placeholder();
    }

    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        placeholderBuilder: (_) => _placeholder(),
      );
    }

    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: iconColor, size: 32),
    );
  }
}
