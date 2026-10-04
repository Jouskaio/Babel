import 'package:babel/src/core/auth/auth_controller.dart';
import 'package:babel/src/features/home/application/server_status_provider.dart';
import 'package:babel/src/features/home/presentation/home_page.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class _SignedInAs extends AuthController {
  @override
  AuthState build() => SignedIn(
        UserResponse(
          id: 'u1',
          email: 'ada@example.com',
          displayName: 'Ada',
          hasPassword: true,
          createdAt: DateTime(2026),
        ),
      );
}

void main() {
  testWidgets('greets the user and shows the API version', (tester) async {
    await tester.pumpWidget(
      wrap(
        const HomePage(),
        overrides: [
          authControllerProvider.overrideWith(_SignedInAs.new),
          serverStatusProvider.overrideWith(
            (ref) async => HealthResponse(
              status: HealthResponseStatusEnum.ok,
              version: '0.1.0',
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(', Ada.'), findsOneWidget);
    expect(find.text('API connectée · v0.1.0'), findsOneWidget);
  });

  testWidgets('reports an unreachable API', (tester) async {
    await tester.pumpWidget(
      wrap(
        const HomePage(),
        overrides: [
          authControllerProvider.overrideWith(_SignedInAs.new),
          serverStatusProvider
              .overrideWith((ref) async => throw Exception('offline')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('API injoignable'), findsOneWidget);
  });
}
