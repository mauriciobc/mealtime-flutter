// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MealTime';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_create => 'Create';

  @override
  String get common_update => 'Update';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_retry => 'Try again';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_close => 'Close';

  @override
  String get common_ok => 'OK';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_previous => 'Previous';

  @override
  String get common_search => 'Search';

  @override
  String get common_refresh => 'Refresh';

  @override
  String get common_filter => 'Filter';

  @override
  String get common_clear => 'Clear';

  @override
  String get common_required => 'Required';

  @override
  String get common_optional => 'Optional';

  @override
  String get common_name => 'Name';

  @override
  String get common_email => 'Email';

  @override
  String get common_password => 'Password';

  @override
  String get common_description => 'Description';

  @override
  String get common_date => 'Date';

  @override
  String get common_time => 'Time';

  @override
  String get common_weight => 'Weight';

  @override
  String get common_actions => 'Actions';

  @override
  String get navigation_home => 'Home';

  @override
  String get navigation_cats => 'Cats';

  @override
  String get navigation_weight => 'Weight';

  @override
  String get navigation_statistics => 'Statistics';

  @override
  String get navigation_profile => 'Profile';

  @override
  String get navigation_notifications => 'Notifications';

  @override
  String get auth_logout => 'Logout';

  @override
  String get auth_register => 'Create Account';

  @override
  String get auth_signIn => 'Sign In';

  @override
  String get auth_signUp => 'Sign Up';

  @override
  String get auth_forgotPassword => 'Forgot password';

  @override
  String get auth_fullName => 'Full name';

  @override
  String get auth_nameRequired => 'Name is required';

  @override
  String get auth_nameMinLength => 'Name must be at least 2 characters';

  @override
  String get auth_emailRequired => 'Email is required';

  @override
  String get auth_emailInvalid => 'Invalid email';

  @override
  String get auth_passwordRequired => 'Password is required';

  @override
  String get auth_passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get auth_confirmPassword => 'Confirm password';

  @override
  String get auth_passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get auth_userNotAuthenticated => 'User not authenticated';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_editProfile => 'Edit profile';

  @override
  String get profile_profileNotFound => 'Profile not found';

  @override
  String get profile_reload => 'Reload';

  @override
  String get profile_profileUpdated => 'Profile updated successfully!';

  @override
  String get profile_errorUpdating => 'Error updating profile';

  @override
  String get profile_confirmLogout => 'Confirm logout';

  @override
  String get profile_logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get profile_logoutError => 'Error logging out';

  @override
  String get profile_user => 'User';

  @override
  String get cats_title => 'My Cats';

  @override
  String get cats_create => 'New Cat';

  @override
  String get cats_edit => 'Edit Cat';

  @override
  String get cats_name => 'Name *';

  @override
  String get cats_nameHint => 'Enter cat name';

  @override
  String get cats_nameRequired => 'Name is required';

  @override
  String get cats_breed => 'Breed';

  @override
  String get cats_breedHint => 'e.g.: Persian, Siamese, Mixed';

  @override
  String get cats_gender => 'Gender';

  @override
  String get cats_color => 'Color';

  @override
  String get cats_birthDate => 'Birth date';

  @override
  String get cats_currentWeight => 'Current Weight (kg)';

  @override
  String get cats_targetWeight => 'Target Weight (kg)';

  @override
  String get cats_updateWeight => 'Update Weight';

  @override
  String get cats_saveCat => 'Save Cat';

  @override
  String get cats_createCat => 'Create Cat';

  @override
  String get cats_catCreated => 'Cat created successfully!';

  @override
  String get cats_catUpdated => 'Cat updated successfully!';

  @override
  String get cats_catDeleted => 'Cat deleted successfully!';

  @override
  String get cats_errorLoading => 'Error loading cats';

  @override
  String get cats_emptyState => 'No cats registered';

  @override
  String get cats_emptyStateDescription =>
      'Tap the + button to add your first cat';

  @override
  String get cats_addCat => 'Add Cat';

  @override
  String get cats_deleteCat => 'Delete Cat';

  @override
  String cats_deleteConfirmation(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get cats_addFirstCat => 'Add your first cat to get started!';

  @override
  String get cats_genderMale => 'Male';

  @override
  String get cats_genderFemale => 'Female';

  @override
  String get cats_birthDateRequired => 'Birth Date *';

  @override
  String get cats_selectDate => 'Select date';

  @override
  String get cats_invalidWeight => 'Invalid weight';

  @override
  String get cats_descriptionHint => 'Additional information about the cat';

  @override
  String get homes_title => 'Homes';

  @override
  String get homes_create => 'New Home';

  @override
  String get homes_edit => 'Edit Home';

  @override
  String get homes_info => 'Home Information';

  @override
  String get homes_name => 'Name';

  @override
  String get homes_description => 'Description';

  @override
  String get homes_address => 'Address';

  @override
  String get homes_createHome => 'Create Home';

  @override
  String get homes_homeCreated => 'Home created successfully!';

  @override
  String get homes_homeUpdated => 'Home updated successfully!';

  @override
  String get homes_homeDeleted => 'Home deleted successfully!';

  @override
  String get homes_nameRequired => 'Home Name *';

  @override
  String get homes_nameHint => 'e.g.: Main House, Apartment, Farm...';

  @override
  String get homes_nameRequiredError => 'Home name is required';

  @override
  String get homes_nameMinLength => 'Name must be at least 2 characters';

  @override
  String get homes_descriptionHint =>
      'Additional information about the home...';

  @override
  String get homes_requiredFields => '* Required fields';

  @override
  String get error_generic => 'Oops! Something went wrong';

  @override
  String get error_loading => 'Error loading';

  @override
  String get error_network => 'Connection error';

  @override
  String get error_server => 'Server error';

  @override
  String get error_notFound => 'Not found';

  @override
  String get error_unauthorized => 'Unauthorized';

  @override
  String get error_validation => 'Validation error';

  @override
  String get error_tryAgain => 'Try Again';
}

