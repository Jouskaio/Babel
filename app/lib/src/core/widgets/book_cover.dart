import 'package:flutter/material.dart';

import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';

/// A book cover with a soft shadow. Falls back to a titled placeholder while loading or
/// when the image is unavailable (offline, missing cover).
class BookCover extends StatelessWidget {
  const BookCover({
    required this.width,
    this.url,
    this.title,
    this.angle = 0,
    super.key,
  });

  final double width;
  final String? url;
  final String? title;

  /// Rotation in degrees.
  final double angle;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.5;
    final placeholder = Container(
      color: BabelColors.velvet,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: BabelColors.gold.withValues(alpha: 0.7)),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: Text(
          title ?? '',
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: BabelText.heading(width / 9),
        ),
      ),
    );
    return Transform.rotate(
      angle: angle * 3.1415926535 / 180,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8C000000),
              blurRadius: 48,
              offset: Offset(0, 24),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: url == null
            ? placeholder
            : Image.network(
                url!,
                fit: BoxFit.cover,
                semanticLabel: title,
                errorBuilder: (_, __, ___) => placeholder,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}
