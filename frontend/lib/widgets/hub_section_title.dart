import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class HubSectionTitle extends StatelessWidget {
  const HubSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: AppTextStyles.cardTitle.copyWith(
          fontSize: 15,
          color: AppColors.navy,
        ),
      ),
    );
  }
}
