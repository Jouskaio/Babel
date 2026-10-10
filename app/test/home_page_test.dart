import 'package:babel/src/core/auth/auth_controller.dart';
import 'package:babel/src/features/home/presentation/home_page.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
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
      emailVerified: true,
      locale: UserResponseLocaleEnum.fr,
      createdAt: DateTime(2026),
    ),
  );
}

void main() {
  testWidgets('greets the user by name', (tester) async {
    await tester.pumpWidget(
      wrap(
        const HomePage(),
        overrides: [authControllerProvider.overrideWith(_SignedInAs.new)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ada.'), findsOneWidget);
    expect(find.textContaining('Bon'), findsWidgets);
  });

  testWidgets('offers moods to browse by', (tester) async {
    await tester.pumpWidget(
      wrap(
        const HomePage(),
        overrides: [authControllerProvider.overrideWith(_SignedInAs.new)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('GOTHIQUE'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );

    expect(find.text('GOTHIQUE'), findsOneWidget);
  });
}
