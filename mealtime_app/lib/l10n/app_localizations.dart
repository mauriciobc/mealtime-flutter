import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'US'),
    Locale('es'),
    Locale('es', 'ES'),
    Locale('fr'),
    Locale('fr', 'FR'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// Título do aplicativo
  ///
  /// In pt_BR, this message translates to:
  /// **'MealTime'**
  String get appTitle;

  /// No description provided for @common_save.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvar'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cancelar'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In pt_BR, this message translates to:
  /// **'Excluir'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar'**
  String get common_edit;

  /// No description provided for @common_create.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar'**
  String get common_create;

  /// No description provided for @common_update.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualizar'**
  String get common_update;

  /// No description provided for @common_loading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Carregando...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sucesso'**
  String get common_success;

  /// No description provided for @common_retry.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tentar novamente'**
  String get common_retry;

  /// No description provided for @common_confirm.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confirmar'**
  String get common_confirm;

  /// No description provided for @common_close.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fechar'**
  String get common_close;

  /// No description provided for @common_ok.
  ///
  /// In pt_BR, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_yes.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sim'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não'**
  String get common_no;

  /// No description provided for @common_back.
  ///
  /// In pt_BR, this message translates to:
  /// **'Voltar'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In pt_BR, this message translates to:
  /// **'Próximo'**
  String get common_next;

  /// No description provided for @common_previous.
  ///
  /// In pt_BR, this message translates to:
  /// **'Anterior'**
  String get common_previous;

  /// No description provided for @common_search.
  ///
  /// In pt_BR, this message translates to:
  /// **'Buscar'**
  String get common_search;

  /// No description provided for @common_refresh.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualizar'**
  String get common_refresh;

  /// No description provided for @common_filter.
  ///
  /// In pt_BR, this message translates to:
  /// **'Filtrar'**
  String get common_filter;

  /// No description provided for @common_clear.
  ///
  /// In pt_BR, this message translates to:
  /// **'Limpar'**
  String get common_clear;

  /// No description provided for @common_required.
  ///
  /// In pt_BR, this message translates to:
  /// **'Obrigatório'**
  String get common_required;

  /// No description provided for @common_optional.
  ///
  /// In pt_BR, this message translates to:
  /// **'Opcional'**
  String get common_optional;

  /// No description provided for @common_name.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome'**
  String get common_name;

  /// No description provided for @common_email.
  ///
  /// In pt_BR, this message translates to:
  /// **'E-mail'**
  String get common_email;

  /// No description provided for @common_password.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha'**
  String get common_password;

  /// No description provided for @common_description.
  ///
  /// In pt_BR, this message translates to:
  /// **'Descrição'**
  String get common_description;

  /// No description provided for @common_date.
  ///
  /// In pt_BR, this message translates to:
  /// **'Data'**
  String get common_date;

  /// No description provided for @common_time.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hora'**
  String get common_time;

  /// No description provided for @common_weight.
  ///
  /// In pt_BR, this message translates to:
  /// **'Peso'**
  String get common_weight;

  /// No description provided for @common_actions.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ações'**
  String get common_actions;

  /// No description provided for @navigation_home.
  ///
  /// In pt_BR, this message translates to:
  /// **'Início'**
  String get navigation_home;

  /// No description provided for @navigation_cats.
  ///
  /// In pt_BR, this message translates to:
  /// **'Gatos'**
  String get navigation_cats;

  /// No description provided for @navigation_weight.
  ///
  /// In pt_BR, this message translates to:
  /// **'Peso'**
  String get navigation_weight;

  /// No description provided for @navigation_statistics.
  ///
  /// In pt_BR, this message translates to:
  /// **'Estatísticas'**
  String get navigation_statistics;

  /// No description provided for @navigation_profile.
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfil'**
  String get navigation_profile;

  /// No description provided for @navigation_notifications.
  ///
  /// In pt_BR, this message translates to:
  /// **'Notificações'**
  String get navigation_notifications;

  /// No description provided for @auth_logout.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sair'**
  String get auth_logout;

  /// No description provided for @auth_register.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar Conta'**
  String get auth_register;

  /// No description provided for @auth_signIn.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entrar'**
  String get auth_signIn;

  /// No description provided for @auth_signUp.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cadastrar'**
  String get auth_signUp;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In pt_BR, this message translates to:
  /// **'Esqueci minha senha'**
  String get auth_forgotPassword;

  /// No description provided for @auth_fullName.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome completo'**
  String get auth_fullName;

  /// No description provided for @auth_nameRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome é obrigatório'**
  String get auth_nameRequired;

  /// No description provided for @auth_nameMinLength.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome deve ter pelo menos 2 caracteres'**
  String get auth_nameMinLength;

  /// No description provided for @auth_emailRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'E-mail é obrigatório'**
  String get auth_emailRequired;

  /// No description provided for @auth_emailInvalid.
  ///
  /// In pt_BR, this message translates to:
  /// **'E-mail inválido'**
  String get auth_emailInvalid;

  /// No description provided for @auth_passwordRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha é obrigatória'**
  String get auth_passwordRequired;

  /// No description provided for @auth_passwordMinLength.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha deve ter pelo menos 6 caracteres'**
  String get auth_passwordMinLength;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confirmar senha'**
  String get auth_confirmPassword;

  /// No description provided for @auth_passwordsDoNotMatch.
  ///
  /// In pt_BR, this message translates to:
  /// **'As senhas não coincidem'**
  String get auth_passwordsDoNotMatch;

  /// No description provided for @auth_userNotAuthenticated.
  ///
  /// In pt_BR, this message translates to:
  /// **'Usuário não autenticado'**
  String get auth_userNotAuthenticated;

  /// No description provided for @profile_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfil'**
  String get profile_title;

  /// No description provided for @profile_editProfile.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar perfil'**
  String get profile_editProfile;

  /// No description provided for @profile_profileNotFound.
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfil não encontrado'**
  String get profile_profileNotFound;

  /// No description provided for @profile_reload.
  ///
  /// In pt_BR, this message translates to:
  /// **'Recarregar'**
  String get profile_reload;

  /// No description provided for @profile_profileUpdated.
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfil atualizado com sucesso!'**
  String get profile_profileUpdated;

  /// No description provided for @profile_errorUpdating.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao atualizar perfil'**
  String get profile_errorUpdating;

  /// No description provided for @profile_confirmLogout.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confirmar logout'**
  String get profile_confirmLogout;

  /// No description provided for @profile_logoutConfirmation.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tem certeza que deseja sair?'**
  String get profile_logoutConfirmation;

  /// No description provided for @profile_logoutError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao fazer logout'**
  String get profile_logoutError;

  /// No description provided for @profile_user.
  ///
  /// In pt_BR, this message translates to:
  /// **'Usuário'**
  String get profile_user;

  /// No description provided for @cats_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Meus Gatos'**
  String get cats_title;

  /// No description provided for @cats_create.
  ///
  /// In pt_BR, this message translates to:
  /// **'Novo Gato'**
  String get cats_create;

  /// No description provided for @cats_edit.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar Gato'**
  String get cats_edit;

  /// No description provided for @cats_name.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome *'**
  String get cats_name;

  /// No description provided for @cats_nameHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite o nome do gato'**
  String get cats_nameHint;

  /// No description provided for @cats_nameRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome é obrigatório'**
  String get cats_nameRequired;

  /// No description provided for @cats_breed.
  ///
  /// In pt_BR, this message translates to:
  /// **'Raça'**
  String get cats_breed;

  /// No description provided for @cats_breedHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ex: Persa, Siamês, SRD'**
  String get cats_breedHint;

  /// No description provided for @cats_gender.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sexo'**
  String get cats_gender;

  /// No description provided for @cats_color.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cor'**
  String get cats_color;

  /// No description provided for @cats_birthDate.
  ///
  /// In pt_BR, this message translates to:
  /// **'Data de nascimento'**
  String get cats_birthDate;

  /// No description provided for @cats_currentWeight.
  ///
  /// In pt_BR, this message translates to:
  /// **'Peso Atual (kg)'**
  String get cats_currentWeight;

  /// No description provided for @cats_targetWeight.
  ///
  /// In pt_BR, this message translates to:
  /// **'Peso Alvo (kg)'**
  String get cats_targetWeight;

  /// No description provided for @cats_updateWeight.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualizar Peso'**
  String get cats_updateWeight;

  /// No description provided for @cats_saveCat.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvar Gato'**
  String get cats_saveCat;

  /// No description provided for @cats_createCat.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar Gato'**
  String get cats_createCat;

  /// No description provided for @cats_catCreated.
  ///
  /// In pt_BR, this message translates to:
  /// **'Gato criado com sucesso!'**
  String get cats_catCreated;

  /// No description provided for @cats_catUpdated.
  ///
  /// In pt_BR, this message translates to:
  /// **'Gato atualizado com sucesso!'**
  String get cats_catUpdated;

  /// No description provided for @cats_catDeleted.
  ///
  /// In pt_BR, this message translates to:
  /// **'Gato excluído com sucesso!'**
  String get cats_catDeleted;

  /// No description provided for @cats_errorLoading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao carregar gatos'**
  String get cats_errorLoading;

  /// No description provided for @cats_emptyState.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nenhum gato cadastrado'**
  String get cats_emptyState;

  /// No description provided for @cats_emptyStateDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Toque no botão + para adicionar seu primeiro gato'**
  String get cats_emptyStateDescription;

  /// No description provided for @cats_addCat.
  ///
  /// In pt_BR, this message translates to:
  /// **'Adicionar Gato'**
  String get cats_addCat;

  /// No description provided for @cats_deleteCat.
  ///
  /// In pt_BR, this message translates to:
  /// **'Excluir Gato'**
  String get cats_deleteCat;

  /// Mensagem de confirmação de exclusão
  ///
  /// In pt_BR, this message translates to:
  /// **'Tem certeza que deseja excluir {name}?'**
  String cats_deleteConfirmation(String name);

  /// No description provided for @cats_addFirstCat.
  ///
  /// In pt_BR, this message translates to:
  /// **'Adicione seu primeiro gato para começar!'**
  String get cats_addFirstCat;

  /// No description provided for @cats_genderMale.
  ///
  /// In pt_BR, this message translates to:
  /// **'Macho'**
  String get cats_genderMale;

  /// No description provided for @cats_genderFemale.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fêmea'**
  String get cats_genderFemale;

  /// No description provided for @cats_birthDateRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Data de Nascimento *'**
  String get cats_birthDateRequired;

  /// No description provided for @cats_selectDate.
  ///
  /// In pt_BR, this message translates to:
  /// **'Selecione a data'**
  String get cats_selectDate;

  /// No description provided for @cats_invalidWeight.
  ///
  /// In pt_BR, this message translates to:
  /// **'Peso inválido'**
  String get cats_invalidWeight;

  /// No description provided for @cats_descriptionHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Informações adicionais sobre o gato'**
  String get cats_descriptionHint;

  /// No description provided for @homes_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Residências'**
  String get homes_title;

  /// No description provided for @homes_create.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nova Residência'**
  String get homes_create;

  /// No description provided for @homes_edit.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar Residência'**
  String get homes_edit;

  /// No description provided for @homes_info.
  ///
  /// In pt_BR, this message translates to:
  /// **'Informações da Residência'**
  String get homes_info;

  /// No description provided for @homes_name.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome'**
  String get homes_name;

  /// No description provided for @homes_description.
  ///
  /// In pt_BR, this message translates to:
  /// **'Descrição'**
  String get homes_description;

  /// No description provided for @homes_address.
  ///
  /// In pt_BR, this message translates to:
  /// **'Endereço'**
  String get homes_address;

  /// No description provided for @homes_createHome.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar Residência'**
  String get homes_createHome;

  /// No description provided for @homes_homeCreated.
  ///
  /// In pt_BR, this message translates to:
  /// **'Residência criada com sucesso!'**
  String get homes_homeCreated;

  /// No description provided for @homes_homeUpdated.
  ///
  /// In pt_BR, this message translates to:
  /// **'Residência atualizada com sucesso!'**
  String get homes_homeUpdated;

  /// No description provided for @homes_homeDeleted.
  ///
  /// In pt_BR, this message translates to:
  /// **'Residência excluída com sucesso!'**
  String get homes_homeDeleted;

  /// No description provided for @homes_nameRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome da Residência *'**
  String get homes_nameRequired;

  /// No description provided for @homes_nameHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ex: Casa Principal, Apartamento, Sítio...'**
  String get homes_nameHint;

  /// No description provided for @homes_nameRequiredError.
  ///
  /// In pt_BR, this message translates to:
  /// **'O nome da residência é obrigatório'**
  String get homes_nameRequiredError;

  /// No description provided for @homes_nameMinLength.
  ///
  /// In pt_BR, this message translates to:
  /// **'O nome deve ter pelo menos 2 caracteres'**
  String get homes_nameMinLength;

  /// No description provided for @homes_descriptionHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Informações adicionais sobre a residência...'**
  String get homes_descriptionHint;

  /// No description provided for @homes_requiredFields.
  ///
  /// In pt_BR, this message translates to:
  /// **'* Campos obrigatórios'**
  String get homes_requiredFields;

  /// No description provided for @error_generic.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ops! Algo deu errado'**
  String get error_generic;

  /// No description provided for @error_loading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao carregar'**
  String get error_loading;

  /// No description provided for @error_network.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro de conexão'**
  String get error_network;

  /// No description provided for @error_server.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro no servidor'**
  String get error_server;

  /// No description provided for @error_notFound.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não encontrado'**
  String get error_notFound;

  /// No description provided for @error_unauthorized.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não autorizado'**
  String get error_unauthorized;

  /// No description provided for @error_validation.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro de validação'**
  String get error_validation;

  /// No description provided for @error_tryAgain.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tentar Novamente'**
  String get error_tryAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
    case 'es':
      {
        switch (locale.countryCode) {
          case 'ES':
            return AppLocalizationsEsEs();
        }
        break;
      }
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'FR':
            return AppLocalizationsFrFr();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
