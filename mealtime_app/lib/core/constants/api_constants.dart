class ApiConstants {
  // ✅ Base URLs
  static const String baseUrl = 'https://mealtime.app.br/api';
  static const String baseUrlV2 = 'https://mealtime.app.br/api/v2';

  // ✅ Endpoints de autenticação - corrigidos conforme documentação
  static const String login = '/auth/mobile';
  static const String register = '/auth/mobile/register';
  static const String refreshToken = '/auth/mobile'; // PUT method para refresh
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // ✅ V2 - Cats endpoints
  static const String v2Cats = '/cats';
  static String v2CatNextFeeding(String catId) => '/cats/$catId/next-feeding';
  
  // ❌ V1 - Cats endpoints (DEPRECATED - será removido em 28/07/2025)
  static const String cats = '/cats';
  static String catById(String id) => '/cats/$id';
  // ⚠️ REMOVIDO: /cats/$catId/meals não existe no backend
  // ⚠️ REMOVIDO: /cats/$catId/weight não existe no backend

  // ❌ REMOVIDO: Meals endpoints NÃO EXISTEM no backend
  // O backend usa /schedules para agendamentos de refeições
  // Use schedules abaixo em vez de meals

  // ✅ V2 - Feedings endpoints
  static const String v2Feedings = '/feedings';
  static String v2FeedingById(String id) => '/feedings/$id';
  static const String v2FeedingStats = '/feedings/stats';

  // ✅ V2 - Schedules endpoints  
  static const String v2Schedules = '/schedules';
  static String v2ScheduleById(String id) => '/schedules/$id';

  // ✅ V2 - Weight Logs endpoints
  static const String v2WeightLogs = '/weight-logs';

  // ✅ V2 - Goals endpoints
  static const String v2Goals = '/goals';

  // ✅ V2 - Profile endpoints
  static String v2Profile(String idOrUsername) => '/profile/$idOrUsername';
  static const String v2Upload = '/upload';

  // ✅ V2 - Households endpoints
  static String v2HouseholdCats(String householdId) => '/households/$householdId/cats';
  static String v2HouseholdInvite(String householdId) => '/households/$householdId/invite';
  static String v2HouseholdInviteCode(String householdId) => '/households/$householdId/invite-code';

  // ❌ V1 - Feeding Logs endpoints (DEPRECATED - será removido em 28/07/2025)
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

  // ✅ Schedule endpoints (CONFIRMADO: existe no backend)
  // Substitui o antigo /meals que não existe
  // GET /schedules?householdId=xxx - listar agendamentos
  // POST /schedules - criar agendamento
  // PUT /schedules/:id - atualizar agendamento  
  // DELETE /schedules/:id - deletar agendamento
  static const String schedules = '/schedules';
  static String scheduleById(String id) => '/schedules/$id';
}
