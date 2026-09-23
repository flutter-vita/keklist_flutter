import 'package:flutter/material.dart';

/// Drop-in replacements for `modal_bottom_sheet`, which does not work here.
///
/// keklist reached for `modal_bottom_sheet: ^3.0.0-pre` in fourteen places.
/// On the Vita all three of its symptoms show up together: the sheet paints as
/// a black rectangle, taps inside it never reach the content, and no gesture
/// closes it. Flutter's own `showModalBottomSheet` is fine in the same build,
/// which is how the paywall and the password prompt still work.
///
/// The package positions its sheet with a layout delegate driven by the route
/// animation and puts a drag-to-dismiss `Listener` above the content. Both of
/// those are the parts that fail, and both exist to give a phone the pull-down
/// gesture. The Vita has no touch bezel worth pulling from and a 960x544
/// landscape screen where a sheet covering the bottom half leaves 272 px of
/// content, so the gesture buys nothing and a page costs nothing.
///
/// So these push a route instead. The names and the `context` / `builder`
/// signature match the package so the call sites keep their shape and the diff
/// stays readable; only the imports changed.
///
/// The `Scaffold` is load-bearing rather than decoration. Sheet bodies here
/// were written to sit inside a container the package supplied:
/// `MindPickerScreen` returns a bare `Column`, so on a route of its own it has
/// nothing painting behind it. The `AppBar` carries the close button that the
/// pull-down gesture used to be.
Future<T?> showBarModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return _pushSheet<T>(context, builder);
}

Future<T?> showCupertinoModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return _pushSheet<T>(context, builder);
}

Future<T?> _pushSheet<T>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(
      builder: (context) => Scaffold(
        appBar: AppBar(
          // 544 px of height, and the body wants all of it. The default 56 is
          // a phone number.
          toolbarHeight: 44.0,
          leading: const CloseButton(),
        ),
        body: builder(context),
      ),
    ),
  );
}
