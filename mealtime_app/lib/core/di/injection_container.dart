import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/network/auth_interceptor.dart';
import 'package:mealtime_app/core/network/api_response_interceptor.dart';
import 'package:mealtime_app/core/database/app_database.dart';
import 'package:mealtime_app/services/api/api_client.dart';
import 'package:mealtime_app/services/api/auth_api_service.dart';
import 'package:mealtime_app/services/api/cats_api_service.dart';
import 'package:mealtime_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mealtime_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mealtime_app/features/auth/data/datasources/supabase_auth_remote_datasource.dart';
import 'package:mealtime_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mealtime_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mealtime_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mealtime_app/features/cats/data/datasources/cats_remote_datasource.dart';
import 'package:mealtime_app/features/cats/data/datasources/cats_local_datasource.dart';
import 'package:mealtime_app/features/cats/data/repositories/cats_repository_impl.dart';
import 'package:mealtime_app/features/cats/domain/repositories/cats_repository.dart';
import 'package:mealtime_app/features/cats/domain/usecases/get_cats.dart';
import 'package:mealtime_app/features/cats/domain/usecases/get_cat_by_id.dart';
import 'package:mealtime_app/features/cats/domain/usecases/create_cat.dart';
import 'package:mealtime_app/features/cats/domain/usecases/update_cat.dart';
import 'package:mealtime_app/features/cats/domain/usecases/delete_cat.dart';
import 'package:mealtime_app/features/cats/domain/usecases/update_cat_weight.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/services/api/homes_api_service.dart';
import 'package:mealtime_app/features/homes/data/datasources/homes_remote_datasource.dart';
import 'package:mealtime_app/features/homes/data/datasources/homes_local_datasource.dart';
import 'package:mealtime_app/features/homes/data/repositories/homes_repository_impl.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';
import 'package:mealtime_app/features/homes/domain/usecases/get_homes.dart';
import 'package:mealtime_app/features/homes/domain/usecases/create_home.dart';
import 'package:mealtime_app/features/homes/domain/usecases/update_home.dart';
import 'package:mealtime_app/features/homes/domain/usecases/delete_home.dart';
import 'package:mealtime_app/features/homes/domain/usecases/set_active_home.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:mealtime_app/features/auth/data/datasources/supabase_storage_datasource.dart';
import 'package:mealtime_app/services/api/feeding_logs_api_service.dart';
import 'package:mealtime_app/features/feeding_logs/data/datasources/feeding_logs_remote_datasource.dart';
import 'package:mealtime_app/features/feeding_logs/data/repositories/feeding_logs_repository_impl.dart';
import 'package:mealtime_app/features/feeding_logs/domain/repositories/feeding_logs_repository.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_feeding_logs.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_feeding_logs_by_cat.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_feeding_log_by_id.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/get_today_feeding_logs.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/create_feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/create_feeding_logs_batch.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/update_feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/usecases/delete_feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/core/sync/sync_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Supabase
  sl.registerLazySingleton(() => SupabaseConfig.client);

  // Database
  sl.registerLazySingleton(() => AppDatabase());

  // Dio - Configurado com interceptors
  // Base URL padrão é /api, mas serviços específicos podem sobrescrever via @RestApi(baseUrl: ...)
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  // Ordem correta dos interceptors:
  // 1. AuthInterceptor - adiciona tokens e headers
  // 2. ApiResponseInterceptor - transforma respostas
  // 3. LogInterceptor - deve ser o último para logar tudo
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(ApiResponseInterceptor());
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: false,
    ),
  );
  sl.registerLazySingleton(() => dio);
  
  // Dio específico para V2 (usado apenas quando necessário)
  final dioV2 = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrlV2,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  // Ordem correta dos interceptors:
  // 1. AuthInterceptor - adiciona tokens e headers
  // 2. ApiResponseInterceptor - transforma respostas
  // 3. LogInterceptor - deve ser o último para logar tudo
  dioV2.interceptors.add(AuthInterceptor());
  dioV2.interceptors.add(ApiResponseInterceptor());
  dioV2.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: false,
    ),
  );
  sl.registerLazySingleton<Dio>(() => dioV2, instanceName: 'dioV2');

  // API Client
  sl.registerLazySingleton(() => ApiClient(sl()));

  // API Services
  sl.registerLazySingleton(() => AuthApiService(sl()));
  // CatsApiService usa Dio V2 para garantir URL correta /api/v2/cats
  // Usa Dio específico da V2 para evitar conflito de baseUrl
  sl.registerLazySingleton(() => CatsApiService(sl<Dio>(instanceName: 'dioV2')));
  // HomesApiService usa Dio V2 para garantir URL correta /api/v2/households
  // Usa Dio específico da V2 para evitar conflito de baseUrl
  sl.registerLazySingleton(() => HomesApiService(sl<Dio>(instanceName: 'dioV2')));

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => SupabaseAuthRemoteDataSourceImpl(supabase: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<SupabaseAuthDataSource>(
    () => SupabaseAuthDataSourceImpl(supabase: sl()),
  );

  sl.registerLazySingleton<SupabaseStorageDataSource>(
    () => SupabaseStorageDataSourceImpl(supabase: sl()),
  );

  sl.registerLazySingleton<CatsRemoteDataSource>(
    () => CatsRemoteDataSourceImpl(apiService: sl()),
  );

  sl.registerLazySingleton<CatsLocalDataSource>(
    () => CatsLocalDataSourceImpl(database: sl()),
  );

  // Usar API do backend via Dio/Retrofit (não Supabase diretamente devido a RLS policies)
  sl.registerLazySingleton<HomesRemoteDataSource>(
    () => HomesRemoteDataSourceImpl(apiService: sl()),
  );

  sl.registerLazySingleton<HomesLocalDataSource>(
    () => HomesLocalDataSourceImpl(
      database: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Sync Service
  sl.registerLazySingleton<SyncService>(
    () => SyncService(
      database: sl(),
      dio: sl<Dio>(instanceName: 'dioV2'),
      catsRemoteDataSource: sl(),
      catsLocalDataSource: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<CatsRepository>(
    () => CatsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      syncService: sl(),
    ),
  );

  sl.registerLazySingleton<HomesRepository>(
    () => HomesRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerLazySingleton(() => GetCats(sl()));
  sl.registerLazySingleton(() => GetCatById(sl()));
  sl.registerLazySingleton(() => CreateCat(sl()));
  sl.registerLazySingleton(() => UpdateCat(sl()));
  sl.registerLazySingleton(() => DeleteCat(sl()));
  sl.registerLazySingleton(() => UpdateCatWeight(sl()));

  sl.registerLazySingleton(() => GetHomes(sl()));
  sl.registerLazySingleton(() => CreateHome(sl()));
  sl.registerLazySingleton(() => UpdateHome(sl()));
  sl.registerLazySingleton(() => DeleteHome(sl()));
  sl.registerLazySingleton(() => SetActiveHome(sl()));

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CatsBloc(
      getCats: sl(),
      getCatById: sl(),
      createCat: sl(),
      updateCat: sl(),
      deleteCat: sl(),
      updateCatWeight: sl(),
    ),
  );

  sl.registerFactory(
    () => HomesBloc(
      getHomes: sl(),
      createHome: sl(),
      updateHome: sl(),
      deleteHome: sl(),
      setActiveHome: sl(),
    ),
  );

  // FeedingLogs - API Service
  // Usa Dio V2 para garantir URL correta /api/v2/feedings
  sl.registerLazySingleton(() => FeedingLogsApiService(sl<Dio>(instanceName: 'dioV2')));

  // FeedingLogs - Data Sources
  sl.registerLazySingleton<FeedingLogsRemoteDataSource>(
    () => FeedingLogsRemoteDataSourceImpl(apiService: sl()),
  );

  // FeedingLogs - Repositories
  sl.registerLazySingleton<FeedingLogsRepository>(
    () => FeedingLogsRepositoryImpl(sl()),
  );

  // FeedingLogs - Use Cases
  sl.registerLazySingleton(() => GetFeedingLogs(sl()));
  sl.registerLazySingleton(() => GetFeedingLogsByCat(sl()));
  sl.registerLazySingleton(() => GetFeedingLogById(sl()));
  sl.registerLazySingleton(() => GetTodayFeedingLogs(sl()));
  sl.registerLazySingleton(() => CreateFeedingLog(sl()));
  sl.registerLazySingleton(() => CreateFeedingLogsBatch(sl()));
  sl.registerLazySingleton(() => UpdateFeedingLog(sl()));
  sl.registerLazySingleton(() => DeleteFeedingLog(sl()));

  // FeedingLogs - BLoC
  sl.registerFactory(
    () => FeedingLogsBloc(
      getFeedingLogs: sl(),
      getFeedingLogsByCat: sl(),
      getFeedingLogById: sl(),
      getTodayFeedingLogs: sl(),
      createFeedingLog: sl(),
      createFeedingLogsBatch: sl(),
      updateFeedingLog: sl(),
      deleteFeedingLog: sl(),
    ),
  );
}
