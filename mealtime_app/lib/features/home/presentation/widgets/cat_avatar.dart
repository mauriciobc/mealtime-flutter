import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

/// Shared cat avatar widget used across many home sections.
/// [size] controls the circle diameter. [size] = 60 for large, 40 for small.
class CatAvatar extends StatelessWidget {
  const CatAvatar({super.key, required this.cat, this.size = 40});

  final Cat cat;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = cat.imageUrl;
    final hasValidImageUrl = imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    if (hasValidImageUrl) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl.trim(),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: size,
              height: size,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Material3LoadingIndicator(size: 20.0),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: size,
              height: size,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.pets,
                size: size * 0.5,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.pets,
        size: size * 0.5,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
