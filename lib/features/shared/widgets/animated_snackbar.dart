import 'package:flutter/material.dart';
import 'fade_message.dart';

class AnimatedSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 2),
  }) {
    final snackBar = SnackBar(
      content: FadeMessage(
        message: message,
        backgroundColor: Colors.transparent,
        duration: duration,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration + const Duration(milliseconds: 300),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8),
      padding: EdgeInsets.zero,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
