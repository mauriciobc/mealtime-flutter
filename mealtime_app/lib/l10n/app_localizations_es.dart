// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MealTime';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_create => 'Crear';

  @override
  String get common_update => 'Actualizar';

  @override
  String get common_loading => 'Cargando...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Éxito';

  @override
  String get common_retry => 'Intentar de nuevo';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_ok => 'OK';

  @override
  String get common_yes => 'Sí';

  @override
  String get common_no => 'No';

  @override
  String get common_back => 'Volver';

  @override
  String get common_next => 'Siguiente';

  @override
  String get common_previous => 'Anterior';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_refresh => 'Actualizar';

  @override
  String get common_filter => 'Filtrar';

  @override
  String get common_clear => 'Limpiar';

  @override
  String get common_required => 'Obligatorio';

  @override
  String get common_optional => 'Opcional';

  @override
  String get common_name => 'Nombre';

  @override
  String get common_email => 'Correo electrónico';

  @override
  String get common_password => 'Contraseña';

  @override
  String get common_description => 'Descripción';

  @override
  String get common_date => 'Fecha';

  @override
  String get common_time => 'Hora';

  @override
  String get common_weight => 'Peso';

  @override
  String get common_actions => 'Acciones';

  @override
  String get navigation_home => 'Inicio';

  @override
  String get navigation_cats => 'Gatos';

  @override
  String get navigation_weight => 'Peso';

  @override
  String get navigation_statistics => 'Estadísticas';

  @override
  String get navigation_profile => 'Perfil';

  @override
  String get navigation_notifications => 'Notificaciones';

  @override
  String get auth_logout => 'Cerrar sesión';

  @override
  String get auth_register => 'Crear cuenta';

  @override
  String get auth_signIn => 'Iniciar sesión';

  @override
  String get auth_signUp => 'Registrarse';

  @override
  String get auth_forgotPassword => 'Olvidé mi contraseña';

  @override
  String get auth_fullName => 'Nombre completo';

  @override
  String get auth_nameRequired => 'El nombre es obligatorio';

  @override
  String get auth_nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get auth_emailRequired => 'El correo electrónico es obligatorio';

  @override
  String get auth_emailInvalid => 'Correo electrónico inválido';

  @override
  String get auth_passwordRequired => 'La contraseña es obligatoria';

  @override
  String get auth_passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get auth_confirmPassword => 'Confirmar contraseña';

  @override
  String get auth_passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get auth_userNotAuthenticated => 'Usuario no autenticado';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_editProfile => 'Editar perfil';

  @override
  String get profile_profileNotFound => 'Perfil no encontrado';

  @override
  String get profile_reload => 'Recargar';

  @override
  String get profile_profileUpdated => '¡Perfil actualizado con éxito!';

  @override
  String get profile_errorUpdating => 'Error al actualizar el perfil';

  @override
  String get profile_confirmLogout => 'Confirmar cierre de sesión';

  @override
  String get profile_logoutConfirmation =>
      '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get profile_logoutError => 'Error al cerrar sesión';

  @override
  String get profile_user => 'Usuario';

  @override
  String get cats_title => 'Mis Gatos';

  @override
  String get cats_create => 'Nuevo Gato';

  @override
  String get cats_edit => 'Editar Gato';

  @override
  String get cats_name => 'Nombre *';

  @override
  String get cats_nameHint => 'Ingrese el nombre del gato';

  @override
  String get cats_nameRequired => 'El nombre es obligatorio';

  @override
  String get cats_breed => 'Raza';

  @override
  String get cats_breedHint => 'Ej.: Persa, Siamés, Mestizo';

  @override
  String get cats_gender => 'Género';

  @override
  String get cats_color => 'Color';

  @override
  String get cats_birthDate => 'Fecha de nacimiento';

  @override
  String get cats_currentWeight => 'Peso Actual (kg)';

  @override
  String get cats_targetWeight => 'Peso Objetivo (kg)';

  @override
  String get cats_updateWeight => 'Actualizar Peso';

  @override
  String get cats_saveCat => 'Guardar Gato';

  @override
  String get cats_createCat => 'Crear Gato';

  @override
  String get cats_catCreated => '¡Gato creado con éxito!';

  @override
  String get cats_catUpdated => '¡Gato actualizado con éxito!';

  @override
  String get cats_catDeleted => '¡Gato eliminado con éxito!';

  @override
  String get cats_errorLoading => 'Error al cargar gatos';

  @override
  String get cats_emptyState => 'No hay gatos registrados';

  @override
  String get cats_emptyStateDescription =>
      'Toca el botón + para agregar tu primer gato';

  @override
  String get cats_addCat => 'Agregar Gato';

  @override
  String get cats_deleteCat => 'Eliminar Gato';

  @override
  String cats_deleteConfirmation(String name) {
    return '¿Estás seguro de que deseas eliminar $name?';
  }

  @override
  String get cats_addFirstCat => '¡Agrega tu primer gato para comenzar!';

  @override
  String get cats_genderMale => 'Macho';

  @override
  String get cats_genderFemale => 'Hembra';

  @override
  String get cats_birthDateRequired => 'Fecha de Nacimiento *';

  @override
  String get cats_selectDate => 'Seleccionar fecha';

  @override
  String get cats_invalidWeight => 'Peso inválido';

  @override
  String get cats_descriptionHint => 'Información adicional sobre el gato';

  @override
  String get homes_title => 'Hogares';

  @override
  String get homes_create => 'Nuevo Hogar';

  @override
  String get homes_edit => 'Editar Hogar';

  @override
  String get homes_info => 'Información del Hogar';

  @override
  String get homes_name => 'Nombre';

  @override
  String get homes_description => 'Descripción';

  @override
  String get homes_address => 'Dirección';

  @override
  String get homes_createHome => 'Crear Hogar';

  @override
  String get homes_homeCreated => '¡Hogar creado con éxito!';

  @override
  String get homes_homeUpdated => '¡Hogar actualizado con éxito!';

  @override
  String get homes_homeDeleted => '¡Hogar eliminado con éxito!';

  @override
  String get homes_nameRequired => 'Nombre del Hogar *';

  @override
  String get homes_nameHint => 'Ej.: Casa Principal, Apartamento, Finca...';

  @override
  String get homes_nameRequiredError => 'El nombre del hogar es obligatorio';

  @override
  String get homes_nameMinLength =>
      'El nombre debe tener al menos 2 caracteres';

  @override
  String get homes_descriptionHint => 'Información adicional sobre el hogar...';

  @override
  String get homes_requiredFields => '* Campos obligatorios';

  @override
  String get error_generic => '¡Ups! Algo salió mal';

  @override
  String get error_loading => 'Error al cargar';

  @override
  String get error_network => 'Error de conexión';

  @override
  String get error_server => 'Error del servidor';

  @override
  String get error_notFound => 'No encontrado';

  @override
  String get error_unauthorized => 'No autorizado';

  @override
  String get error_validation => 'Error de validación';

  @override
  String get error_tryAgain => 'Intentar de Nuevo';

  @override
  String get home_hello => 'Olá';

  @override
  String get home_food_dry => 'Ração Seca';

  @override
  String get home_food_wet => 'Ração Úmida';

  @override
  String get home_food_homemade => 'Comida Caseira';

  @override
  String get home_food_not_specified => 'Alimento não especificado';

  @override
  String get home_fed_by_you => 'Você';

  @override
  String get home_fed_by_other => 'Outro usuário';

  @override
  String home_fed_by(String name) {
    return 'Alimentado por $name';
  }

  @override
  String get home_no_feeding_records => 'Nenhum registro de alimentação';

  @override
  String get home_last_7_days => 'Últimos 7 dias';

  @override
  String get home_register_feeding_chart =>
      'Registre alimentações para ver o gráfico dos últimos 7 dias';

  @override
  String get home_recent_records => 'Registros Recentes';

  @override
  String get home_no_recent_records => 'Nenhum registro recente';

  @override
  String get home_see_all_cats => 'Ver todos os gatos';

  @override
  String get home_no_cats_registered => 'Nenhum gato cadastrado';

  @override
  String get home_feedings_title => 'Alimentações';

  @override
  String get home_last_feeding_title => 'Última Alimentação';

  @override
  String get home_average_portion => 'Porção Média';

  @override
  String get home_today => 'Hoje';

  @override
  String get home_total_cats => 'Total de Gatos';

  @override
  String get home_last_time => 'Última Vez';

  @override
  String get home_active_cats => 'Ativos';

  @override
  String get home_average_portion_subtitle => 'Últimos 7 dias';

  @override
  String get home_last_time_subtitle => 'Último registro';

  @override
  String home_amount_food_type(String amount, String foodType) {
    return '${amount}g de $foodType';
  }

  @override
  String home_fed_by_user(String name) {
    return 'Alimentado por $name';
  }

  @override
  String get home_no_feeding_recorded => 'Nenhuma alimentação registrada';

  @override
  String get home_cat_name_not_found => 'Nome não encontrado';

  @override
  String get home_my_cats => 'Meus Gatos';

  @override
  String home_cat_weight(String weight) {
    return '${weight}kg';
  }

  @override
  String get home_no_cats_register_first =>
      'Nenhum gato cadastrado. Cadastre um gato primeiro.';

  @override
  String get home_register_feeding => 'Registrar Alimentação';

  @override
  String get auth_welcomeBack => 'Bem-vindo de volta!';

  @override
  String get auth_managementDescription =>
      'Gerenciamento de alimentação para gatos';

  @override
  String get auth_passwordPlaceholder => 'Senha';

  @override
  String get auth_alreadyHaveAccount => 'Já tem uma conta? ';

  @override
  String get auth_noAccount => 'Não tem uma conta? ';

  @override
  String get auth_signInShort => 'Entrar';

  @override
  String get auth_registerShort => 'Criar conta';

  @override
  String get auth_featureInDevelopment => 'Funcionalidade em desenvolvimento';

  @override
  String get auth_registerInDevelopment =>
      'Funcionalidade de cadastro em desenvolvimento';

  @override
  String get profile_accountInfo => 'Informações da Conta';

  @override
  String get profile_userInfo => 'Informações do Usuário';

  @override
  String get profile_usernameLabel => 'Nome de usuário';

  @override
  String get profile_website => 'Website';

  @override
  String get profile_updateProfile => 'Atualizar Perfil';

  @override
  String get profile_userId => 'ID do Usuário';

  @override
  String get profile_accountStatus => 'Status da Conta';

  @override
  String get profile_verified => 'Verificado';

  @override
  String get profile_notVerified => 'Não verificado';

  @override
  String get profile_accountCreated => 'Conta criada em';

  @override
  String get profile_lastAccess => 'Último acesso';

  @override
  String get profile_logoutErrorGeneric => 'Erro ao fazer logout';

  @override
  String get statistics_title => 'Estatísticas';

  @override
  String get statistics_loading => 'Carregando estatísticas...';

  @override
  String get statistics_errorLoading => 'Erro ao carregar estatísticas';

  @override
  String get statistics_noData => 'Nenhum dado disponível';

  @override
  String get statistics_noDataPeriod =>
      'Não há alimentações registradas no período selecionado.';

  @override
  String get statistics_chartError => 'Erro ao renderizar gráfico';

  @override
  String get notifications_title => 'Notificações';

  @override
  String get notifications_markedAsRead => 'Notificação marcada como lida';

  @override
  String notifications_errorMarkAsRead(String error) {
    return 'Erro ao marcar como lida: $error';
  }

  @override
  String get notifications_allMarkedAsRead =>
      'Todas as notificações foram marcadas como lidas';

  @override
  String notifications_errorMarkAllAsRead(String error) {
    return 'Erro ao marcar todas como lidas: $error';
  }

  @override
  String get notifications_removed => 'Notificação removida';

  @override
  String notifications_errorRemove(String error) {
    return 'Erro ao remover notificação: $error';
  }

  @override
  String get notifications_tryAgain => 'Tentar novamente';

  @override
  String get notifications_markAllAsRead => 'Marcar todas como lidas';

  @override
  String get notifications_empty => 'Nenhuma notificação';

  @override
  String get notifications_emptySubtitle => 'Você está em dia!';

  @override
  String get notifications_refresh => 'Atualizar';

  @override
  String get notifications_delete => 'Deletar notificação';

  @override
  String get notifications_userNotAuthenticated => 'Usuário não autenticado';

  @override
  String notifications_errorLoading(String error) {
    return 'Erro ao carregar notificações: $error';
  }

  @override
  String get auth_pleaseEnterEmail => 'Por favor, digite seu email';

  @override
  String get auth_pleaseEnterPassword => 'Por favor, digite sua senha';

  @override
  String get auth_pleaseEnterFullName => 'Por favor, digite seu nome completo';
}

