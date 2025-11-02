import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/features/auth/data/models/user_profile.dart';
import 'package:mealtime_app/features/auth/presentation/pages/login_page.dart';
import 'package:mealtime_app/shared/widgets/avatar_widget.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/main.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _avatarUrl;
  var _loading = true;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  /// Carrega o perfil do usuário
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = SupabaseConfig.client.auth.currentSession?.user.id;
      if (userId == null) {
        _navigateToLogin();
        return;
      }

      try {
        final data = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (data != null) {
          _profile = UserProfile.fromJson(data);
          _usernameController.text = _profile?.username ?? '';
          _websiteController.text = _profile?.website ?? '';
          _avatarUrl = _profile?.avatarUrl;
        } else {
          // Profile não existe, criar um padrão com dados do Auth
          debugPrint('Profile não encontrado, usando dados do Auth');
        }
      } on PostgrestException catch (error) {
        // Se a tabela profiles não existir ou houver erro,
        // apenas continuar sem profile (usaremos dados do Auth)
        if (mounted) {
          debugPrint(
            'Aviso: Não foi possível carregar profile: ${error.message}',
          );
        }
      }
    } catch (error) {
      if (mounted) {
        debugPrint('Erro ao carregar perfil: ${error.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Atualiza o perfil do usuário
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });

    final userName = _usernameController.text.trim();
    final website = _websiteController.text.trim();
    final user = SupabaseConfig.client.auth.currentUser;

    if (user == null) {
      _navigateToLogin();
      return;
    }

    final updates = {
      'id': user.id,
      'username': userName,
      'website': website,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await SupabaseConfig.client.from('profiles').upsert(updates);
      if (mounted) {
        context.showSnackBar('Perfil atualizado com sucesso!');
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBar(error.message, isError: true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar(
          'Erro inesperado: ${error.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Faz logout do usuário
  Future<void> _signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      _navigateToLogin();
    } catch (error) {
      if (mounted) {
        context.showSnackBar(
          'Erro ao fazer logout: ${error.toString()}',
          isError: true,
        );
      }
    }
  }

  /// Callback para upload de avatar
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        _navigateToLogin();
        return;
      }

      await SupabaseConfig.client.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });

      if (mounted) {
        context.showSnackBar('Foto de perfil atualizada!');
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBar(error.message, isError: true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar(
          'Erro inesperado: ${error.toString()}',
          isError: true,
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Material3LoadingIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          // Avatar
          AvatarWidget(imageUrl: _avatarUrl, onUpload: _onUpload, size: 120),
          const SizedBox(height: 24),

          // Informações do usuário
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações do Usuário',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome de usuário',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website',
                      prefixIcon: Icon(Icons.web),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botão de atualizar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _updateProfile,
              child: _loading
                  ? const Material3LoadingIndicator(size: 20.0)
                  : const Text('Atualizar Perfil'),
            ),
          ),
          const SizedBox(height: 16),

          // Informações da conta
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações da Conta',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('ID do Usuário'),
                    subtitle: Text(
                      SupabaseConfig.client.auth.currentUser?.id ?? 'N/A',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(
                      SupabaseConfig.client.auth.currentUser?.email ?? 'N/A',
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.verified),
                    title: const Text('Status da Conta'),
                    subtitle: Text(
                      SupabaseConfig
                                  .client
                                  .auth
                                  .currentUser
                                  ?.emailConfirmedAt !=
                              null
                          ? 'Verificado'
                          : 'Não verificado',
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Conta criada em'),
                    subtitle: Text(
                      SupabaseConfig.client.auth.currentUser?.createdAt != null
                          ? _formatDate(
                              DateTime.parse(SupabaseConfig
                                  .client.auth.currentUser!.createdAt),
                            )
                          : 'N/A',
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Último acesso'),
                    subtitle: Text(
                      SupabaseConfig.client.auth.currentUser?.lastSignInAt !=
                              null
                          ? _formatDate(
                              DateTime.parse(SupabaseConfig
                                  .client.auth.currentUser!.lastSignInAt!),
                            )
                          : 'N/A',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
