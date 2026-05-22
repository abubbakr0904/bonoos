import 'package:bonoos/features/auth/data/auth_repository_impl.dart';
import 'package:bonoos/features/auth/domain/repository/auth_repository.dart';
import 'package:bonoos/features/calendar/data/calendar_repository_impl.dart';
import 'package:bonoos/features/calendar/domain/repository/calendar_repository.dart';
import 'package:bonoos/features/common/cubit/settings_cubit.dart';
import 'package:bonoos/features/home/data/banners_repository_impl.dart';
import 'package:bonoos/features/home/data/quotes_repository_impl.dart';
import 'package:bonoos/features/home/data/topics_repository_impl.dart';
import 'package:bonoos/features/home/domain/repository/banners_repository.dart';
import 'package:bonoos/features/home/domain/repository/quotes_repository.dart';
import 'package:bonoos/features/home/domain/repository/topics_repository.dart';
import 'package:bonoos/features/profile/data/profile_repository_impl.dart';
import 'package:bonoos/features/profile/domain/repository/profile_repository.dart';
import 'package:bonoos/features/subscription/data/subscription_repository_impl.dart';
import 'package:bonoos/features/subscription/domain/repository/subscription_repository.dart';
import 'package:bonoos/features/notification/data/notifications_repository_impl.dart';
import 'package:bonoos/features/notification/domain/repository/notifications_repository.dart';
import 'package:bonoos/features/playlist/data/playlist_repository_impl.dart';
import 'package:bonoos/features/playlist/domain/repository/playlist_repository.dart';
import 'package:bonoos/features/common/data/repository/settings_repository_impl.dart';
import 'package:bonoos/features/common/domain/repository/settings_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api/dio_client.dart';
import 'core/utils/pref_manager.dart';
import 'core/services/notification/notification_service.dart';

final inject = GetIt.instance;

Future<void> initDi() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  inject.registerSingleton<SharedPreferences>(pref);
  initPrefManager(pref);

  inject.registerSingleton<DioClient>(DioClient(pref));
  inject.registerSingleton<NotificationService>(NotificationService());
  _dataSources();
  _repositories();
  _useCases();
  _cubits();
}

void initPrefManager(SharedPreferences pref) {
  inject.registerLazySingleton<PrefManager>(() => PrefManager(pref));
}

void _dataSources() {
  // inject.registerLazySingleton<AuthDataSource>(
  //       () => AuthDataSourceImpl(inject()),
  // );
}

void _repositories() {
  inject.registerSingleton<SettingsRepository>(SettingsRepositoryImpl());
  inject.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  inject.registerSingleton<QuotesRepository>(QuotesRepositoryImpl());
  inject.registerSingleton<BannersRepository>(BannersRepositoryImpl());
  inject.registerSingleton<TopicsRepository>(TopicsRepositoryImpl());
  inject.registerSingleton<ProfileRepository>(ProfileRepositoryImpl());
  inject
      .registerSingleton<SubscriptionRepository>(SubscriptionRepositoryImpl());
  inject.registerSingleton<PlaylistRepository>(PlaylistRepositoryImpl());
  inject.registerSingleton<NotificationsRepository>(
      NotificationsRepositoryImpl());
  inject.registerSingleton<CalendarRepository>(CalendarRepositoryImpl());
}

void _useCases() {}

void _cubits() {
  inject.registerSingleton(SettingsCubit(inject()));
}
