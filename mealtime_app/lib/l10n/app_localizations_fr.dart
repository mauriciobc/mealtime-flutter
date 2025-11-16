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
  String get auth_login => 'Se connecter';

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
  String get cats_currentWeight => 'Poids actuel (kg)';

  @override
  String get cats_targetWeight => 'Poids cible (kg)';

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
  String get cats_currentWeightLabel => 'Poids actuel (kg)';

  @override
  String get cats_targetWeightLabel => 'Poids idéal (kg)';

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
  String get auth_login => 'Se connecter';

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
  String get cats_currentWeight => 'Poids actuel (kg)';

  @override
  String get cats_targetWeight => 'Poids cible (kg)';

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
  String get cats_currentWeightLabel => 'Poids actuel (kg)';

  @override
  String get cats_targetWeightLabel => 'Poids idéal (kg)';

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
