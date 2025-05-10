import 'package:flutter/material.dart';

class AccessibleText extends StatelessWidget {
  final Widget child;

  const AccessibleText({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scale = mediaQuery.textScaleFactor.clamp(1.0, 1.5);

    if (scale == mediaQuery.textScaleFactor) {
      return child;
    }

    return MediaQuery(
      data: mediaQuery.copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}
