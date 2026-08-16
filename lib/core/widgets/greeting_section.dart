import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

class GreetingSection extends StatelessWidget {
  final String userName;
  final String subtitle;

  final Widget? trailing;

  const GreetingSection({
    super.key,
    required this.userName,
    required this.subtitle,
    this.trailing,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                userName,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSizes.xs),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: AppSizes.xs),

        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
