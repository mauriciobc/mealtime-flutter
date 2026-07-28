import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Material3LoadingIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de loading de tela cheia seguindo especificações Material 3
/// Usado para bloquear a tela enquanto dados são carregados da API
class FullScreenLoadingWidget extends StatelessWidget {
  final String? message;

  const FullScreenLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Material3LoadingIndicator(),
              if (message != null) ...[
                const SizedBox(height: 24),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Façade estável sobre [M3ELoadingIndicator] (material_3_expressive).
class Material3LoadingIndicator extends StatelessWidget {
  const Material3LoadingIndicator({
    super.key,
    this.variant,
    this.size = 48.0,
  });

  /// Variante do indicador: default ou contained
  final M3ELoadingIndicatorVariant? variant;

  /// Tamanho do indicador (48dp é o padrão Material 3)
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: M3ELoadingIndicator(
          variant: variant ?? M3ELoadingIndicatorVariant.defaultStyle,
        ),
      ),
    );
  }
}
