part of 'settings_cubit.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(BlocStatus.init) final BlocStatus status,
    @Default('') final String message,
    @Default(Locale('uz')) final Locale language,
    @Default(false) final bool onBoard,
  }) = _SettingsState;

  const SettingsState._();

  @override
   get language => throw UnimplementedError();

  @override
  String get message => throw UnimplementedError();

  @override
  bool get onBoard => throw UnimplementedError();

  @override
  BlocStatus get status => throw UnimplementedError();
}
