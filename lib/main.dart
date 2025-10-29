import 'package:aaho_player/aaho.dart';

import 'aaho_exports.dart';

void main() {
  AppTheme.setLightColors(
    CoderColor(
      primary: Color(0xFFFFFFFF),
      background: Color(0xFFFBFBFB),
      card: Color(0xFFF3F3F3),
      cardText: Color(0xFF101010),
      text: Color(0xFF101010),
      accent: Color(0xFF5F55E3),
      accentText: Color(0xFFFFFFFF),
    ),
  );
  AppTheme.useLight();
  runApp(const Aaho());
}
