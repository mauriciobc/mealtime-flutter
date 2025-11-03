import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:mealtime_app/features/profile/presentation/widgets/profile_avatar_widget.dart';
import 'package:mealtime_app/features/profile/presentation/widgets/profile_tabs_widget.dart';
import 'package:mealtime_app/features/profile/presentation/widgets/profile_edit_dialog.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = SupabaseConfig.client.auth.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(
          child: Text('Usuário não autenticado'),
        ),
      );
    }

    final profileAsync = ref.watch(profileNotifierProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(context, ref, user.id, profileAsync),
            icon: const Icon(Icons.edit),
            tooltip: 'Editar perfil',
          ),
          IconButton(
            onPressed: () => _handleLogout(context, ref),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Perfil não encontrado'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(profileNotifierProvider(user.id).notifier)
                        .refresh(),
                    child: const Text('Recarregar'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(profileNotifierProvider(user.id).notifier).refresh();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      ProfileAvatarWidget(
                        imageUrl: profile.avatarUrl,
                        userId: user.id,
                        size: 120,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.fullName ??
                            profile.email?.split('@').first ??
                            'Usuário',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: ProfileTabsWidget(profile: profile),
                ),
              ],
            ),
          );
        },
        loading: () => const Scaffold(
          body: Center(
            child: Material3LoadingIndicator(),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableText.rich(
                TextSpan(
                  text: 'Erro ao carregar perfil: ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  children: [
                    TextSpan(
                      text: error.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(profileNotifierProvider(user.id).notifier)
                    .refresh(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
    AsyncValue<Profile?> profileAsync,
  ) {
    final profile = profileAsync.value;
    if (profile == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => ProfileEditDialog(
        profile: profile,
      ),
    ).then((updatedProfile) async {
      if (updatedProfile != null) {
        final notifier = ref.read(profileNotifierProvider(userId).notifier);
        final success = await notifier.updateProfile(updatedProfile);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Perfil atualizado com sucesso!'
                    : 'Erro ao atualizar perfil',
              ),
              backgroundColor: success
                  ? null
                  : Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    });
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar logout'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await SupabaseConfig.client.auth.signOut();
                // Só fecha o diálogo e navega se o signOut for bem-sucedido
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } catch (error, stackTrace) {
                // Log do erro para debugging
                developer.log(
                  'Erro ao fazer logout',
                  error: error,
                  stackTrace: stackTrace,
                  name: 'ProfilePage._handleLogout',
                );

                // Não fecha o diálogo em caso de erro
                // Mostra mensagem de erro ao usuário
                if (dialogContext.mounted) {
                  // Mostra erro dentro do diálogo de confirmação
                  showDialog(
                    context: dialogContext,
                    builder: (errorDialogContext) => AlertDialog(
                      title: const Text('Erro ao fazer logout'),
                      content: SelectableText.rich(
                        TextSpan(
                          text: 'Não foi possível fazer logout. ',
                          style: TextStyle(
                            color: Theme.of(errorDialogContext)
                                .colorScheme
                                .error,
                          ),
                          children: [
                            TextSpan(
                              text: 'Tente novamente.',
                              style: TextStyle(
                                color: Theme.of(errorDialogContext)
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(errorDialogContext).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else if (context.mounted) {
                  // Se o diálogo de confirmação já foi fechado, mostra SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erro ao fazer logout: ${error.toString()}',
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

