// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MealTime';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_create => 'Créer';

  @override
  String get common_update => 'Mettre à jour';

  @override
  String get common_loading => 'Chargement...';

  @override
  String get common_error => 'Erreur';

  @override
  String get common_success => 'Succès';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String get common_close => 'Fermer';

  @override
  String get common_ok => 'OK';

  @override
  String get common_yes => 'Oui';

  @override
  String get common_no => 'Non';

  @override
  String get common_back => 'Retour';

  @override
  String get common_next => 'Suivant';

  @override
  String get common_previous => 'Précédent';

  @override
  String get common_search => 'Rechercher';

  @override
  String get common_refresh => 'Actualiser';

  @override
  String get common_filter => 'Filtrer';

  @override
  String get common_clear => 'Effacer';

  @override
  String get common_required => 'Obligatoire';

  @override
  String get common_optional => 'Optionnel';

  @override
  String get common_name => 'Nom';

  @override
  String get common_email => 'Email';

  @override
  String get common_password => 'Mot de passe';

  @override
  String get common_description => 'Description';

  @override
  String get common_date => 'Date';

  @override
  String get common_time => 'Heure';

  @override
  String get common_weight => 'Poids';

  @override
  String get common_actions => 'Actions';

  @override
  String get navigation_home => 'Accueil';

  @override
  String get navigation_cats => 'Chats';

  @override
  String get navigation_weight => 'Poids';

  @override
  String get navigation_statistics => 'Statistiques';

  @override
  String get navigation_profile => 'Profil';

  @override
  String get navigation_notifications => 'Notifications';

  @override
  String get auth_logout => 'Se déconnecter';

  @override
  String get auth_register => 'Créer un compte';

  @override
  String get auth_signIn => 'Se connecter';

  @override
  String get auth_signUp => 'S\'inscrire';

  @override
  String get auth_forgotPassword => 'Mot de passe oublié';

  @override
  String get auth_fullName => 'Nom complet';

  @override
  String get auth_nameRequired => 'Le nom est obligatoire';

  @override
  String get auth_nameMinLength => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get auth_emailRequired => 'L\'email est obligatoire';

  @override
  String get auth_emailInvalid => 'Email invalide';

  @override
  String get auth_passwordRequired => 'Le mot de passe est obligatoire';

  @override
  String get auth_passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get auth_confirmPassword => 'Confirmer le mot de passe';

  @override
  String get auth_passwordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get auth_userNotAuthenticated => 'Utilisateur non authentifié';

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_editProfile => 'Modifier le profil';

  @override
  String get profile_profileNotFound => 'Profil non trouvé';

  @override
  String get profile_reload => 'Recharger';

  @override
  String get profile_profileUpdated => 'Profil mis à jour avec succès !';

  @override
  String get profile_errorUpdating => 'Erreur lors de la mise à jour du profil';

  @override
  String get profile_confirmLogout => 'Confirmer la déconnexion';

  @override
  String get profile_logoutConfirmation =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get profile_logoutError => 'Erreur lors de la déconnexion';

  @override
  String get profile_user => 'Utilisateur';

  @override
  String get cats_title => 'Mes Chats';

  @override
  String get cats_create => 'Nouveau Chat';

  @override
  String get cats_edit => 'Modifier le Chat';

  @override
  String get cats_name => 'Nom *';

  @override
  String get cats_nameHint => 'Entrez le nom du chat';

  @override
  String get cats_nameRequired => 'Le nom est obligatoire';

  @override
  String get cats_breed => 'Race';

  @override
  String get cats_breedHint => 'Ex. : Persan, Siamois, Métis';

  @override
  String get cats_gender => 'Sexe';

  @override
  String get cats_color => 'Couleur';

  @override
  String get cats_birthDate => 'Date de naissance';

  @override
  String get cats_currentWeight => 'Poids Actuel (kg)';

  @override
  String get cats_targetWeight => 'Poids Cible (kg)';

  @override
  String get cats_updateWeight => 'Mettre à jour le poids';

  @override
  String get cats_saveCat => 'Enregistrer le chat';

  @override
  String get cats_createCat => 'Créer un chat';

  @override
  String get cats_catCreated => 'Chat créé avec succès !';

  @override
  String get cats_catUpdated => 'Chat mis à jour avec succès !';

  @override
  String get cats_catDeleted => 'Chat supprimé avec succès !';

  @override
  String get cats_errorLoading => 'Erreur lors du chargement des chats';

  @override
  String get cats_emptyState => 'Aucun chat enregistré';

  @override
  String get cats_emptyStateDescription =>
      'Appuyez sur le bouton + pour ajouter votre premier chat';

  @override
  String get cats_addCat => 'Ajouter un chat';

  @override
  String get cats_deleteCat => 'Supprimer le chat';

  @override
  String cats_deleteConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir supprimer $name ?';
  }

  @override
  String get cats_addFirstCat => 'Ajoutez votre premier chat pour commencer !';

  @override
  String get cats_genderMale => 'Mâle';

  @override
  String get cats_genderFemale => 'Femelle';

  @override
  String get cats_birthDateRequired => 'Date de naissance *';

  @override
  String get cats_selectDate => 'Sélectionner la date';

  @override
  String get cats_invalidWeight => 'Poids invalide';

  @override
  String get cats_descriptionHint => 'Informations supplémentaires sur le chat';

  @override
  String get homes_title => 'Foyers';

  @override
  String get homes_create => 'Nouveau Foyer';

  @override
  String get homes_edit => 'Modifier le Foyer';

  @override
  String get homes_info => 'Informations du Foyer';

  @override
  String get homes_name => 'Nom';

  @override
  String get homes_description => 'Description';

  @override
  String get homes_address => 'Adresse';

  @override
  String get homes_createHome => 'Créer un foyer';

  @override
  String get homes_homeCreated => 'Foyer créé avec succès !';

  @override
  String get homes_homeUpdated => 'Foyer mis à jour avec succès !';

  @override
  String get homes_homeDeleted => 'Foyer supprimé avec succès !';

  @override
  String get homes_nameRequired => 'Nom du Foyer *';

  @override
  String get homes_nameHint => 'Ex. : Maison Principale, Appartement, Ferme...';

  @override
  String get homes_nameRequiredError => 'Le nom du foyer est obligatoire';

  @override
  String get homes_nameMinLength =>
      'Le nom doit contenir au moins 2 caractères';

  @override
  String get homes_descriptionHint =>
      'Informations supplémentaires sur le foyer...';

  @override
  String get homes_requiredFields => '* Champs obligatoires';

  @override
  String get error_generic => 'Oups ! Quelque chose s\'est mal passé';

  @override
  String get error_loading => 'Erreur de chargement';

  @override
  String get error_network => 'Erreur de connexion';

  @override
  String get error_server => 'Erreur du serveur';

  @override
  String get error_notFound => 'Non trouvé';

  @override
  String get error_unauthorized => 'Non autorisé';

  @override
  String get error_validation => 'Erreur de validation';

  @override
  String get error_tryAgain => 'Réessayer';

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

