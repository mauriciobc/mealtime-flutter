class ApiConstants {
  // ✅ Base URL confirmada - compatível com documentação
  static const String baseUrl = 'https://mealtime.app.br/api';

  // ✅ Endpoints de autenticação - corrigidos conforme documentação
  static const String login = '/auth/mobile';
  static const String register = '/auth/mobile/register';
  static const String refreshToken = '/auth/mobile'; // PUT method para refresh
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Cats endpoints
  static const String cats = '/cats';
  static String catById(String id) => '/cats/$id';
  static String catMeals(String catId) => '/cats/$catId/meals';
  static String catWeightHistory(String catId) => '/cats/$catId/weight';

  // ✅ Feeding Logs endpoints (renomeado de meals)
  static const String feedingLogs = '/feeding-logs';
  static String feedingLogById(String id) => '/feeding-logs/$id';
  static String lastFeeding(String catId) => '/feedings/last/$catId';
  static const String feedingStats = '/feedings/stats';

  // Households endpoints (migrado de /homes para /households)
  static const String households = '/households';
  static String householdById(String id) => '/households/$id';
  static String householdCats(String householdId) =>
      '/households/$householdId/cats';

  // Notifications endpoints
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const String notificationSettings = '/notifications/settings';

  // ✅ User endpoints (corrigido)
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String changePassword = '/profile/change-password';

  // ⚠️ Statistics endpoints - TEMPORARIAMENTE DESABILITADO (erro 500 na API)
  // static const String statistics = '/statistics';
  // static String catStatistics(String catId) => '/statistics/cats/$catId';
  // static String homeStatistics(String homeId) => '/statistics/homes/$homeId';

  // Weight tracking endpoints
  static const String weightLogs = '/weight/logs';
  static const String weightGoals = '/weight/goals';

  // ⚠️ Feeding logs antigos - removidos (duplicados, já definidos acima)
  // static const String feedingLogs = '/feeding-logs';
  // static String catFeedingLogs(String catId) => '/feeding-logs?cat_id=$catId';
  // static String lastFeeding(String catId) => '/feedings/last/$catId';
  // static const String feedingStats = '/feedings/stats';

  // ✅ Household management endpoints
  static String householdMembers(String homeId) =>
      '/households/$homeId/members';
  static String householdInvite(String homeId) => '/households/$homeId/invite';
  static const String householdJoin = '/households/join';
  static String householdInviteCode(String homeId) =>
      '/households/$homeId/invite-code';

  // Schedule endpoints
  static const String schedules = '/schedules';
  static String scheduleById(String id) => '/schedules/$id';
}
