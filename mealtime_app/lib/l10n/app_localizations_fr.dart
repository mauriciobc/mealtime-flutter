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
  String get common_moreOptions => 'Plus d\'options';

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
  String get home_hello => 'Bonjour';

  @override
  String get home_food_dry => 'Nourriture sèche';

  @override
  String get home_food_wet => 'Nourriture humide';

  @override
  String get home_food_homemade => 'Nourriture maison';

  @override
  String get home_food_sachet => 'Sachet';

  @override
  String get home_food_treat => 'Friandise';

  @override
  String get home_food_not_specified => 'Aliment non spécifié';

  @override
  String get home_fed_by_you => 'Vous';

  @override
  String get home_fed_by_other => 'Autre utilisateur';

  @override
  String home_fed_by(String name) {
    return 'Nourri par $name';
  }

  @override
  String get home_no_feeding_records => 'Aucun enregistrement d\'alimentation';

  @override
  String get home_last_7_days => '7 derniers jours';

  @override
  String get home_register_feeding_chart =>
      'Enregistrez des repas pour voir le graphique des 7 derniers jours';

  @override
  String get home_recent_records => 'Enregistrements récents';

  @override
  String get home_no_recent_records => 'Aucun enregistrement récent';

  @override
  String get home_see_all_cats => 'Voir tous les chats';

  @override
  String get home_no_cats_registered => 'Aucun chat enregistré';

  @override
  String get home_feedings_title => 'Repas';

  @override
  String get home_last_feeding_title => 'Dernier repas';

  @override
  String get home_average_portion => 'Portion moyenne';

  @override
  String get home_today => 'Aujourd\'hui';

  @override
  String get home_total_cats => 'Total des chats';

  @override
  String get home_last_time => 'Dernière fois';

  @override
  String get home_active_cats => 'Actifs';

  @override
  String get home_average_portion_subtitle => '7 derniers jours';

  @override
  String get home_last_time_subtitle => 'Dernier enregistrement';

  @override
  String home_amount_food_type(String amount, String foodType) {
    return '${amount}g de $foodType';
  }

  @override
  String get home_no_feeding_recorded => 'Aucun repas enregistré';

  @override
  String get home_cat_name_not_found => 'Nom non trouvé';

  @override
  String get home_my_cats => 'Mes chats';

  @override
  String home_cat_weight(String weight) {
    return '${weight}kg';
  }

  @override
  String get home_cat_weight_unknown => 'Inconnu';

  @override
  String get home_no_cats_register_first =>
      'Aucun chat enregistré. Enregistrez un chat d\'abord.';

  @override
  String get home_register_feeding => 'Enregistrer un repas';

  @override
  String get auth_welcomeBack => 'Bon retour !';

  @override
  String get auth_managementDescription =>
      'Gestion de l\'alimentation des chats';

  @override
  String get auth_passwordPlaceholder => 'Mot de passe';

  @override
  String get auth_alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get auth_noAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get auth_signInShort => 'Se connecter';

  @override
  String get auth_registerShort => 'Créer un compte';

  @override
  String get auth_featureInDevelopment =>
      'Fonctionnalité en cours de développement';

  @override
  String get auth_registerInDevelopment =>
      'Fonctionnalité d\'inscription en développement';

  @override
  String get profile_accountInfo => 'Informations du compte';

  @override
  String get profile_userInfo => 'Informations utilisateur';

  @override
  String get profile_usernameLabel => 'Nom d\'utilisateur';

  @override
  String get profile_website => 'Site web';

  @override
  String get profile_updateProfile => 'Mettre à jour le profil';

  @override
  String get profile_userId => 'ID utilisateur';

  @override
  String get profile_accountStatus => 'État du compte';

  @override
  String get profile_verified => 'Vérifié';

  @override
  String get profile_notVerified => 'Non vérifié';

  @override
  String get profile_accountCreated => 'Compte créé le';

  @override
  String get profile_lastAccess => 'Dernier accès';

  @override
  String get profile_logoutErrorGeneric => 'Erreur lors de la déconnexion';

  @override
  String get statistics_title => 'Statistiques';

  @override
  String get statistics_loading => 'Chargement des statistiques...';

  @override
  String get statistics_errorLoading =>
      'Erreur lors du chargement des statistiques';

  @override
  String get statistics_noData => 'Aucune donnée disponible';

  @override
  String get statistics_noDataPeriod =>
      'Aucun repas enregistré pour la période sélectionnée.';

  @override
  String get statistics_chartError => 'Erreur lors du rendu du graphique';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_markedAsRead => 'Notification marquée comme lue';

  @override
  String notifications_errorMarkAsRead(String error) {
    return 'Erreur lors du marquage comme lue : $error';
  }

  @override
  String get notifications_allMarkedAsRead =>
      'Toutes les notifications ont été marquées comme lues';

  @override
  String notifications_errorMarkAllAsRead(String error) {
    return 'Erreur lors du marquage de toutes comme lues : $error';
  }

  @override
  String get notifications_removed => 'Notification supprimée';

  @override
  String notifications_errorRemove(String error) {
    return 'Erreur lors de la suppression de la notification : $error';
  }

  @override
  String get notifications_tryAgain => 'Réessayer';

  @override
  String get notifications_markAllAsRead => 'Tout marquer comme lu';

  @override
  String get notifications_empty => 'Aucune notification';

  @override
  String get notifications_emptySubtitle => 'Vous êtes à jour !';

  @override
  String get notifications_refresh => 'Actualiser';

  @override
  String get notifications_delete => 'Supprimer la notification';

  @override
  String get notifications_userNotAuthenticated =>
      'Utilisateur non authentifié';

  @override
  String notifications_errorLoading(String error) {
    return 'Erreur lors du chargement des notifications : $error';
  }

  @override
  String get auth_pleaseEnterEmail => 'Veuillez entrer votre email';

  @override
  String get auth_pleaseEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get auth_pleaseEnterFullName => 'Veuillez entrer votre nom complet';
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
  String get common_moreOptions => 'Plus d\'options';

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
  String get home_hello => 'Bonjour';

  @override
  String get home_food_dry => 'Nourriture sèche';

  @override
  String get home_food_wet => 'Nourriture humide';

  @override
  String get home_food_homemade => 'Nourriture maison';

  @override
  String get home_food_sachet => 'Sachet';

  @override
  String get home_food_treat => 'Friandise';

  @override
  String get home_food_not_specified => 'Aliment non spécifié';

  @override
  String get home_fed_by_you => 'Vous';

  @override
  String get home_fed_by_other => 'Autre utilisateur';

  @override
  String home_fed_by(String name) {
    return 'Nourri par $name';
  }

  @override
  String get home_no_feeding_records => 'Aucun enregistrement d\'alimentation';

  @override
  String get home_last_7_days => '7 derniers jours';

  @override
  String get home_register_feeding_chart =>
      'Enregistrez des repas pour voir le graphique des 7 derniers jours';

  @override
  String get home_recent_records => 'Enregistrements récents';

  @override
  String get home_no_recent_records => 'Aucun enregistrement récent';

  @override
  String get home_see_all_cats => 'Voir tous les chats';

  @override
  String get home_no_cats_registered => 'Aucun chat enregistré';

  @override
  String get home_feedings_title => 'Repas';

  @override
  String get home_last_feeding_title => 'Dernier repas';

  @override
  String get home_average_portion => 'Portion moyenne';

  @override
  String get home_today => 'Aujourd\'hui';

  @override
  String get home_total_cats => 'Total des chats';

  @override
  String get home_last_time => 'Dernière fois';

  @override
  String get home_active_cats => 'Actifs';

  @override
  String get home_average_portion_subtitle => '7 derniers jours';

  @override
  String get home_last_time_subtitle => 'Dernier enregistrement';

  @override
  String home_amount_food_type(String amount, String foodType) {
    return '${amount}g de $foodType';
  }

  @override
  String get home_no_feeding_recorded => 'Aucun repas enregistré';

  @override
  String get home_cat_name_not_found => 'Nom non trouvé';

  @override
  String get home_my_cats => 'Mes chats';

  @override
  String home_cat_weight(String weight) {
    return '${weight}kg';
  }

  @override
  String get home_cat_weight_unknown => 'Inconnu';

  @override
  String get home_no_cats_register_first =>
      'Aucun chat enregistré. Enregistrez un chat d\'abord.';

  @override
  String get home_register_feeding => 'Enregistrer un repas';

  @override
  String get auth_welcomeBack => 'Bon retour !';

  @override
  String get auth_managementDescription =>
      'Gestion de l\'alimentation des chats';

  @override
  String get auth_passwordPlaceholder => 'Mot de passe';

  @override
  String get auth_alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get auth_noAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get auth_signInShort => 'Se connecter';

  @override
  String get auth_registerShort => 'Créer un compte';

  @override
  String get auth_featureInDevelopment =>
      'Fonctionnalité en cours de développement';

  @override
  String get auth_registerInDevelopment =>
      'Fonctionnalité d\'inscription en développement';

  @override
  String get profile_accountInfo => 'Informations du compte';

  @override
  String get profile_userInfo => 'Informations utilisateur';

  @override
  String get profile_usernameLabel => 'Nom d\'utilisateur';

  @override
  String get profile_website => 'Site web';

  @override
  String get profile_updateProfile => 'Mettre à jour le profil';

  @override
  String get profile_userId => 'ID utilisateur';

  @override
  String get profile_accountStatus => 'État du compte';

  @override
  String get profile_verified => 'Vérifié';

  @override
  String get profile_notVerified => 'Non vérifié';

  @override
  String get profile_accountCreated => 'Compte créé le';

  @override
  String get profile_lastAccess => 'Dernier accès';

  @override
  String get profile_logoutErrorGeneric => 'Erreur lors de la déconnexion';

  @override
  String get statistics_title => 'Statistiques';

  @override
  String get statistics_loading => 'Chargement des statistiques...';

  @override
  String get statistics_errorLoading =>
      'Erreur lors du chargement des statistiques';

  @override
  String get statistics_noData => 'Aucune donnée disponible';

  @override
  String get statistics_noDataPeriod =>
      'Aucun repas enregistré pour la période sélectionnée.';

  @override
  String get statistics_chartError => 'Erreur lors du rendu du graphique';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_markedAsRead => 'Notification marquée comme lue';

  @override
  String notifications_errorMarkAsRead(String error) {
    return 'Erreur lors du marquage comme lue : $error';
  }

  @override
  String get notifications_allMarkedAsRead =>
      'Toutes les notifications ont été marquées comme lues';

  @override
  String notifications_errorMarkAllAsRead(String error) {
    return 'Erreur lors du marquage de toutes comme lues : $error';
  }

  @override
  String get notifications_removed => 'Notification supprimée';

  @override
  String notifications_errorRemove(String error) {
    return 'Erreur lors de la suppression de la notification : $error';
  }

  @override
  String get notifications_tryAgain => 'Réessayer';

  @override
  String get notifications_markAllAsRead => 'Tout marquer comme lu';

  @override
  String get notifications_empty => 'Aucune notification';

  @override
  String get notifications_emptySubtitle => 'Vous êtes à jour !';

  @override
  String get notifications_refresh => 'Actualiser';

  @override
  String get notifications_delete => 'Supprimer la notification';

  @override
  String get notifications_userNotAuthenticated =>
      'Utilisateur non authentifié';

  @override
  String notifications_errorLoading(String error) {
    return 'Erreur lors du chargement des notifications : $error';
  }

  @override
  String get auth_pleaseEnterEmail => 'Veuillez entrer votre email';

  @override
  String get auth_pleaseEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get auth_pleaseEnterFullName => 'Veuillez entrer votre nom complet';
}
