import 'package:flutter/material.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

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
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
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
                  style: Theme.of(context).textTheme.bodyLarge,
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

/// Indicador de loading Material 3 Expressive
/// Usa polígonos que se transformam (morphing polygons) seguindo as especificações
/// Material 3 Expressive do Flutter
class Material3LoadingIndicator extends StatelessWidget {
  const Material3LoadingIndicator({
    super.key,
    this.variant,
    this.size = 48.0,
  });

  /// Variante do indicador: default ou contained
  final LoadingIndicatorM3EVariant? variant;
  
  /// Tamanho do indicador (48dp é o padrão Material 3)
  final double size;

  @override
  Widget build(BuildContext context) {
    // LoadingIndicatorM3E usa automaticamente as cores do ColorScheme
    // - Default: container usa secondaryContainer, indicador usa primary
    // - Contained: container usa primaryContainer, indicador usa onPrimaryContainer
    return Semantics(
      label: 'Carregando',
      value: 'Carregando dados',
      child: SizedBox(
        width: size,
        height: size,
        child: variant != null
            ? LoadingIndicatorM3E(
                variant: variant!,
                // Opcionalmente pode personalizar a cor do indicador
                // Se não especificado, usa as cores do tema automaticamente
              )
            : const LoadingIndicatorM3E(),
      ),
    );
  }
}
