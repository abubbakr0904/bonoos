import 'package:bonoos/core/utils/enums.dart';
import 'package:bonoos/features/common/domain/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_cubit.freezed.dart';
part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsRepository) : super(const SettingsState()) {
    loadAppLang();
    loadAppOnboard();
  }

  final SettingsRepository _settingsRepository;

  void loadAppLang() async {
    emit(state.copyWith(status: BlocStatus.inProgress));
    var result = await _settingsRepository.getAppLang();
    Locale locale;
    result.fold((failure) => emit(state.copyWith(message: failure.message ?? '', status: BlocStatus.fail)), (lang) {
      if (lang == 'es') {
        locale = Locale('uz', 'Cyrl');
      } else {
        locale = Locale(lang);
      }
      emit(state.copyWith(language: locale, status: BlocStatus.init));
    });
  }

  void loadAppOnboard() async {
    emit(state.copyWith(status: BlocStatus.inProgress));
    var result = await _settingsRepository.getAppOnBoard();
    result.fold(
      (failure) => emit(state.copyWith(message: failure.message ?? '', status: BlocStatus.fail)),
      (lang) => emit(state.copyWith(onBoard: lang, status: BlocStatus.init)),
    );
  }

  void saveAppLang(String lang) async {
    if (isClosed) throw Exception('closed'); // Exit if the bloc is already closed

    emit(state.copyWith(status: BlocStatus.inProgress));

    var result = await _settingsRepository.setAppLang(lang);
    if (isClosed) {
      return; // Check again if bloc is closed after async operation
    }

    result.fold((failure) => emit(state.copyWith(message: failure.message ?? '', status: BlocStatus.fail)), (lang) {
      Locale locale;
      if (lang == 'es') {
        locale = Locale('uz', 'Cyrl');
      } else {
        locale = Locale(lang);
      }
      emit(state.copyWith(language: locale, status: BlocStatus.init));
    });
  }

  void saveAppOnboard(bool onBoard) async {
    emit(state.copyWith(status: BlocStatus.inProgress));
    var result = await _settingsRepository.saveAppOnBoard(onBoard);
    result.fold(
      (failure) => emit(state.copyWith(message: failure.message ?? '', status: BlocStatus.fail)),
      (onBoard) => emit(state.copyWith(onBoard: onBoard, status: BlocStatus.init)),
    );
  }
}
