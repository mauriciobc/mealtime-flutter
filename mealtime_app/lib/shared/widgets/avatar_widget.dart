import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

class AvatarWidget extends StatefulWidget {
  final String? imageUrl;
  final Function(String) onUpload;
  final double size;
  final bool showEditButton;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.onUpload,
    this.size = 100,
    this.showEditButton = true,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
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
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: widget.size * 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 80,
    );

    if (imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simular upload - em uma implementação real, você chamaria o data source
      await Future.delayed(const Duration(seconds: 1));

      // Por enquanto, vamos simular uma URL
      final mockUrl = 'https://via.placeholder.com/300x300?text=Avatar';
      widget.onUpload(mockUrl);
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
