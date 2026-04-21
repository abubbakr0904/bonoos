import 'package:flutter/material.dart';

enum ThemeModeState { light, dark, auto }

List<Map<String, String>> languages = [
  {'code': 'uz', 'name': "O'zbek"},
  {'code': 'es', 'name': "Ўзбекча"},
  {'code': 'ru', 'name': "Русский"},
  {'code': 'en', 'name': "English"},
];

enum ValidationStatus { UNVALIDATED, IN_PROGRESS, VALIDATED, INVALID }

enum CardType { visa, mastercard, uzcard, humo, unknown }

enum BlocStatus { init, inProgress, fail, success , initial , unAutorized , inProgressUpdate;


  bool get isInit => this == init;

  bool get isInProgress => this == inProgress;

  bool get isFail => this == fail;

  bool get isSuccess => this == success;
}

