import 'dart:io';
import 'package:flutter/material.dart';

/// Reusable image widget that works with network URLs, asset paths, and local file paths.
///
/// - `http://` / `https://` → [Image.network]
/// - `assets/`             → [Image.asset]
/// - other non-empty path  → [Image.file]
/// - empty / null          → placeholder icon
class AppImage extends StatelessWidget {
  final String? src;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final double iconSize;

  const AppImage({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.iconSize = 48,
  });

  bool get _isNetwork => src != null && (src!.startsWith('http://') || src!.startsWith('https://'));

  bool get _isAsset => src != null && src!.startsWith('assets/');

  bool get _isLocalPath => src != null && src!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(
        src!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _fallback(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _loading(),
      );
    }

    if (_isAsset) {
      return Image.asset(
        src!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    if (_isLocalPath) {
      return Image.file(
        File(src!),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return placeholder ??
        Center(
          child: Icon(Icons.image, size: iconSize, color: Colors.grey),
        );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