/// The translations for English, as used in the United States (`en_US`).
class AppLocalizationsEnUs extends AppLocalizationsEn {
  AppLocalizationsEnUs() : super('en_US');

  @override
  String get appTitle => 'MealTime';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_create => 'Create';

  @override
  String get common_update => 'Update';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_retry => 'Try again';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_close => 'Close';

  @override
  String get common_ok => 'OK';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_previous => 'Previous';

  @override
  String get common_search => 'Search';

  @override
  String get common_refresh => 'Refresh';

  @override
  String get common_filter => 'Filter';

  @override
  String get common_clear => 'Clear';

  @override
  String get common_required => 'Required';

  @override
  String get common_optional => 'Optional';

  @override
  String get common_name => 'Name';

  @override
  String get common_email => 'Email';

  @override
  String get common_password => 'Password';

  @override
  String get common_description => 'Description';

  @override
  String get common_date => 'Date';

  @override
  String get common_time => 'Time';

  @override
  String get common_weight => 'Weight';

  @override
  String get common_actions => 'Actions';

  @override
  String get navigation_home => 'Home';

  @override
  String get navigation_cats => 'Cats';

  @override
  String get navigation_weight => 'Weight';

  @override
  String get navigation_statistics => 'Statistics';

  @override
  String get navigation_profile => 'Profile';

  @override
  String get navigation_notifications => 'Notifications';

  @override
  String get auth_logout => 'Logout';

  @override
  String get auth_register => 'Create Account';

  @override
  String get auth_signIn => 'Sign In';

  @override
  String get auth_signUp => 'Sign Up';

  @override
  String get auth_forgotPassword => 'Forgot password';

  @override
  String get auth_fullName => 'Full name';

  @override
  String get auth_nameRequired => 'Name is required';

  @override
  String get auth_nameMinLength => 'Name must be at least 2 characters';

  @override
  String get auth_emailRequired => 'Email is required';

  @override
  String get auth_emailInvalid => 'Invalid email';

  @override
  String get auth_passwordRequired => 'Password is required';

  @override
  String get auth_passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get auth_confirmPassword => 'Confirm password';

