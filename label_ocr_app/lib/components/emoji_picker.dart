import 'package:flutter/material.dart';

import '../app/theme/colors.dart' show AppColors;
import '../app/theme/typography.dart' show AppSpacing;

/// An emoji selection dropdown button for template icon picking.
///
/// Displays a [PopupMenuButton] with common product-category emojis.
class EmojiPicker extends StatefulWidget {
  /// The currently selected emoji string (e.g. "🥛").
  final String selectedEmoji;

  /// Callback invoked when the user picks an emoji.
  final ValueChanged<String> onEmojiSelected;

  /// Overall size of the picker button (width & height). Defaults to `36`.
  final double size;

  const EmojiPicker({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
    this.size = 36.0,
  });

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  bool _isExpanded = false;

  /// Common emojis for product label templates (30 items).
  static const List<String> _emojis = [
    '😀',
    '🥛',
    '🧀',
    '🍞',
    '🥫',
    '🧊',
    '💄',
    '💊',
    '🍺',
    '🥤',
    '🍎',
    '🍌',
    '🐟',
    '🥩',
    '🍚',
    '🍝',
    '🥗',
    '🍰',
    '☕',
    '🍷',
    '🧴',
    '🧹',
    '🔧',
    '💡',
    '📦',
    '🎁',
    '🧸',
    '👶',
    '🐾',
    '🌿',
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: widget.selectedEmoji,
      onSelected: (value) {
        setState(() {});
        widget.onEmojiSelected(value);
      },
      onOpened: () => setState(() => _isExpanded = true),
      onCanceled: () => setState(() => _isExpanded = false),
      itemBuilder: (BuildContext context) => _emojis.map((emoji) {
        return PopupMenuItem<String>(
          value: emoji,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
        );
      }).toList(),
      offset: const Offset(0, 8),
      constraints: const BoxConstraints(maxHeight: 240, maxWidth: 200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
      ),
      elevation: 4,
      padding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          ),
          child: Center(
            child: Text(
              widget.selectedEmoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
