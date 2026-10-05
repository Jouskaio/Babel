import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

const _images = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.avif'};

/// How a comic's pages follow each other.
enum ComicDirection {
  /// Western comics: left to right.
  leftToRight,

  /// Manga: right to left.
  rightToLeft,

  /// Webtoons: one long vertical strip.
  vertical,
}

/// A comic archive (CBZ): its pages in reading order, and how it reads.
class ComicBook {
  ComicBook._(this._pages, this.direction);

  /// Opens a CBZ. The direction comes from its ComicInfo.xml when there is one
  /// (`<Manga>YesAndRightToLeft</Manga>`), else left to right.
  factory ComicBook.open(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final pages =
        archive.files
            .where(
              (f) =>
                  f.isFile &&
                  !f.name.startsWith('__MACOSX/') &&
                  _images.any((e) => f.name.toLowerCase().endsWith(e)),
            )
            .toList()
          ..sort((a, b) => _natural(a.name, b.name));
    if (pages.isEmpty) throw const FormatException('no pages');
    return ComicBook._(pages, _direction(archive));
  }

  final List<ArchiveFile> _pages;
  final ComicDirection direction;

  int get length => _pages.length;

  Uint8List page(int index) =>
      Uint8List.fromList(_pages[index].content as List<int>);

  static ComicDirection _direction(Archive archive) {
    final info = archive.files
        .where((f) => f.name.toLowerCase().endsWith('comicinfo.xml'))
        .firstOrNull;
    if (info == null) return ComicDirection.leftToRight;
    try {
      final xml = XmlDocument.parse(
        utf8.decode(info.content as List<int>, allowMalformed: true),
      );
      final manga = xml.findAllElements('Manga').firstOrNull?.innerText.trim();
      return manga == 'YesAndRightToLeft'
          ? ComicDirection.rightToLeft
          : ComicDirection.leftToRight;
    } on XmlException {
      return ComicDirection.leftToRight;
    }
  }
}

/// "page2" before "page10".
int _natural(String a, String b) {
  final digits = RegExp(r'\d+|\D+');
  final pa = digits.allMatches(a.toLowerCase()).map((m) => m[0]!).toList();
  final pb = digits.allMatches(b.toLowerCase()).map((m) => m[0]!).toList();
  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final na = int.tryParse(pa[i]);
    final nb = int.tryParse(pb[i]);
    final order = na != null && nb != null
        ? na.compareTo(nb)
        : pa[i].compareTo(pb[i]);
    if (order != 0) return order;
  }
  return pa.length.compareTo(pb.length);
}

/// An area of a page, in fractions of the page: "x,y,w,h" as stored with notes.
class PageRegion {
  const PageRegion(this.x, this.y, this.width, this.height);

  static PageRegion? parse(String? value) {
    final parts = value?.split(',').map(double.tryParse).toList();
    if (parts == null || parts.length != 4 || parts.contains(null)) return null;
    return PageRegion(parts[0]!, parts[1]!, parts[2]!, parts[3]!);
  }

  /// From two corners of a drag, clamped to the page; null when too small to mean
  /// anything (a tap).
  static PageRegion? between(double x1, double y1, double x2, double y2) {
    double c(double v) => v.clamp(0.0, 1.0);
    final left = c(x1 < x2 ? x1 : x2);
    final top = c(y1 < y2 ? y1 : y2);
    final width = c(x1 < x2 ? x2 : x1) - left;
    final height = c(y1 < y2 ? y2 : y1) - top;
    if (width < 0.02 || height < 0.02) return null;
    return PageRegion(left, top, width, height);
  }

  final double x;
  final double y;
  final double width;
  final double height;

  @override
  String toString() =>
      [x, y, width, height].map((v) => v.toStringAsFixed(4)).join(',');
}