  @override
  String get auth_passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get auth_userNotAuthenticated => 'User not authenticated';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_editProfile => 'Edit profile';

  @override
  String get profile_profileNotFound => 'Profile not found';

  @override
  String get profile_reload => 'Reload';

  @override
  String get profile_profileUpdated => 'Profile updated successfully!';

  @override
  String get profile_errorUpdating => 'Error updating profile';

  @override
  String get profile_confirmLogout => 'Confirm logout';

  @override
  String get profile_logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get profile_logoutError => 'Error logging out';

  @override
  String get profile_user => 'User';

  @override
  String get cats_title => 'My Cats';

  @override
  String get cats_create => 'New Cat';

  @override
  String get cats_edit => 'Edit Cat';

  @override
  String get cats_name => 'Name *';

  @override
  String get cats_nameHint => 'Enter cat name';

  @override
  String get cats_nameRequired => 'Name is required';

  @override
  String get cats_breed => 'Breed';

  @override
  String get cats_breedHint => 'e.g.: Persian, Siamese, Mixed';

  @override
  String get cats_gender => 'Gender';

  @override
  String get cats_color => 'Color';

  @override
  String get cats_birthDate => 'Birth date';

  @override
  String get cats_currentWeight => 'Current Weight (kg)';

  @override
  String get cats_targetWeight => 'Target Weight (kg)';

  @override
  String get cats_updateWeight => 'Update Weight';

  @override
  String get cats_saveCat => 'Save Cat';

  @override
  String get cats_createCat => 'Create Cat';

  @override
  String get cats_catCreated => 'Cat created successfully!';

  @override
  String get cats_catUpdated => 'Cat updated successfully!';

  @override
  String get cats_catDeleted => 'Cat deleted successfully!';

  @override
  String get cats_errorLoading => 'Error loading cats';

  @override
  String get cats_emptyState => 'No cats registered';

  @override
  String get cats_emptyStateDescription =>
      'Tap the + button to add your first cat';

  @override
  String get cats_addCat => 'Add Cat';

  @override
  String get cats_deleteCat => 'Delete Cat';

  @override
  String cats_deleteConfirmation(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get cats_addFirstCat => 'Add your first cat to get started!';

  @override
  String get cats_genderMale => 'Male';

  @override
  String get cats_genderFemale => 'Female';

  @override
  String get cats_birthDateRequired => 'Birth Date *';

  @override
  String get cats_selectDate => 'Select date';

  @override
  String get cats_invalidWeight => 'Invalid weight';

  @override
  String get cats_descriptionHint => 'Additional information about the cat';

  @override
  String get homes_title => 'Homes';

  @override
  String get homes_create => 'New Home';

  @override
  String get homes_edit => 'Edit Home';

  @override
  String get homes_info => 'Home Information';

  @override
  String get homes_name => 'Name';

  @override
  String get homes_description => 'Description';

  @override
  String get homes_address => 'Address';

  @override
  String get homes_createHome => 'Create Home';

  @override
  String get homes_homeCreated => 'Home created successfully!';

  @override
  String get homes_homeUpdated => 'Home updated successfully!';

  @override
  String get homes_homeDeleted => 'Home deleted successfully!';

  @override
  String get homes_nameRequired => 'Home Name *';

  @override
  String get homes_nameHint => 'e.g.: Main House, Apartment, Farm...';

  @override
  String get homes_nameRequiredError => 'Home name is required';

  @override
  String get homes_nameMinLength => 'Name must be at least 2 characters';

  @override
  String get homes_descriptionHint =>
      'Additional information about the home...';

  @override
  String get homes_requiredFields => '* Required fields';

  @override
  String get error_generic => 'Oops! Something went wrong';

  @override
  String get error_loading => 'Error loading';

  @override
  String get error_network => 'Connection error';

  @override
  String get error_server => 'Server error';

  @override
  String get error_notFound => 'Not found';

  @override
  String get error_unauthorized => 'Unauthorized';

  @override
  String get error_validation => 'Validation error';

  @override
  String get error_tryAgain => 'Try Again';
}
