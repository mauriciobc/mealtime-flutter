// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MealTime';

  @override
  String get common_save => 'Salvar';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_delete => 'Excluir';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_create => 'Criar';

  @override
  String get common_update => 'Atualizar';

  @override
  String get common_loading => 'Carregando...';

  @override
  String get common_error => 'Erro';

  @override
  String get common_success => 'Sucesso';

  @override
  String get common_retry => 'Tentar novamente';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_close => 'Fechar';

  @override
  String get common_ok => 'OK';

  @override
  String get common_yes => 'Sim';

  @override
  String get common_no => 'Não';

  @override
  String get common_back => 'Voltar';

  @override
  String get common_next => 'Próximo';

  @override
  String get common_previous => 'Anterior';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_refresh => 'Atualizar';

  @override
  String get common_filter => 'Filtrar';

  @override
  String get common_clear => 'Limpar';

  @override
  String get common_required => 'Obrigatório';

  @override
  String get common_optional => 'Opcional';

  @override
  String get common_name => 'Nome';

  @override
  String get common_email => 'Email';

  @override
  String get common_password => 'Senha';

  @override
  String get common_description => 'Descrição';

  @override
  String get common_date => 'Data';

  @override
  String get common_time => 'Hora';

  @override
  String get common_weight => 'Peso';

  @override
  String get common_actions => 'Ações';

  @override
  String get navigation_home => 'Início';

  @override
  String get navigation_cats => 'Gatos';

  @override
  String get navigation_weight => 'Peso';

  @override
  String get navigation_statistics => 'Estatísticas';

  @override
  String get navigation_profile => 'Perfil';

  @override
  String get navigation_notifications => 'Notificações';

  @override
  String get auth_logout => 'Sair';

  @override
  String get auth_register => 'Criar Conta';

  @override
  String get auth_signIn => 'Entrar';

  @override
  String get auth_signUp => 'Cadastrar';

  @override
  String get auth_forgotPassword => 'Esqueci minha senha';

  @override
  String get auth_fullName => 'Nome completo';

  @override
  String get auth_nameRequired => 'Nome é obrigatório';

  @override
  String get auth_nameMinLength => 'Nome deve ter pelo menos 2 caracteres';

  @override
  String get auth_emailRequired => 'Email é obrigatório';

  @override
  String get auth_emailInvalid => 'Email inválido';

  @override
  String get auth_passwordRequired => 'Senha é obrigatória';

  @override
  String get auth_passwordMinLength => 'Senha deve ter pelo menos 6 caracteres';

  @override
  String get auth_confirmPassword => 'Confirmar senha';

  @override
  String get auth_passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get auth_userNotAuthenticated => 'Usuário não autenticado';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_editProfile => 'Editar perfil';

  @override
  String get profile_profileNotFound => 'Perfil não encontrado';

  @override
  String get profile_reload => 'Recarregar';

  @override
  String get profile_profileUpdated => 'Perfil atualizado com sucesso!';

  @override
  String get profile_errorUpdating => 'Erro ao atualizar perfil';

  @override
  String get profile_confirmLogout => 'Confirmar logout';

  @override
  String get profile_logoutConfirmation => 'Tem certeza que deseja sair?';

  @override
  String get profile_logoutError => 'Erro ao fazer logout';

  @override
  String get profile_user => 'Usuário';

  @override
  String get cats_title => 'Meus Gatos';

  @override
  String get cats_create => 'Novo Gato';

  @override
  String get cats_edit => 'Editar Gato';

  @override
  String get cats_name => 'Nome *';

  @override
  String get cats_nameHint => 'Digite o nome do gato';

  @override
  String get cats_nameRequired => 'Nome é obrigatório';

  @override
  String get cats_breed => 'Raça';

  @override
  String get cats_breedHint => 'Ex: Persa, Siamês, SRD';

  @override
  String get cats_gender => 'Sexo';

  @override
  String get cats_color => 'Cor';

  @override
  String get cats_birthDate => 'Data de nascimento';

  @override
  String get cats_currentWeight => 'Peso Atual (kg)';

  @override
  String get cats_targetWeight => 'Peso Alvo (kg)';

  @override
  String get cats_updateWeight => 'Atualizar Peso';

  @override
  String get cats_saveCat => 'Salvar Gato';

  @override
  String get cats_createCat => 'Criar Gato';

  @override
  String get cats_catCreated => 'Gato criado com sucesso!';

  @override
  String get cats_catUpdated => 'Gato atualizado com sucesso!';

  @override
  String get cats_catDeleted => 'Gato excluído com sucesso!';

  @override
  String get cats_errorLoading => 'Erro ao carregar gatos';

  @override
  String get cats_emptyState => 'Nenhum gato cadastrado';

  @override
  String get cats_emptyStateDescription =>
      'Toque no botão + para adicionar seu primeiro gato';

  @override
  String get cats_addCat => 'Adicionar Gato';

  @override
  String get cats_deleteCat => 'Excluir Gato';

  @override
  String cats_deleteConfirmation(String name) {
    return 'Tem certeza que deseja excluir $name?';
  }

  @override
  String get cats_addFirstCat => 'Adicione seu primeiro gato para começar!';

  @override
  String get cats_genderMale => 'Macho';

  @override
  String get cats_genderFemale => 'Fêmea';

  @override
  String get cats_birthDateRequired => 'Data de Nascimento *';

  @override
  String get cats_selectDate => 'Selecione a data';

  @override
  String get cats_invalidWeight => 'Peso inválido';

  @override
  String get cats_descriptionHint => 'Informações adicionais sobre o gato';

  @override
  String get homes_title => 'Residências';

  @override
  String get homes_create => 'Nova Residência';

  @override
  String get homes_edit => 'Editar Residência';

  @override
  String get homes_info => 'Informações da Residência';

  @override
  String get homes_name => 'Nome';

  @override
  String get homes_description => 'Descrição';

  @override
  String get homes_address => 'Endereço';

  @override
  String get homes_createHome => 'Criar Residência';

  @override
  String get homes_homeCreated => 'Residência criada com sucesso!';

  @override
  String get homes_homeUpdated => 'Residência atualizada com sucesso!';

  @override
  String get homes_homeDeleted => 'Residência excluída com sucesso!';

  @override
  String get homes_nameRequired => 'Nome da Residência *';

  @override
  String get homes_nameHint => 'Ex: Casa Principal, Apartamento, Sítio...';

  @override
  String get homes_nameRequiredError => 'O nome da residência é obrigatório';

  @override
  String get homes_nameMinLength => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get homes_descriptionHint =>
      'Informações adicionais sobre a residência...';

  @override
  String get homes_requiredFields => '* Campos obrigatórios';

  @override
  String get error_generic => 'Ops! Algo deu errado';

  @override
  String get error_loading => 'Erro ao carregar';

  @override
  String get error_network => 'Erro de conexão';

  @override
  String get error_server => 'Erro no servidor';

  @override
  String get error_notFound => 'Não encontrado';

  @override
  String get error_unauthorized => 'Não autorizado';

  @override
  String get error_validation => 'Erro de validação';

  @override
  String get error_tryAgain => 'Tentar Novamente';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'MealTime';

  @override
  String get common_save => 'Salvar';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_delete => 'Excluir';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_create => 'Criar';

  @override
  String get common_update => 'Atualizar';

  @override
  String get common_loading => 'Carregando...';

  @override
  String get common_error => 'Erro';

  @override
  String get common_success => 'Sucesso';

  @override
  String get common_retry => 'Tentar novamente';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_close => 'Fechar';

  @override
  String get common_ok => 'OK';

  @override
  String get common_yes => 'Sim';

  @override
  String get common_no => 'Não';

  @override
  String get common_back => 'Voltar';

  @override
  String get common_next => 'Próximo';

  @override
  String get common_previous => 'Anterior';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_refresh => 'Atualizar';

  @override
  String get common_filter => 'Filtrar';

  @override
  String get common_clear => 'Limpar';

  @override
  String get common_required => 'Obrigatório';

  @override
  String get common_optional => 'Opcional';

  @override
  String get common_name => 'Nome';

  @override
  String get common_email => 'E-mail';

  @override
  String get common_password => 'Senha';

  @override
  String get common_description => 'Descrição';

  @override
  String get common_date => 'Data';

  @override
  String get common_time => 'Hora';

  @override
  String get common_weight => 'Peso';

  @override
  String get common_actions => 'Ações';

  @override
  String get navigation_home => 'Início';

  @override
  String get navigation_cats => 'Gatos';

  @override
  String get navigation_weight => 'Peso';

  @override
  String get navigation_statistics => 'Estatísticas';

  @override
  String get navigation_profile => 'Perfil';

  @override
  String get navigation_notifications => 'Notificações';

  @override
  String get auth_logout => 'Sair';

  @override
  String get auth_register => 'Criar Conta';

  @override
  String get auth_signIn => 'Entrar';

  @override
  String get auth_signUp => 'Cadastrar';

  @override
  String get auth_forgotPassword => 'Esqueci minha senha';

  @override
  String get auth_fullName => 'Nome completo';

  @override
  String get auth_nameRequired => 'Nome é obrigatório';

  @override
  String get auth_nameMinLength => 'Nome deve ter pelo menos 2 caracteres';

  @override
  String get auth_emailRequired => 'E-mail é obrigatório';

  @override
  String get auth_emailInvalid => 'E-mail inválido';

  @override
  String get auth_passwordRequired => 'Senha é obrigatória';

  @override
  String get auth_passwordMinLength => 'Senha deve ter pelo menos 6 caracteres';

  @override
  String get auth_confirmPassword => 'Confirmar senha';

  @override
  String get auth_passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get auth_userNotAuthenticated => 'Usuário não autenticado';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_editProfile => 'Editar perfil';

  @override
  String get profile_profileNotFound => 'Perfil não encontrado';

  @override
  String get profile_reload => 'Recarregar';

  @override
  String get profile_profileUpdated => 'Perfil atualizado com sucesso!';

  @override
  String get profile_errorUpdating => 'Erro ao atualizar perfil';

  @override
  String get profile_confirmLogout => 'Confirmar logout';

  @override
  String get profile_logoutConfirmation => 'Tem certeza que deseja sair?';

  @override
  String get profile_logoutError => 'Erro ao fazer logout';

  @override
  String get profile_user => 'Usuário';

  @override
  String get cats_title => 'Meus Gatos';

  @override
  String get cats_create => 'Novo Gato';

  @override
  String get cats_edit => 'Editar Gato';

  @override
  String get cats_name => 'Nome *';

  @override
  String get cats_nameHint => 'Digite o nome do gato';

  @override
  String get cats_nameRequired => 'Nome é obrigatório';

  @override
  String get cats_breed => 'Raça';

  @override
  String get cats_breedHint => 'Ex: Persa, Siamês, SRD';

  @override
  String get cats_gender => 'Sexo';

  @override
  String get cats_color => 'Cor';

  @override
  String get cats_birthDate => 'Data de nascimento';

  @override
  String get cats_currentWeight => 'Peso Atual (kg)';

  @override
  String get cats_targetWeight => 'Peso Alvo (kg)';

  @override
  String get cats_updateWeight => 'Atualizar Peso';

  @override
  String get cats_saveCat => 'Salvar Gato';

  @override
  String get cats_createCat => 'Criar Gato';

  @override
  String get cats_catCreated => 'Gato criado com sucesso!';

  @override
  String get cats_catUpdated => 'Gato atualizado com sucesso!';

  @override
  String get cats_catDeleted => 'Gato excluído com sucesso!';

  @override
  String get cats_errorLoading => 'Erro ao carregar gatos';

  @override
  String get cats_emptyState => 'Nenhum gato cadastrado';

  @override
  String get cats_emptyStateDescription =>
      'Toque no botão + para adicionar seu primeiro gato';

  @override
  String get cats_addCat => 'Adicionar Gato';

  @override
  String get cats_deleteCat => 'Excluir Gato';

  @override
  String cats_deleteConfirmation(String name) {
    return 'Tem certeza que deseja excluir $name?';
  }

  @override
  String get cats_addFirstCat => 'Adicione seu primeiro gato para começar!';

  @override
  String get cats_genderMale => 'Macho';

  @override
  String get cats_genderFemale => 'Fêmea';

  @override
  String get cats_birthDateRequired => 'Data de Nascimento *';

  @override
  String get cats_selectDate => 'Selecione a data';

  @override
  String get cats_invalidWeight => 'Peso inválido';

  @override
  String get cats_descriptionHint => 'Informações adicionais sobre o gato';

  @override
  String get homes_title => 'Residências';

  @override
  String get homes_create => 'Nova Residência';

  @override
  String get homes_edit => 'Editar Residência';

  @override
  String get homes_info => 'Informações da Residência';

  @override
  String get homes_name => 'Nome';

  @override
  String get homes_description => 'Descrição';

  @override
  String get homes_address => 'Endereço';

  @override
  String get homes_createHome => 'Criar Residência';

  @override
  String get homes_homeCreated => 'Residência criada com sucesso!';

  @override
  String get homes_homeUpdated => 'Residência atualizada com sucesso!';

  @override
  String get homes_homeDeleted => 'Residência excluída com sucesso!';

  @override
  String get homes_nameRequired => 'Nome da Residência *';

  @override
  String get homes_nameHint => 'Ex: Casa Principal, Apartamento, Sítio...';

  @override
  String get homes_nameRequiredError => 'O nome da residência é obrigatório';

  @override
  String get homes_nameMinLength => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get homes_descriptionHint =>
      'Informações adicionais sobre a residência...';

  @override
  String get homes_requiredFields => '* Campos obrigatórios';

  @override
  String get error_generic => 'Ops! Algo deu errado';

  @override
  String get error_loading => 'Erro ao carregar';

  @override
  String get error_network => 'Erro de conexão';

  @override
  String get error_server => 'Erro no servidor';

  @override
  String get error_notFound => 'Não encontrado';

  @override
  String get error_unauthorized => 'Não autorizado';

  @override
  String get error_validation => 'Erro de validação';

  @override
  String get error_tryAgain => 'Tentar Novamente';
}
