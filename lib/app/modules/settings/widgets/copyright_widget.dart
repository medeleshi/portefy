import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class CopyRightWidget extends StatelessWidget {
  const CopyRightWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '© ${DateTime.now().year} Portefy . جميع الحقوق محفوظة.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }
}
