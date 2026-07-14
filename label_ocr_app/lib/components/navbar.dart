import 'package:flutter/material.dart';

import '../app/theme/typography.dart' show AppTypography, kEm;
import '../utils/constants.dart';

/// Fixed top navigation bar used across all screens.
///
/// Displays a back button (when applicable), a subtitle + title block,
/// and an optional right-side action widget. Background is #111218 at 64 px height.
class Navbar extends StatelessWidget implements PreferredSizeWidget {
  /// The primary screen title shown in the nav bar.
  final String title;

  /// A secondary label above [title], e.g. "Label Scanner".
  final String subtitle;

  /// Whether to show the back arrow button on the left side.
  final bool showBackButton;

  /// Custom callback for the back button tap. Falls back to `Navigator.pop` when null.
  final VoidCallback? onBack;

  /// Optional widget placed on the right side of the nav bar (e.g. a "Nouveau" button).
  final Widget? rightAction;

  const Navbar({
    super.key,
    required this.title,
    this.subtitle = 'Label Scanner',
    this.showBackButton = true,
    this.onBack,
    this.rightAction,
  });

  @override
  Size get preferredSize => const Size.fromHeight(navbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton && canPop;

    return Container(
      height: navbarHeight,
      color: const Color(0xFF111218),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // ── Left side ────────────────────────────────────────
              Expanded(
                child: Row(
                  children: [
                    if (shouldShowBack) ...[
                      GestureDetector(
                        onTap: onBack ?? () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.only(left: -4.0),
                          child: Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),

                    // Title block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            subtitle,
                            style: AppTypography.monoLabelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10,
                              letterSpacing: 0.1 * kEm,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Right side action ────────────────────────────────
              ?rightAction,
            ],
          ),
        ),
      ),
    );
  }
}
