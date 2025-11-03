import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget reutilizável para renderizar SVGs com cores dinâmicas do Material 3
///
/// Este widget aplica automaticamente colorização aos SVGs baseado no tema
/// ativo do Material 3, permitindo que os ícones adaptem suas cores
/// automaticamente quando o tema muda.
///
/// Exemplo de uso:
/// ```dart
/// ThemedSvg(
///   assetPath: 'assets/images/icon.svg',
///   size: 24,
///   colorSchemeColor: context.colorScheme.onPrimary,
/// )
/// ```
class ThemedSvg extends StatelessWidget {
  /// Caminho do arquivo SVG no diretório assets
  final String assetPath;

  /// Largura do ícone
  final double? width;

  /// Altura do ícone
  final double? height;

  /// Tamanho único (define tanto width quanto height)
  final double? size;

  /// Cor do ColorScheme do Material 3 a ser aplicada
  final Color? colorSchemeColor;

  /// Label semântico para acessibilidade
  final String? semanticsLabel;

  const ThemedSvg({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.size,
    this.colorSchemeColor,
    this.semanticsLabel,
  }) : assert(
          (width == null && height == null) || size == null,
          'Não é possível definir width/height e size ao mesmo tempo',
        );

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size ?? width,
      height: size ?? height,
      colorFilter: colorSchemeColor != null
          ? ColorFilter.mode(
              colorSchemeColor!,
              BlendMode.srcIn,
            )
          : null,
      semanticsLabel: semanticsLabel,
    );
  }
}