/// The translations for Spanish Castilian, as used in Spain (`es_ES`).
class AppLocalizationsEsEs extends AppLocalizationsEs {
  AppLocalizationsEsEs() : super('es_ES');

  @override
  String get appTitle => 'MealTime';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_create => 'Crear';

  @override
  String get common_update => 'Actualizar';

  @override
  String get common_loading => 'Cargando...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Éxito';

  @override
  String get common_retry => 'Intentar de nuevo';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_ok => 'OK';

  @override
  String get common_yes => 'Sí';

  @override
  String get common_no => 'No';

  @override
  String get common_back => 'Volver';

  @override
  String get common_next => 'Siguiente';

  @override
  String get common_previous => 'Anterior';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_refresh => 'Actualizar';

  @override
  String get common_filter => 'Filtrar';

  @override
  String get common_clear => 'Limpiar';

  @override
  String get common_required => 'Obligatorio';

  @override
  String get common_optional => 'Opcional';

  @override
  String get common_name => 'Nombre';

  @override
  String get common_email => 'Correo electrónico';

  @override
  String get common_password => 'Contraseña';

  @override
  String get common_description => 'Descripción';

  @override
  String get common_date => 'Fecha';

  @override
  String get common_time => 'Hora';

  @override
  String get common_weight => 'Peso';

