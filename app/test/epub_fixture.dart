import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// A small EPUB 3 with a navigation document, two chapters and an image.
Uint8List epubFixture() {
  final archive = Archive();
  void add(String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  add('mimetype', 'application/epub+zip');
  add(
    'META-INF/container.xml',
    '<?xml version="1.0"?><container version="1.0" '
        'xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles>'
        '<rootfile full-path="OEBPS/content.opf" '
        'media-type="application/oebps-package+xml"/></rootfiles></container>',
  );
  add(
    'OEBPS/content.opf',
    '<?xml version="1.0"?><package xmlns="http://www.idpf.org/2007/opf" '
        'version="3.0"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'
        '<dc:title>Wuthering Heights</dc:title></metadata><manifest>'
        '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" '
        'properties="nav"/>'
        '<item id="c1" href="text/one.xhtml" media-type="application/xhtml+xml"/>'
        '<item id="c2" href="text/two%20b.xhtml" '
        'media-type="application/xhtml+xml"/>'
        '<item id="img" href="images/moor.png" media-type="image/png"/>'
        '</manifest><spine><itemref idref="nav" linear="no"/>'
        '<itemref idref="c1"/><itemref idref="c2"/></spine></package>',
  );
  add(
    'OEBPS/nav.xhtml',
    '<html xmlns="http://www.w3.org/1999/xhtml"><body><nav><ol>'
        '<li><a href="text/one.xhtml">Chapter I</a></li>'
        '<li><a href="text/two%20b.xhtml#start">Chapter II</a></li>'
        '</ol></nav></body></html>',
  );
  add(
    'OEBPS/text/one.xhtml',
    '<html xmlns="http://www.w3.org/1999/xhtml"><head><style>p{color:red}</style>'
        '</head><body><p>I have just returned from a visit to my landlord.</p>'
        '<img src="../images/moor.png"/><script>alert(1)</script></body></html>',
  );
  add(
    'OEBPS/text/two b.xhtml',
    '<html xmlns="http://www.w3.org/1999/xhtml"><body>'
        '<p>Nelly, I am Heathcliff!</p></body></html>',
  );
  final png = base64.decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  );
  archive.addFile(ArchiveFile('OEBPS/images/moor.png', png.length, png));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
