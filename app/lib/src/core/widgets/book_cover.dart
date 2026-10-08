import 'package:flutter/material.dart';

import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';

/// How a cover looks when there is no image: Babel's wine red, or the deep red of a
/// fanfiction from Archive of Our Own.
enum BookCoverStyle { standard, fanfiction }

/// A book cover with a soft shadow. Falls back to a titled placeholder while loading or
/// when the image is unavailable (offline, missing cover).
class BookCover extends StatelessWidget {
  const BookCover({
    required this.width,
    this.url,
    this.title,
    this.angle = 0,
    this.style = BookCoverStyle.standard,
    super.key,
  });

  final BookCoverStyle style;

  final double width;
  final String? url;
  final String? title;

  /// Rotation in degrees.
  final double angle;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.5;
    final placeholder = style == BookCoverStyle.fanfiction
        ? _FanficPlaceholder(width: width, title: title ?? '')
        : Container(
            color: BabelColors.velvet,
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: BabelColors.gold.withValues(alpha: 0.7),
                ),
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
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}

/// The cover of a fanfiction without one: the deep red and the paper white of an archive,
/// an open book, the title between two rules, and the mention of what it is.
class _FanficPlaceholder extends StatelessWidget {
  const _FanficPlaceholder({required this.width, required this.title});
  final double width;
  final String title;

  static const _paper = Color(0xFFF3E9DC);

  @override
  Widget build(BuildContext context) {
    final small = width < 70;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA32323), Color(0xFF5A0F0F)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(width / 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: _paper.withValues(alpha: 0.55)),
          ),
          child: Padding(
            padding: EdgeInsets.all(width / 16),
            child: Column(
              children: [
                Icon(Icons.auto_stories, color: _paper, size: width / 4),
                const Spacer(),
                Container(height: 1, color: _paper.withValues(alpha: 0.6)),
                SizedBox(height: width / 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: small ? 3 : 5,
                  overflow: TextOverflow.ellipsis,
                  style: BabelText.heading(width / 9, color: _paper),
                ),
                SizedBox(height: width / 20),
                Container(height: 1, color: _paper.withValues(alpha: 0.6)),
                const Spacer(),
                if (!small)
                  Text(
                    'FANFICTION',
                    style: BabelText.label(
                      width / 16,
                      color: _paper.withValues(alpha: 0.85),
                      spacing: 2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
