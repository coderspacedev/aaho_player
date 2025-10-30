import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum StatusBarTheme { light, dark }

class CoderXAnnotatedRegion extends StatelessWidget {
  final Widget child;
  final StatusBarTheme theme;

  const CoderXAnnotatedRegion({
    super.key,
    required this.child,
    this.theme = StatusBarTheme.light,
  });

  @override
  Widget build(BuildContext context) {
    final style = theme == StatusBarTheme.light
        ? const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android -> white icons
      statusBarBrightness: Brightness.dark,      // iOS -> white icons
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    )
        : const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android -> black icons
      statusBarBrightness: Brightness.light,    // iOS -> black icons
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: child,
    );
  }
}