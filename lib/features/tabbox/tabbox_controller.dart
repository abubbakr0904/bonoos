import 'package:bonoos/core/utils/external_payments.dart';
import 'package:flutter/foundation.dart';

enum AppTab {
  home,
  calendar,
  gratitude,
  subscription,
  sections,
}

class TabBoxController {
  TabBoxController._();

  static final TabBoxController instance = TabBoxController._();

  final ValueNotifier<int> index = ValueNotifier<int>(0);

  /// «To‘plamlar» (tashqi to‘lov) tabi — tashqi to‘lovlar yashirilmagan bo‘lsa ko‘rinadi.
  static bool get isSubscriptionVisible => !hideExternalPayments();

  static List<AppTab> get visibleTabs {
    if (isSubscriptionVisible) {
      return AppTab.values;
    }
    return const [
      AppTab.home,
      AppTab.calendar,
      AppTab.gratitude,
      AppTab.sections,
    ];
  }

  static int indexOf(AppTab tab) => visibleTabs.indexOf(tab);

  static AppTab tabAt(int index) {
    final tabs = visibleTabs;
    if (index < 0 || index >= tabs.length) return tabs.first;
    return tabs[index];
  }

  void setIndex(int value) {
    final clamped = value.clamp(0, visibleTabs.length - 1);
    if (clamped == index.value) return;
    index.value = clamped;
  }

  void setTab(AppTab tab) {
    final i = indexOf(tab);
    if (i < 0) return;
    setIndex(i);
  }
}