  @override
  String get common_actions => 'Acciones';

  @override
  String get navigation_home => 'Inicio';

  @override
  String get navigation_cats => 'Gatos';

  @override
  String get navigation_weight => 'Peso';

  @override
  String get navigation_statistics => 'Estadísticas';

  @override
  String get navigation_profile => 'Perfil';

  @override
  String get navigation_notifications => 'Notificaciones';

  @override
  String get auth_logout => 'Cerrar sesión';

  @override
  String get auth_register => 'Crear cuenta';

  @override
  String get auth_signIn => 'Iniciar sesión';

  @override
  String get auth_signUp => 'Registrarse';

  @override
  String get auth_forgotPassword => 'Olvidé mi contraseña';

  @override
  String get auth_fullName => 'Nombre completo';

  @override
  String get auth_nameRequired => 'El nombre es obligatorio';

  @override
  String get auth_nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get auth_emailRequired => 'El correo electrónico es obligatorio';

  @override
  String get auth_emailInvalid => 'Correo electrónico inválido';

  @override
  String get auth_passwordRequired => 'La contraseña es obligatoria';

  @override
  String get auth_passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get auth_confirmPassword => 'Confirmar contraseña';

  @override
  String get auth_passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get auth_userNotAuthenticated => 'Usuario no autenticado';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_editProfile => 'Editar perfil';

