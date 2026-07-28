import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:mealtime_app/features/profile/presentation/widgets/profile_avatar_widget.dart';
import 'package:mealtime_app/features/profile/presentation/widgets/profile_edit_bottom_sheet.dart';
import 'package:mealtime_app/features/profile/presentation/widgets/profile_dashboard_widget.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/shared/widgets/expressive_dialogs.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = SupabaseConfig.client.auth.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: M3EAppBar.top(
          titleText: context.l10n.profile_title,
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: Text(context.l10n.auth_userNotAuthenticated),
        ),
      );
    }

    final profileAsync = ref.watch(profileProvider(user.id));

    return Scaffold(
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Scaffold(
              appBar: M3EAppBar.top(
                titleText: context.l10n.profile_title,
                automaticallyImplyLeading: true,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.l10n.profile_profileNotFound),
                    const SizedBox(height: 16),
                    M3EButton(
                      style: M3EButtonStyle.filled,
                      size: M3EButtonSize.md,
                      shape: M3EButtonShape.round,
                      onPressed: () {
                        final provider = profileProvider(user.id);
                        ref.read(provider.notifier).refresh();
                      },
                      child: Text(context.l10n.profile_reload),
                    ),
                  ],
                ),
              ),
            );
          }

          return M3ERefreshIndicator(
            onRefresh: () async {
              HapticsService.mediumImpact();
              final provider = profileProvider(user.id);
              await ref.read(provider.notifier).refresh();
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  pinned: true,
                  floating: true,
                  stretch: true,
                  title: Text(context.l10n.profile_title),
                  actions: [
                    M3EIconButton(
                      onPressed: () => _showEditBottomSheet(context, ref, user.id, profileAsync),
                      icon: const Icon(Icons.edit),
                      tooltip: context.l10n.profile_editProfile,
                    ),
                    M3EIconButton(
                      onPressed: () => _handleLogout(context, ref),
                      icon: const Icon(Icons.logout),
                      tooltip: context.l10n.auth_logout,
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      ProfileAvatarWidget(
                        imageUrl: profile.avatarUrl,
                        userId: user.id,
                        size: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.fullName ??
                            profile.email?.split('@').first ??
                            context.l10n.profile_user,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (profile.username != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '@${profile.username}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: ProfileDashboardWidget(profile: profile),
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
        error: (error, stack) => Scaffold(
          appBar: M3EAppBar.top(
            titleText: context.l10n.profile_title,
            automaticallyImplyLeading: true,
          ),
          body: Center(
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
                M3EButton(
                  style: M3EButtonStyle.filled,
                  size: M3EButtonSize.md,
                  shape: M3EButtonShape.round,
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
      ),
    );
  }

  void _showEditBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String userId,
    AsyncValue<Profile?> profileAsync,
  ) {
    HapticsService.mediumImpact();
    final profile = profileAsync.value;
    if (profile == null) return;

    ExpressiveBottomSheet.show<Profile>(
      context: context,
      child: ProfileEditBottomSheet(profile: profile),
      isScrollControlled: true,
    ).then((updatedProfile) async {
      if (updatedProfile != null) {
        final provider = profileProvider(userId);
        final notifier = ref.read(provider.notifier);
        final success = await notifier.updateProfile(updatedProfile);

        if (context.mounted) {
          HapticsService.success();
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
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: M3Shapes.shapeMedium,
              ),
            ),
          );
        }
      }
    });
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showExpressiveConfirmation(
      context: context,
      title: context.l10n.profile_confirmLogout,
      message: context.l10n.profile_logoutConfirmation,
      confirmText: context.l10n.auth_logout,
      cancelText: context.l10n.common_cancel,
      onConfirm: () async {
        try {
          await SupabaseConfig.client.auth.signOut();
          if (context.mounted) {
            context.go('/login');
          }
        } catch (error, stackTrace) {
          developer.log(
            'Error during logout',
            error: error,
            stackTrace: stackTrace,
            name: 'ProfilePage._handleLogout',
          );
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
                      TextSpan(text: error.toString()),
                    ],
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: M3Shapes.shapeMedium,
                ),
              ),
            );
          }
        }
      },
    );
  }
}
