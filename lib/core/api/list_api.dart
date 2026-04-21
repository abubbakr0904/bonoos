import 'package:flutter_dotenv/flutter_dotenv.dart';

class ListAPI {
  ListAPI._();

  // static const String baseUrl = "https://location.globalgreentour.uz/api/v1/";
  // static const String BASE_URL = "http://192.168.1.143:8001/api/v1/";

  static String get baseUrl => dotenv.env['TASK_BASE_URL'] ?? '';

  static String get TaskBaseUrl => dotenv.env['TASK_BASE_URL'] ?? '';

  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';

  /// Barcha API so‘rovlarida yuboriladigan header (`x-uuid`). Qiymat: `.env` → `X_UUID`.
  static const String headerXUuid = 'x-uuid';
  static const String _defaultXUuid = '810da8fa-72d8-4a0c-81d8-3a740fe5d18e';
  static String get xUuid => (dotenv.env['X_UUID']?.trim().isNotEmpty ?? false)
      ? dotenv.env['X_UUID']!.trim()
      : _defaultXUuid;

  static const String verify = 'auth/verify-registration';
  static const String login = 'mobile/teacher/login/';
  static const String getMe = 'users/getme/';
  static const String base = 'mobile/teacher/';

  static const String themeMode = 'theme-mode';
  static const String groups = "${base}groups/";
  static const String attendance = "${base}student-attendances/";
  static const String students = "${base}students/";
  static const String onBoard = "on-board";
  static const String lang = "LANG";
  static const String module = "mobile/teacher/modules";
  static const String groupModule = "platform/groups/modules";

  static const String getMainCard = "mobile/teacher/main-card/";
  static const String getLessonShift = "mobile/teacher/lesson-shift";
  static const String moduleStudent = "mobile/teacher/modules/students";
  static const String getModule = "mobile/teacher/modules/?exclude=topic";
  static const String getModuleStudent = "mobile/teacher/modules/students";
  static const String moduleScore = "mobile/teacher/modules/score";

  static const String profile = "mobile/profile";
  static const String payment = "mobile/teacher/salaries/";
  static const String modulePost = "platform/groups/modules/";

  static String moduleDelete(int id) => "platform/groups/modules/$id/";

  static String fileDelete(int id) => "platform/groups/crud/module-files/$id/";

  static String studentDelete(int id) => "platform/group-students/modules/$id/";
  static const String studentModule = "platform/group-students/modules/";
  static const String imageUrl = "https://demo.xamidovcoder.uz/";
  static const String lessonDay = "mobile/teacher/lesson-dates/";

  /// Vibrant auth — POST body: `{ "phone": "930374441" }` (9 raqam, prefiksiz).
  static const String authSendOtp = 'api/v1/auth/client/send-otp';

  /// POST body: `{ "phone": "930374441", "code": "5976" }`.
  static const String authVerifyOtp = 'api/v1/auth/client/verify-otp';

  /// POST — sessiya (Bearer kerak). Body: `device_id`, `device_name`, `session_type`, `fcm_token`.
  static const String authClientSession = 'api/v1/auth/client/session';

  /// POST — chiqish (Bearer kerak). Body: `refresh_token`, `device_id`.
  static const String authClientLogout = 'api/v1/auth/client/logout';

  /// Kunlik iqtiboslar ro‘yxati (GET).
  static const String quotes = 'api/v1/quotes';

  /// O‘zing bilan suhbat — yo‘nalishlar / mavzular (GET).
  static const String topics = 'api/v1/topics';

  /// Mavzuga tegishli savollar (GET).
  static String topicQuestions(int topicId) =>
      'api/v1/topics/$topicId/questions';

  /// Joriy mijoz profili (GET, Bearer).
  static const String clientProfileMe = 'api/v1/client/profile/me';

  /// Mijoz bildirishnomalari (GET, Bearer).
  static const String clientNotifications = 'api/v1/client/notifications';

  /// Bildirishnomalarni o‘qilgan deb belgilash (POST, Bearer). Body: `{ "notification_id", "scope" }`.
  static const String clientNotificationsRead =
      'api/v1/client/notifications/read';

  /// Viloyatlar ro'yxati (GET).
  static const String regions = 'api/v1/regions';

  /// Faoliyat turlari ro'yxati (GET).
  static const String activities = 'api/v1/activities';

  /// Daromad oralig'lari ro'yxati (GET).
  static const String incomeRanges = 'api/v1/income-ranges';

  /// Profil rasmini yuklash (POST, multipart, Bearer).
  static const String clientProfileUpload = 'api/v1/client/profile/upload';

  /// Mijoz profilini yangilash (PUT, Bearer).
  static const String clientProfileUpdate = 'api/v1/client/profile/update';

  /// Obunalar rejasi ro'yxati (GET).
  static const String plans = 'api/v1/plans';

  /// Obunaga yozilish (POST). Body: `{ "plan_id": N }`.
  static const String plansSubscribe = 'api/v1/plans/subscribe';

  /// Kategoriyalar ro'yxati (GET).
  static const String categories = 'api/v1/categories';

  /// Auditionlar ro'yxati (GET). Query: `?category_id=N`.
  static const String auditions = 'api/v1/auditions';

  /// Audioni tinglash (POST, Bearer). Body: `duration`, `audition_type`, `day`.
  static String clientAuditionListen(int auditionId) =>
      'api/v1/client/auditions/$auditionId/listen';

  /// Sevimlilar (POST, Bearer) — audioni favorite qilish / olib tashlash.
  static String clientAuditionFavorite(int auditionId) =>
      'api/v1/client/auditions/$auditionId/favorite';

  /// Sevimli auditionlar ro'yxati (GET, Bearer).
  static const String clientFavoriteAuditions =
      'api/v1/client/favorites/auditions';
}

class SharedModel {
  SharedModel._();

  static const String accessToken = 'access-token';
  static const String refreshToken = 'refresh-token';
  static const String useName = 'userPhone';
  static const String lang = 'app_lang';
  static const String onBoard = 'app_onboarding';

  /// OTP (login) muvaffaqiyatidan keyin yoziladigan flag.
  /// `true` bo'lsa splash'dan keyin Home'ga o'tiladi.
  static const String newUser = 'app_new_user';
  static const String userId = "user_id";
  static const String userId2 = "user_id2";
  static const String hostName = "host-name";
  static const String notificationStatus = "notif_enabled";
  static const String locationStatus = "location_enabled";
  static const String isOwner = "is_owner";
  static const String isDarkMode = "is_dark_mode";
  static const String workStatus = "workStatus";
  static const String companyName = "companyName";
  static const String base = "base";

  /// `tokens.expires_in` (sekund).
  static const String authExpiresIn = 'auth_expires_in';

  /// Verify-otp `data` obyektining to‘liq JSON qatori (keyinchalik ishlatish uchun).
  static const String authSessionJson = 'auth_session_json';

  /// Ushbu o‘rnatish uchun barqaror `device_id` (session API).
  static const String deviceClientId = 'device_client_id';
}
