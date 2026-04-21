class ClientProfile {
  const ClientProfile({
    required this.id,
    required this.phone,
    required this.email,
    required this.verifiedEmail,
    required this.fullName,
    required this.avatar,
    required this.telegramId,
    required this.bio,
    this.birthday,
    this.regionId,
    this.activityId,
    this.income,
  });

  final int id;
  final String phone;
  final String email;
  final bool verifiedEmail;
  final String fullName;
  final String avatar;
  final String telegramId;
  final String bio;
  final String? birthday;
  final int? regionId;
  final int? activityId;
  final int? income;

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      verifiedEmail: json['verified_email'] as bool? ?? false,
      fullName: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      telegramId: json['telegram_id'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      birthday: json['birthday'] as String?,
      regionId: (json['region_id'] as num?)?.toInt(),
      activityId: (json['activity_id'] as num?)?.toInt(),
      income: (json['income'] as num?)?.toInt(),
    );
  }
}
