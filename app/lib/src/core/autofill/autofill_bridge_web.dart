import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

class _Handle {
  _Handle(this.listener);
  final JSFunction listener;
}

/// Listens (before Flutter does) to what is written into the form's inputs.
Object? attach(Map<String, TextEditingController> controllers) {
  void onInput(web.Event event) {
    final target = event.target;
    if (target == null || !target.isA<web.HTMLInputElement>()) return;
    final input = target as web.HTMLInputElement;
    // The focused input is Flutter's own, which handles it; the others are the form's
    // hidden inputs a password manager fills.
    if (web.document.activeElement == input) return;
    final controller =
        controllers[input.name] ?? controllers[input.autocomplete];
    if (controller != null && controller.text != input.value) {
      controller.value = TextEditingValue(
        text: input.value,
        selection: TextSelection.collapsed(offset: input.value.length),
      );
    }
  }

  final listener = onInput.toJS;
  web.document.addEventListener('input', listener, true.toJS);
  web.document.addEventListener('change', listener, true.toJS);
  return _Handle(listener);
}

void detach(Object? handle) {
  if (handle is! _Handle) return;
  web.document.removeEventListener('input', handle.listener, true.toJS);
  web.document.removeEventListener('change', handle.listener, true.toJS);
}