/// The translations for French, as used in France (`fr_FR`).
class AppLocalizationsFrFr extends AppLocalizationsFr {
  AppLocalizationsFrFr() : super('fr_FR');

  @override
  String get appTitle => 'MealTime';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_create => 'Créer';

  @override
  String get common_update => 'Mettre à jour';

  @override
  String get common_loading => 'Chargement...';

  @override
  String get common_error => 'Erreur';

  @override
  String get common_success => 'Succès';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String get common_close => 'Fermer';

  @override
  String get common_ok => 'OK';

  @override
  String get common_yes => 'Oui';

  @override
  String get common_no => 'Non';

  @override
  String get common_back => 'Retour';

  @override
  String get common_next => 'Suivant';

  @override
  String get common_previous => 'Précédent';

  @override
  String get common_search => 'Rechercher';

  @override
  String get common_refresh => 'Actualiser';

  @override
  String get common_filter => 'Filtrer';

  @override
  String get common_clear => 'Effacer';

  @override
  String get common_required => 'Obligatoire';

  @override
  String get common_optional => 'Optionnel';

  @override
  String get common_name => 'Nom';

  @override
  String get common_email => 'Email';

  @override
  String get common_password => 'Mot de passe';

  @override
  String get common_description => 'Description';

  @override
  String get common_date => 'Date';

  @override
  String get common_time => 'Heure';

  @override
  String get common_weight => 'Poids';

  @override
  String get common_actions => 'Actions';

  @override
  String get navigation_home => 'Accueil';

  @override
  String get navigation_cats => 'Chats';

  @override
  String get navigation_weight => 'Poids';

  @override
  String get navigation_statistics => 'Statistiques';

  @override
  String get navigation_profile => 'Profil';

  @override
  String get navigation_notifications => 'Notifications';

  @override
  String get auth_logout => 'Se déconnecter';

  @override
  String get auth_register => 'Créer un compte';

  @override
  String get auth_signIn => 'Se connecter';

  @override
  String get auth_signUp => 'S\'inscrire';

  @override
  String get auth_forgotPassword => 'Mot de passe oublié';

  @override
  String get auth_fullName => 'Nom complet';

  @override
  String get auth_nameRequired => 'Le nom est obligatoire';

  @override
  String get auth_nameMinLength => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get auth_emailRequired => 'L\'email est obligatoire';

  @override
  String get auth_emailInvalid => 'Email invalide';

  @override
  String get auth_passwordRequired => 'Le mot de passe est obligatoire';

