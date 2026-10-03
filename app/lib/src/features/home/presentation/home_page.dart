import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/server_status_provider.dart';

/// Home screen. For now: greeting and API connection status.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final status = ref.watch(serverStatusProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('B A B E L', style: text.labelSmall),
              const SizedBox(height: 32),
              Text('Bonsoir.', style: text.displayLarge),
              const SizedBox(height: 24),
              Text(
                status.when(
                  data: (health) =>
                      'API connectée · v${health?.version ?? '?'}',
                  loading: () => 'Connexion à l’API…',
                  error: (_, __) => 'API injoignable',
                ),
                style: text.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