  @override
  String get profile_profileNotFound => 'Perfil no encontrado';

  @override
  String get profile_reload => 'Recargar';

  @override
  String get profile_profileUpdated => '¡Perfil actualizado con éxito!';

  @override
  String get profile_errorUpdating => 'Error al actualizar el perfil';

  @override
  String get profile_confirmLogout => 'Confirmar cierre de sesión';

  @override
  String get profile_logoutConfirmation =>
      '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get profile_logoutError => 'Error al cerrar sesión';

  @override
  String get profile_user => 'Usuario';

  @override
  String get cats_title => 'Mis Gatos';

  @override
  String get cats_create => 'Nuevo Gato';

  @override
  String get cats_edit => 'Editar Gato';

  @override
  String get cats_name => 'Nombre *';

  @override
  String get cats_nameHint => 'Ingrese el nombre del gato';

  @override
  String get cats_nameRequired => 'El nombre es obligatorio';

  @override
  String get cats_breed => 'Raza';

  @override
  String get cats_breedHint => 'Ej.: Persa, Siamés, Mestizo';

  @override
  String get cats_gender => 'Género';

  @override
  String get cats_color => 'Color';

  @override
  String get cats_birthDate => 'Fecha de nacimiento';

  @override
  String get cats_currentWeight => 'Peso Actual (kg)';

