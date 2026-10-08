import 'package:babel/src/features/catalog/presentation/search_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('volumes of a series are named after the series, titles are not', () {
    expect(
      seriesOfTitle("Les carnets de l'apothicaire - Enquêtes à la cour To3"),
      "Les carnets de l'apothicaire",
    );
    expect(
      seriesOfTitle("Les Carnets de l'Apothicaire, Tome 13"),
      "Les Carnets de l'Apothicaire",
    );
    expect(seriesOfTitle('Homunculus Vol. 3'), 'Homunculus');
    expect(seriesOfTitle('Fahrenheit 451'), isNull);
    expect(seriesOfTitle('Jane Eyre'), isNull);
  });
}
