import 'package:flutter/foundation.dart';

@immutable
class ProfileAvatar {
  const ProfileAvatar._({this.gradientIndex, this.filePath});

  final int? gradientIndex;
  final String? filePath;

  const ProfileAvatar.logo() : this._();

  const ProfileAvatar.gradient(int index) : this._(gradientIndex: index);

  const ProfileAvatar.file(String path) : this._(filePath: path);

  bool get isLogo => gradientIndex == null && filePath == null;
}

class ProfileAvatarController {
  ProfileAvatarController._();

  static final ProfileAvatarController instance = ProfileAvatarController._();

  final ValueNotifier<ProfileAvatar> avatar = ValueNotifier<ProfileAvatar>(const ProfileAvatar.logo());

  void setLogo() => avatar.value = const ProfileAvatar.logo();

  void setGradient(int index) => avatar.value = ProfileAvatar.gradient(index);

  void setFile(String path) => avatar.value = ProfileAvatar.file(path);
}

