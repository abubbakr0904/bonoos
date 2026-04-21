import 'package:bonoos/generated/l10n.dart';
import 'package:flutter/material.dart';

extension ForContext on BuildContext {
  MediaQueryData get mq => MediaQuery.of(this);
  double get w => mq.size.width;
  double get h => mq.size.height;

  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => theme.brightness == Brightness.dark;
}


extension Translate on BuildContext {
  S get tr => S.of(this);
}