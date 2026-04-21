import 'package:flutter/foundation.dart';

class TabBoxController {
  TabBoxController._();

  static final TabBoxController instance = TabBoxController._();

  final ValueNotifier<int> index = ValueNotifier<int>(0);

  void setIndex(int value) {
    if (value == index.value) return;
    index.value = value;
  }
}

