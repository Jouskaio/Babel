import 'package:flutter/widgets.dart';

import 'autofill_bridge_io.dart'
    if (dart.library.js_interop) 'autofill_bridge_web.dart'
    as impl;

/// Lets a browser's password manager (Proton Pass, Dashlane, 1Password…) fill a form.
///
/// On the web a text field is a hidden browser input that exists only while it is focused; what
/// an extension writes into the other, unfocused inputs of the form was ignored. This reads those
/// inputs (named like their autofill hint: "username", "current-password"…) and writes them into
/// the matching controllers. Elsewhere it does nothing.
class AutofillBridge {
  AutofillBridge(Map<String, TextEditingController> controllers)
    : _handle = impl.attach(controllers);

  final Object? _handle;

  void dispose() => impl.detach(_handle);
}
