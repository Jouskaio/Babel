import 'package:flutter/material.dart';

import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';

/// Labelled text field of the design system. Password fields get a show/hide toggle.
class BabelTextField extends StatefulWidget {
  const BabelTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.help,
    this.obscure = false,
    this.showLabel,
    this.hideLabel,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? help;
  final bool obscure;
  final String? showLabel;
  final String? hideLabel;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<BabelTextField> createState() => _BabelTextFieldState();
}

class _BabelTextFieldState extends State<BabelTextField> {
  late bool _hidden = widget.obscure;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: BabelText.label(
            10,
            color: BabelColors.textSecondary,
            spacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          style: BabelText.body(15, color: BabelColors.textPrimary),
          cursorColor: BabelColors.gold,
          decoration: InputDecoration(
            filled: true,
            fillColor: BabelColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            enabledBorder: _border(BabelColors.border),
            focusedBorder: _border(BabelColors.gold),
            errorBorder: _border(BabelColors.dustyRose),
            focusedErrorBorder: _border(BabelColors.dustyRose),
            errorStyle: BabelText.body(12, color: BabelColors.dustyRose),
            helperText: widget.help,
            helperStyle: BabelText.body(12),
            helperMaxLines: 2,
            suffixIcon: widget.obscure
                ? TextButton(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    child: Text(
                      (_hidden ? widget.showLabel : widget.hideLabel)
                              ?.toUpperCase() ??
                          '',
                      style: BabelText.label(10, spacing: 1.2),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