  @override
  String get auth_passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get auth_confirmPassword => 'Confirmer le mot de passe';

  @override
  String get auth_passwordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get auth_userNotAuthenticated => 'Utilisateur non authentifié';

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_editProfile => 'Modifier le profil';

  @override
  String get profile_profileNotFound => 'Profil non trouvé';

  @override
  String get profile_reload => 'Recharger';

  @override
  String get profile_profileUpdated => 'Profil mis à jour avec succès !';

  @override
  String get profile_errorUpdating => 'Erreur lors de la mise à jour du profil';

  @override
  String get profile_confirmLogout => 'Confirmer la déconnexion';

  @override
  String get profile_logoutConfirmation =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get profile_logoutError => 'Erreur lors de la déconnexion';

  @override
  String get profile_user => 'Utilisateur';

  @override
  String get cats_title => 'Mes Chats';

  @override
  String get cats_create => 'Nouveau Chat';

  @override
  String get cats_edit => 'Modifier le Chat';

  @override
  String get cats_name => 'Nom *';

  @override
  String get cats_nameHint => 'Entrez le nom du chat';

  @override
  String get cats_nameRequired => 'Le nom est obligatoire';

  @override
  String get cats_breed => 'Race';

  @override
  String get cats_breedHint => 'Ex. : Persan, Siamois, Métis';

  @override
  String get cats_gender => 'Sexe';

  @override
  String get cats_color => 'Couleur';

  @override
  String get cats_birthDate => 'Date de naissance';

  @override
  String get cats_currentWeight => 'Poids Actuel (kg)';

  @override
  String get cats_targetWeight => 'Poids Cible (kg)';

  @override
  String get cats_updateWeight => 'Mettre à jour le poids';

  @override
  String get cats_saveCat => 'Enregistrer le chat';

  @override
  String get cats_createCat => 'Créer un chat';

  @override
  String get cats_catCreated => 'Chat créé avec succès !';

  @override
  String get cats_catUpdated => 'Chat mis à jour avec succès !';

  @override
  String get cats_catDeleted => 'Chat supprimé avec succès !';

  @override
  String get cats_errorLoading => 'Erreur lors du chargement des chats';

  @override
  String get cats_emptyState => 'Aucun chat enregistré';

  @override
  String get cats_emptyStateDescription =>
      'Appuyez sur le bouton + pour ajouter votre premier chat';

  @override
  String get cats_addCat => 'Ajouter un chat';

  @override
  String get cats_deleteCat => 'Supprimer le chat';

  @override
  String cats_deleteConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir supprimer $name ?';
  }

  @override
  String get cats_addFirstCat => 'Ajoutez votre premier chat pour commencer !';

  @override
  String get cats_genderMale => 'Mâle';

  @override
  String get cats_genderFemale => 'Femelle';

  @override
  String get cats_birthDateRequired => 'Date de naissance *';

  @override
  String get cats_selectDate => 'Sélectionner la date';

  @override
  String get cats_invalidWeight => 'Poids invalide';

  @override
  String get cats_descriptionHint => 'Informations supplémentaires sur le chat';

  @override
  String get homes_title => 'Foyers';

  @override
  String get homes_create => 'Nouveau Foyer';

  @override
  String get homes_edit => 'Modifier le Foyer';

  @override
  String get homes_info => 'Informations du Foyer';

  @override
  String get homes_name => 'Nom';

  @override
  String get homes_description => 'Description';

  @override
  String get homes_address => 'Adresse';

  @override
  String get homes_createHome => 'Créer un foyer';

  @override
  String get homes_homeCreated => 'Foyer créé avec succès !';

  @override
  String get homes_homeUpdated => 'Foyer mis à jour avec succès !';

  @override
  String get homes_homeDeleted => 'Foyer supprimé avec succès !';

  @override
  String get homes_nameRequired => 'Nom du Foyer *';

  @override
  String get homes_nameHint => 'Ex. : Maison Principale, Appartement, Ferme...';

  @override
  String get homes_nameRequiredError => 'Le nom du foyer est obligatoire';

  @override
  String get homes_nameMinLength =>
      'Le nom doit contenir au moins 2 caractères';

  @override
  String get homes_descriptionHint =>
      'Informations supplémentaires sur le foyer...';

  @override
  String get homes_requiredFields => '* Champs obligatoires';

  @override
  String get error_generic => 'Oups ! Quelque chose s\'est mal passé';

  @override
  String get error_loading => 'Erreur de chargement';

  @override
  String get error_network => 'Erreur de connexion';

  @override
  String get error_server => 'Erreur du serveur';

  @override
  String get error_notFound => 'Non trouvé';

  @override
  String get error_unauthorized => 'Non autorisé';

  @override
  String get error_validation => 'Erreur de validation';

  @override
  String get error_tryAgain => 'Réessayer';
}
