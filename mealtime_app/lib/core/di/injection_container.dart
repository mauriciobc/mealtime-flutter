import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/core/constants/api_constants.dart';
import 'package:mealtime_app/core/network/auth_interceptor.dart';
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
import 'package:mealtime_app/features/cats/data/repositories/cats_repository_impl.dart';
import 'package:mealtime_app/features/cats/domain/repositories/cats_repository.dart';
import 'package:mealtime_app/features/cats/domain/usecases/get_cats.dart';
import 'package:mealtime_app/features/cats/domain/usecases/get_cat_by_id.dart';
import 'package:mealtime_app/features/cats/domain/usecases/create_cat.dart';
import 'package:mealtime_app/features/cats/domain/usecases/update_cat.dart';
import 'package:mealtime_app/features/cats/domain/usecases/delete_cat.dart';
import 'package:mealtime_app/features/cats/domain/usecases/update_cat_weight.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/services/api/meals_api_service.dart';
import 'package:mealtime_app/features/meals/data/datasources/meals_remote_datasource.dart';
import 'package:mealtime_app/features/meals/data/repositories/meals_repository_impl.dart';
import 'package:mealtime_app/features/meals/domain/repositories/meals_repository.dart';
import 'package:mealtime_app/features/meals/domain/usecases/get_meals.dart';
import 'package:mealtime_app/features/meals/domain/usecases/get_meals_by_cat.dart';
import 'package:mealtime_app/features/meals/domain/usecases/get_meal_by_id.dart';
import 'package:mealtime_app/features/meals/domain/usecases/get_today_meals.dart';
import 'package:mealtime_app/features/meals/domain/usecases/create_meal.dart';
import 'package:mealtime_app/features/meals/domain/usecases/update_meal.dart';
import 'package:mealtime_app/features/meals/domain/usecases/delete_meal.dart';
import 'package:mealtime_app/features/meals/domain/usecases/complete_meal.dart';
import 'package:mealtime_app/features/meals/domain/usecases/skip_meal.dart';
import 'package:mealtime_app/features/meals/presentation/bloc/meals_bloc.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Supabase
  sl.registerLazySingleton(() => SupabaseConfig.client);

  // Dio - Configurado com interceptors
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
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: true, error: true),
  );
  sl.registerLazySingleton(() => dio);

  // API Client
  sl.registerLazySingleton(() => ApiClient(sl()));

  // API Services
  sl.registerLazySingleton(() => AuthApiService(sl()));
  sl.registerLazySingleton(() => CatsApiService(sl()));
  sl.registerLazySingleton(() => MealsApiService(sl()));
  sl.registerLazySingleton(() => HomesApiService(sl()));

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

  sl.registerLazySingleton<MealsRemoteDataSource>(
    () => MealsRemoteDataSourceImpl(apiService: sl()),
  );

  sl.registerLazySingleton<HomesRemoteDataSource>(
    () => HomesRemoteDataSourceImpl(apiService: sl()),
  );

  sl.registerLazySingleton<HomesLocalDataSource>(
    () => HomesLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<CatsRepository>(
    () => CatsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<MealsRepository>(
    () => MealsRepositoryImpl(sl()),
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

  sl.registerLazySingleton(() => GetMeals(sl()));
  sl.registerLazySingleton(() => GetMealsByCat(sl()));
  sl.registerLazySingleton(() => GetMealById(sl()));
  sl.registerLazySingleton(() => GetTodayMeals(sl()));
  sl.registerLazySingleton(() => CreateMeal(sl()));
  sl.registerLazySingleton(() => UpdateMeal(sl()));
  sl.registerLazySingleton(() => DeleteMeal(sl()));
  sl.registerLazySingleton(() => CompleteMeal(sl()));
  sl.registerLazySingleton(() => SkipMeal(sl()));

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
    () => MealsBloc(
      getMeals: sl(),
      getMealsByCat: sl(),
      getMealById: sl(),
      getTodayMeals: sl(),
      createMeal: sl(),
      updateMeal: sl(),
      deleteMeal: sl(),
      completeMeal: sl(),
      skipMeal: sl(),
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
}
