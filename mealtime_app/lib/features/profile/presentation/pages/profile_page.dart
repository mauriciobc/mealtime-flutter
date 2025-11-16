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
import 'package:m3e_collection/m3e_collection.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = SupabaseConfig.client.auth.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.profile_title)),
        body: Center(
          child: Text(context.l10n.auth_userNotAuthenticated),
        ),
      );
    }

    final profileAsync = ref.watch(profileProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile_title),
        actions: [
          IconButtonM3E(
            onPressed: () => _showEditDialog(context, ref, user.id, profileAsync),
            icon: const Icon(Icons.edit),
            tooltip: context.l10n.profile_editProfile,
          ),
          IconButtonM3E(
            onPressed: () => _handleLogout(context, ref),
            icon: const Icon(Icons.logout),
            tooltip: context.l10n.auth_logout,
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
                  Text(context.l10n.profile_profileNotFound),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final provider = profileProvider(user.id);
                      ref.read(provider.notifier).refresh();
                    },
                    child: Text(context.l10n.profile_reload),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final provider = profileProvider(user.id);
              await ref.read(provider.notifier).refresh();
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
                            context.l10n.profile_user,
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
                  text: '${context.l10n.error_loading}: ',
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
                onPressed: () {
                  final provider = profileProvider(user.id);
                  ref.read(provider.notifier).refresh();
                },
                child: Text(context.l10n.common_retry),
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
        final provider = profileProvider(userId);
        final notifier = ref.read(provider.notifier);
        final success = await notifier.updateProfile(updatedProfile);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? context.l10n.profile_profileUpdated
                    : context.l10n.profile_errorUpdating,
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
        title: Text(context.l10n.profile_confirmLogout),
        content: Text(context.l10n.profile_logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.common_cancel),
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

                // Primeiro fecha o diálogo de confirmação se ainda estiver montado
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                // Depois mostra o erro usando o contexto externo
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: SelectableText.rich(
                        TextSpan(
                          text: '${context.l10n.profile_logoutError}: ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                          children: [
                            TextSpan(
                              text: error.toString(),
                            ),
                          ],
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: Text(context.l10n.auth_logout),
          ),
        ],
      ),
    );
  }
}

