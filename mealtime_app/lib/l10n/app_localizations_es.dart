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
