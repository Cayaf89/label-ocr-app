import 'package:flutter/material.dart';

import '../app/theme/colors.dart';
import '../app/theme/typography.dart';

/// A small badge displaying an OCR confidence percentage with color coding.
///
/// Color thresholds (as specified in the design spec):
/// - **≥ 97 %** → Emerald background / text
/// - **≥ 94 %** → Amber background / text
/// - **< 94 %** → Red background / text
class ConfidencePill extends StatelessWidget {
  /// The confidence value as a percentage (0–100).
  final double confidence;

  /// Whether to append the percent sign. Defaults to `true`.
  final bool showPercentageSign;

  const ConfidencePill({
    super.key,
    required this.confidence,
    this.showPercentageSign = true,
  });

  @override
  Widget build(BuildContext context) {
    final int displayValue = confidence.round();
    final String text = showPercentageSign ? '$displayValue%' : '$displayValue';

    // Determine color based on confidence thresholds.
    Color backgroundColor;
    Color textColor;

    if (confidence >= 97) {
      backgroundColor = AppColors.emerald100;
      textColor = AppColors.emerald700;
    } else if (confidence >= 94) {
      backgroundColor = AppColors.amber100;
      textColor = AppColors.amber700;
    } else {
      backgroundColor = AppColors.red100;
      textColor = AppColors.red700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
      ),
      child: Text(
        text,
        style: AppTypography.monoLabelSmall.copyWith(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
