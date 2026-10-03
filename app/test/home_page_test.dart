import 'package:babel/src/features/home/application/server_status_provider.dart';
import 'package:babel/src/features/home/presentation/home_page.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Override override) => ProviderScope(
      overrides: [override],
      child: const MaterialApp(home: HomePage()),
    );

void main() {
  testWidgets('shows the API version when the API responds', (tester) async {
    await tester.pumpWidget(
      _wrap(
        serverStatusProvider.overrideWith(
          (ref) async => HealthResponse(
            status: HealthResponseStatusEnum.ok,
            version: '0.1.0',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('API connectée · v0.1.0'), findsOneWidget);
  });

  testWidgets('reports an unreachable API', (tester) async {
    await tester.pumpWidget(
      _wrap(
        serverStatusProvider.overrideWith(
          (ref) async => throw Exception('offline'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('API injoignable'), findsOneWidget);
  });
}
