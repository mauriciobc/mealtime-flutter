import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/features/auth/presentation/pages/login_page.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:mealtime_app/shared/widgets/avatar_widget.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _avatarUrl;
  bool _isSaving = false;
  bool _hasPopulatedInitially = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      if (mounted) _navigateToLogin();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.profile_logoutErrorGeneric}: $error',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToLogin());
      return const Scaffold(
        body: Center(child: Material3LoadingIndicator()),
      );
    }

    final profileAsync = ref.watch(profileProvider(user.id));

    ref.listen<AsyncValue<Profile?>>(profileProvider(user.id), (prev, next) {
      next.whenOrNull(
        data: (profile) {
          if (profile != null && mounted) _populateFields(profile);
        },
        error: (err, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(err.toString()),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
      );
    });

    return profileAsync.when(
      data: (profile) {
        if (profile != null && !_hasPopulatedInitially) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _populateFields(profile);
              setState(() => _hasPopulatedInitially = true);
            }
          });
        }
        return _buildBody(context, user, profile, _isSaving);
      },
      loading: () => const Scaffold(
        body: Center(child: Material3LoadingIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.profile_title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${context.l10n.error_loading}: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(profileProvider(user.id));
                },
                child: Text(context.l10n.common_retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    User user,
    Profile? profile,
    bool isLoading,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile_title),
        actions: [
          IconButtonM3E(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: context.l10n.auth_logout,
          ),
        ],
      ),
      body: ListView(
        padding: const M3EdgeInsets.symmetric(
          vertical: M3SpacingToken.space16,
          horizontal: M3SpacingToken.space12,
        ),
        children: [
          AvatarWidget(
            imageUrl: _avatarUrl,
            onImagePicked: (path) => _onUpload(context, user.id, path),
            size: 120,
          ),
          SizedBox(height: M3SpacingToken.space24.value),
          Card(
            child: Padding(
              padding: const M3EdgeInsets.all(M3SpacingToken.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.profile_userInfo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: M3SpacingToken.space16.value),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.profile_usernameLabel,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    enabled: !isLoading,
                  ),
                  SizedBox(height: M3SpacingToken.space16.value),
                  TextFormField(
                    controller: _websiteController,
                    decoration: InputDecoration(
                      labelText: context.l10n.profile_website,
                      prefixIcon: const Icon(Icons.web),
                    ),
                    keyboardType: TextInputType.url,
                    enabled: !isLoading,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: M3SpacingToken.space24.value),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _updateProfile(context, user.id),
              child: isLoading
                  ? const Material3LoadingIndicator(size: 20.0)
                  : Text(context.l10n.profile_updateProfile),
            ),
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          _buildAccountInfoCard(context, user),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, User user) {
    return Card(
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.profile_accountInfo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            ListTile(
              leading: const Icon(Icons.badge),
              title: Text(context.l10n.profile_userId),
              subtitle: Text(user.id, style: const TextStyle(fontSize: 12)),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(context.l10n.common_email),
              subtitle: Text(user.email ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: Text(context.l10n.profile_accountStatus),
              subtitle: Text(
                user.emailConfirmedAt != null
                    ? context.l10n.profile_verified
                    : context.l10n.profile_notVerified,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(context.l10n.profile_accountCreated),
              subtitle: Text(
                user.createdAt != null && user.createdAt.isNotEmpty
                    ? _formatDate(DateTime.parse(user.createdAt))
                    : 'N/A',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(context.l10n.profile_lastAccess),
              subtitle: Text(
                user.lastSignInAt != null && user.lastSignInAt.isNotEmpty
                    ? _formatDate(DateTime.parse(user.lastSignInAt!))
                    : 'N/A',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _populateFields(Profile profile) {
    if (_usernameController.text != (profile.username ?? '')) {
      _usernameController.text = profile.username ?? '';
    }
    if (_websiteController.text != (profile.website ?? '')) {
      _websiteController.text = profile.website ?? '';
    }
    if (_avatarUrl != profile.avatarUrl && mounted) {
      setState(() => _avatarUrl = profile.avatarUrl);
    }
  }

  Future<void> _onUpload(
    BuildContext context,
    String userId,
    String filePath,
  ) async {
    final notifier = ref.read(profileProvider(userId).notifier);
    String? url;
    try {
      url = await notifier.uploadAvatar(filePath);
    } catch (e, st) {
      developer.log('Avatar upload failed', error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profile_errorUpdating),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (!mounted) return;
    if (url != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profile_profileUpdated)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profile_errorUpdating),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _updateProfile(BuildContext context, String userId) async {
    final profileAsync = ref.read(profileProvider(userId));
    final currentProfile = profileAsync.valueOrNull;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      username: _usernameController.text.trim(),
      website: _websiteController.text.trim(),
    );

    setState(() => _isSaving = true);
    final notifier = ref.read(profileProvider(userId).notifier);
    bool success = false;
    try {
      success = await notifier.updateProfile(updatedProfile);
      if (success) _populateFields(updatedProfile);
    } catch (e, st) {
      developer.log('Profile update failed', error: e, stackTrace: st);
      success = false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.l10n.profile_profileUpdated
              : context.l10n.profile_errorUpdating,
        ),
        backgroundColor: success ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }
}