  @override
  String get cats_targetWeight => 'Peso Objetivo (kg)';

  @override
  String get cats_updateWeight => 'Actualizar Peso';

  @override
  String get cats_saveCat => 'Guardar Gato';

  @override
  String get cats_createCat => 'Crear Gato';

  @override
  String get cats_catCreated => '¡Gato creado con éxito!';

  @override
  String get cats_catUpdated => '¡Gato actualizado con éxito!';

  @override
  String get cats_catDeleted => '¡Gato eliminado con éxito!';

  @override
  String get cats_errorLoading => 'Error al cargar gatos';

  @override
  String get cats_emptyState => 'No hay gatos registrados';

  @override
  String get cats_emptyStateDescription =>
      'Toca el botón + para agregar tu primer gato';

  @override
  String get cats_addCat => 'Agregar Gato';

  @override
  String get cats_deleteCat => 'Eliminar Gato';

  @override
  String cats_deleteConfirmation(String name) {
    return '¿Estás seguro de que deseas eliminar $name?';
  }

  @override
  String get cats_addFirstCat => '¡Agrega tu primer gato para comenzar!';

  @override
  String get cats_genderMale => 'Macho';

  @override
  String get cats_genderFemale => 'Hembra';

  @override
  String get cats_birthDateRequired => 'Fecha de Nacimiento *';

  @override
  String get cats_selectDate => 'Seleccionar fecha';

  @override
  String get cats_invalidWeight => 'Peso inválido';

  @override
  String get cats_descriptionHint => 'Información adicional sobre el gato';

  @override
  String get homes_title => 'Hogares';

  @override
  String get homes_create => 'Nuevo Hogar';

  @override
  String get homes_edit => 'Editar Hogar';

  @override
  String get homes_info => 'Información del Hogar';

  @override
  String get homes_name => 'Nombre';

  @override
  String get homes_description => 'Descripción';

  @override
  String get homes_address => 'Dirección';

  @override
  String get homes_createHome => 'Crear Hogar';

  @override
  String get homes_homeCreated => '¡Hogar creado con éxito!';

  @override
  String get homes_homeUpdated => '¡Hogar actualizado con éxito!';

  @override
  String get homes_homeDeleted => '¡Hogar eliminado con éxito!';

  @override
  String get homes_nameRequired => 'Nombre del Hogar *';

  @override
  String get homes_nameHint => 'Ej.: Casa Principal, Apartamento, Finca...';

  @override
  String get homes_nameRequiredError => 'El nombre del hogar es obligatorio';

  @override
  String get homes_nameMinLength =>
      'El nombre debe tener al menos 2 caracteres';

  @override
  String get homes_descriptionHint => 'Información adicional sobre el hogar...';

  @override
  String get homes_requiredFields => '* Campos obligatorios';

  @override
  String get error_generic => '¡Ups! Algo salió mal';

  @override
  String get error_loading => 'Error al cargar';

  @override
  String get error_network => 'Error de conexión';

  @override
  String get error_server => 'Error del servidor';

  @override
  String get error_notFound => 'No encontrado';

  @override
  String get error_unauthorized => 'No autorizado';

  @override
  String get error_validation => 'Error de validación';

  @override
  String get error_tryAgain => 'Intentar de Nuevo';
}
