import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/router.dart';
import '../theme/babel_colors.dart';

/// The back arrow of a page. Flutter's own arrow disappears when there is no page below
/// (a reloaded page, a link opened directly): this one then goes home.
class BackLeading extends StatelessWidget {
  const BackLeading({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    icon: Icon(Icons.arrow_back, color: BabelColors.textPrimary),
    onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
  );
}
