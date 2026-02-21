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
  String get common_moreOptions => 'Más opciones';

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
  String get cats_birthDateNotInformed => 'No informada';

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
  String get home_hello => 'Hola';

  @override
  String get home_food_dry => 'Comida Seca';

  @override
  String get home_food_wet => 'Comida Húmeda';

  @override
  String get home_food_homemade => 'Comida Casera';

  @override
  String get home_food_sachet => 'Sobrecito';

  @override
  String get home_food_treat => 'Golosina';

  @override
  String get home_food_not_specified => 'Alimento no especificado';

  @override
  String get home_fed_by_you => 'Tú';

  @override
  String get home_fed_by_other => 'Otro usuario';

  @override
  String home_fed_by(String name) {
    return 'Alimentado por $name';
  }

  @override
  String get home_no_feeding_records => 'No hay registros de alimentación';

  @override
  String get home_last_7_days => 'Últimos 7 días';

  @override
  String get home_register_feeding_chart =>
      'Registra alimentaciones para ver el gráfico de los últimos 7 días';

  @override
  String get home_recent_records => 'Registros Recientes';

  @override
  String get home_no_recent_records => 'No hay registros recientes';

  @override
  String get home_see_all_cats => 'Ver todos los gatos';

  @override
  String get home_no_cats_registered => 'No hay gatos registrados';

  @override
  String get home_feedings_title => 'Alimentaciones';

  @override
  String get home_last_feeding_title => 'Última Alimentación';

  @override
  String get home_average_portion => 'Porción Promedio';

  @override
  String get home_today => 'Hoy';

  @override
  String get home_total_cats => 'Total de Gatos';

  @override
  String get home_last_time => 'Última Vez';

  @override
  String get home_active_cats => 'Activos';

  @override
  String get home_average_portion_subtitle => 'Últimos 7 días';

  @override
  String get home_last_time_subtitle => 'Último registro';

  @override
  String home_amount_food_type(String amount, String foodType) {
    return '${amount}g de $foodType';
  }

  @override
  String get home_no_feeding_recorded => 'No hay alimentación registrada';

  @override
  String get home_cat_name_not_found => 'Nombre no encontrado';

  @override
  String get home_my_cats => 'Mis Gatos';

  @override
  String home_cat_weight(String weight) {
    return '${weight}kg';
  }

  @override
  String get home_cat_weight_unknown => 'Desconocido';

  @override
  String get home_no_cats_register_first =>
      'No hay gatos registrados. Registra un gato primero.';

  @override
  String get home_register_feeding => 'Registrar Alimentación';

  @override
  String get auth_welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get auth_managementDescription => 'Gestión de alimentación para gatos';

  @override
  String get auth_passwordPlaceholder => 'Contraseña';

  @override
  String get auth_alreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get auth_noAccount => '¿No tienes una cuenta? ';

  @override
  String get auth_signInShort => 'Iniciar sesión';

  @override
  String get auth_registerShort => 'Crear cuenta';

  @override
  String get auth_featureInDevelopment => 'Función en desarrollo';

  @override
  String get auth_registerInDevelopment => 'Función de registro en desarrollo';

  @override
  String get auth_signInWithGoogle => 'Entrar con Google';

  @override
  String get profile_accountInfo => 'Información de la Cuenta';

  @override
  String get profile_userInfo => 'Información del Usuario';

  @override
  String get profile_usernameLabel => 'Nombre de usuario';

  @override
  String get profile_website => 'Sitio web';

  @override
  String get profile_updateProfile => 'Actualizar Perfil';

  @override
  String get profile_userId => 'ID de Usuario';

  @override
  String get profile_accountStatus => 'Estado de la Cuenta';

  @override
  String get profile_verified => 'Verificado';

  @override
  String get profile_notVerified => 'No verificado';

  @override
  String get profile_accountCreated => 'Cuenta creada el';

  @override
  String get profile_lastAccess => 'Último acceso';

  @override
  String get profile_logoutErrorGeneric => 'Error al cerrar sesión';

  @override
  String get statistics_title => 'Estadísticas';

  @override
  String get statistics_loading => 'Cargando estadísticas...';

  @override
  String get statistics_errorLoading => 'Error al cargar estadísticas';

  @override
  String get statistics_noData => 'No hay datos disponibles';

  @override
  String get statistics_noDataPeriod =>
      'No hay alimentaciones registradas en el período seleccionado.';

  @override
  String get statistics_chartError => 'Error al renderizar el gráfico';

  @override
  String get notifications_title => 'Notificaciones';

  @override
  String get notifications_markedAsRead => 'Notificación marcada como leída';

  @override
  String notifications_errorMarkAsRead(String error) {
    return 'Error al marcar como leída: $error';
  }

  @override
  String get notifications_allMarkedAsRead =>
      'Todas las notificaciones marcadas como leídas';

  @override
  String notifications_errorMarkAllAsRead(String error) {
    return 'Error al marcar todas como leídas: $error';
  }

  @override
  String get notifications_removed => 'Notificación eliminada';

  @override
  String notifications_errorRemove(String error) {
    return 'Error al eliminar notificación: $error';
  }

  @override
  String get notifications_tryAgain => 'Intentar de nuevo';

  @override
  String get notifications_markAllAsRead => 'Marcar todas como leídas';

  @override
  String get notifications_empty => 'Sin notificaciones';

  @override
  String get notifications_emptySubtitle => '¡Estás al día!';

  @override
  String get notifications_refresh => 'Actualizar';

  @override
  String get notifications_delete => 'Eliminar notificación';

  @override
  String get notifications_userNotAuthenticated => 'Usuario no autenticado';

  @override
  String notifications_errorLoading(String error) {
    return 'Error al cargar notificaciones: $error';
  }

  @override
  String get auth_pleaseEnterEmail =>
      'Por favor, ingresa tu correo electrónico';

  @override
  String get auth_pleaseEnterPassword => 'Por favor, ingresa tu contraseña';

  @override
  String get auth_pleaseEnterFullName =>
      'Por favor, ingresa tu nombre completo';
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
  String get common_moreOptions => 'Más opciones';

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
  String get cats_birthDateNotInformed => 'No informada';

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
  String get home_hello => 'Hola';

  @override
  String get home_food_dry => 'Comida Seca';

  @override
  String get home_food_wet => 'Comida Húmeda';

  @override
  String get home_food_homemade => 'Comida Casera';

  @override
  String get home_food_sachet => 'Sobrecito';

  @override
  String get home_food_treat => 'Golosina';

  @override
  String get home_food_not_specified => 'Alimento no especificado';

  @override
  String get home_fed_by_you => 'Tú';

  @override
  String get home_fed_by_other => 'Otro usuario';

  @override
  String home_fed_by(String name) {
    return 'Alimentado por $name';
  }

  @override
  String get home_no_feeding_records => 'No hay registros de alimentación';

  @override
  String get home_last_7_days => 'Últimos 7 días';

  @override
  String get home_register_feeding_chart =>
      'Registra alimentaciones para ver el gráfico de los últimos 7 días';

  @override
  String get home_recent_records => 'Registros Recientes';

  @override
  String get home_no_recent_records => 'No hay registros recientes';

  @override
  String get home_see_all_cats => 'Ver todos los gatos';

  @override
  String get home_no_cats_registered => 'No hay gatos registrados';

  @override
  String get home_feedings_title => 'Alimentaciones';

  @override
  String get home_last_feeding_title => 'Última Alimentación';

  @override
  String get home_average_portion => 'Porción Promedio';

  @override
  String get home_today => 'Hoy';

  @override
  String get home_total_cats => 'Total de Gatos';

  @override
  String get home_last_time => 'Última Vez';

  @override
  String get home_active_cats => 'Activos';

  @override
  String get home_average_portion_subtitle => 'Últimos 7 días';

  @override
  String get home_last_time_subtitle => 'Último registro';

  @override
  String home_amount_food_type(String amount, String foodType) {
    return '${amount}g de $foodType';
  }

  @override
  String get home_no_feeding_recorded => 'No hay alimentación registrada';

  @override
  String get home_cat_name_not_found => 'Nombre no encontrado';

  @override
  String get home_my_cats => 'Mis Gatos';

  @override
  String home_cat_weight(String weight) {
    return '${weight}kg';
  }

  @override
  String get home_cat_weight_unknown => 'Desconocido';

  @override
  String get home_no_cats_register_first =>
      'No hay gatos registrados. Registra un gato primero.';

  @override
  String get home_register_feeding => 'Registrar Alimentación';

  @override
  String get auth_welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get auth_managementDescription => 'Gestión de alimentación para gatos';

  @override
  String get auth_passwordPlaceholder => 'Contraseña';

  @override
  String get auth_alreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get auth_noAccount => '¿No tienes una cuenta? ';

  @override
  String get auth_signInShort => 'Iniciar sesión';

  @override
  String get auth_registerShort => 'Crear cuenta';

  @override
  String get auth_featureInDevelopment => 'Función en desarrollo';

  @override
  String get auth_registerInDevelopment => 'Función de registro en desarrollo';

  @override
  String get auth_signInWithGoogle => 'Entrar con Google';

  @override
  String get profile_accountInfo => 'Información de la Cuenta';

  @override
  String get profile_userInfo => 'Información del Usuario';

  @override
  String get profile_usernameLabel => 'Nombre de usuario';

  @override
  String get profile_website => 'Sitio web';

  @override
  String get profile_updateProfile => 'Actualizar Perfil';

  @override
  String get profile_userId => 'ID de Usuario';

  @override
  String get profile_accountStatus => 'Estado de la Cuenta';

  @override
  String get profile_verified => 'Verificado';

  @override
  String get profile_notVerified => 'No verificado';

  @override
  String get profile_accountCreated => 'Cuenta creada el';

  @override
  String get profile_lastAccess => 'Último acceso';

  @override
  String get profile_logoutErrorGeneric => 'Error al cerrar sesión';

  @override
  String get statistics_title => 'Estadísticas';

  @override
  String get statistics_loading => 'Cargando estadísticas...';

  @override
  String get statistics_errorLoading => 'Error al cargar estadísticas';

  @override
  String get statistics_noData => 'No hay datos disponibles';

  @override
  String get statistics_noDataPeriod =>
      'No hay alimentaciones registradas en el período seleccionado.';

  @override
  String get statistics_chartError => 'Error al renderizar el gráfico';

  @override
  String get notifications_title => 'Notificaciones';

  @override
  String get notifications_markedAsRead => 'Notificación marcada como leída';

  @override
  String notifications_errorMarkAsRead(String error) {
    return 'Error al marcar como leída: $error';
  }

  @override
  String get notifications_allMarkedAsRead =>
      'Todas las notificaciones marcadas como leídas';

  @override
  String notifications_errorMarkAllAsRead(String error) {
    return 'Error al marcar todas como leídas: $error';
  }

  @override
  String get notifications_removed => 'Notificación eliminada';

  @override
  String notifications_errorRemove(String error) {
    return 'Error al eliminar notificación: $error';
  }

  @override
  String get notifications_tryAgain => 'Intentar de nuevo';

  @override
  String get notifications_markAllAsRead => 'Marcar todas como leídas';

  @override
  String get notifications_empty => 'Sin notificaciones';

  @override
  String get notifications_emptySubtitle => '¡Estás al día!';

  @override
  String get notifications_refresh => 'Actualizar';

  @override
  String get notifications_delete => 'Eliminar notificación';

  @override
  String get notifications_userNotAuthenticated => 'Usuario no autenticado';

  @override
  String notifications_errorLoading(String error) {
    return 'Error al cargar notificaciones: $error';
  }

  @override
  String get auth_pleaseEnterEmail =>
      'Por favor, ingresa tu correo electrónico';

  @override
  String get auth_pleaseEnterPassword => 'Por favor, ingresa tu contraseña';

  @override
  String get auth_pleaseEnterFullName =>
      'Por favor, ingresa tu nombre completo';
}
