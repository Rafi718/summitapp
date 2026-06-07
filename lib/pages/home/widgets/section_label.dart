import 'package:flutter/material.dart';
import '../alpine_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: AppText.title(size: 18)),
          const Spacer(),
          if (trailing != null) ...[trailing!, const SizedBox(width: 12)],
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(action!, style: AppText.caption(size: 12, color: AppColors.textPrimary, weight: FontWeight.w500)),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.textPrimary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
