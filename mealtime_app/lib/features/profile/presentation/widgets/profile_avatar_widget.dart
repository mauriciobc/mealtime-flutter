import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

class ProfileAvatarWidget extends ConsumerStatefulWidget {
  final String? imageUrl;
  final String userId;
  final double size;
  final bool showEditButton;

  const ProfileAvatarWidget({
    super.key,
    this.imageUrl,
    required this.userId,
    this.size = 120,
    this.showEditButton = true,
  });

  @override
  ConsumerState<ProfileAvatarWidget> createState() =>
      _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends ConsumerState<ProfileAvatarWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            child: ClipOval(child: _buildAvatarContent()),
          ),
          if (widget.showEditButton)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: IconButtonM3E(
                  icon: _isLoading
                      ? Material3LoadingIndicator(size: 16.0)
                      : Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  onPressed: _isLoading ? null : _pickImage,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final user = SupabaseConfig.client.auth.currentUser;
    final initial = (user?.email?.trim().isNotEmpty == true)
        ? user!.email!.trim().substring(0, 1).toUpperCase()
        : 'U';
    
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: widget.size * 0.4,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 85,
    );

    if (imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = profileProvider(widget.userId);
      final notifier = ref.read(provider.notifier);
      final url = await notifier.uploadAvatar(imageFile.path);

      if (url != null && mounted) {
        // Atualizar perfil com nova URL do avatar
        final currentProfile = ref.read(profileProvider(widget.userId));
        if (currentProfile.value != null) {
          final updatedProfile = currentProfile.value!.copyWith(avatarUrl: url);
          await notifier.updateProfile(updatedProfile);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil atualizada!'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erro ao fazer upload'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer upload: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

