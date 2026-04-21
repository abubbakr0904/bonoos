class VerifyOtpResult {
  const VerifyOtpResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.userId,
    required this.isNewUser,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int userId;
  final bool isNewUser;

  factory VerifyOtpResult.fromJson(Map<String, dynamic> data) {
    final tokens = data['tokens'];
    final t = tokens is Map<String, dynamic> ? tokens : <String, dynamic>{};
    return VerifyOtpResult(
      accessToken: t['access_token'] as String? ?? '',
      refreshToken: t['refresh_token'] as String? ?? '',
      expiresIn: (t['expires_in'] as num?)?.toInt() ?? 0,
      userId: (data['user_id'] as num?)?.toInt() ?? 0,
      isNewUser: data['is_new_user'] as bool? ?? false,
    );
  }
}
