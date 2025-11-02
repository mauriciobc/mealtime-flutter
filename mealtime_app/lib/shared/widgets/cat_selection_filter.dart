import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

/// Widget de seleção de gatos estilo "Avatar Filter" com animação ondulante (wobbly)
/// Material Design 3.
///
/// Este widget exibe uma lista horizontal de avatares de gatos com uma animação
/// ondulante ao redor do item selecionado, seguindo as especificações do Material 3.
class CatSelectionFilter extends StatefulWidget {
  const CatSelectionFilter({
    super.key,
    required this.cats,
    required this.onSelected,
    this.initialSelectedId,
  });

  /// Lista de gatos disponíveis para seleção
  final List<Cat> cats;

  /// Callback chamado quando um gato é selecionado ou desselecionado.
  /// Retorna o ID do gato selecionado ou null se desselecionado.
  final ValueChanged<String?> onSelected;

  /// ID opcional do gato inicialmente selecionado
  final String? initialSelectedId;

  @override
  State<CatSelectionFilter> createState() => _CatSelectionFilterState();
}

class _CatSelectionFilterState extends State<CatSelectionFilter>
    with SingleTickerProviderStateMixin {
  String? _selectedId;

  // Controlador de animação para a borda ondulante
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedId;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Duração de 1s
    );

    // Se houver seleção inicial, iniciar animação
    if (_selectedId != null) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAvatar(BuildContext context, Cat cat, bool isSelected) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // --- O Avatar ---
        // Adicionamos padding para dar espaço para a borda ondulante desenhar ao redor.
        // Padding reduzido de 10.0 para 5.0 para diminuir espaço entre avatares.
        Padding(
          padding: const EdgeInsets.all(5.0), // Espaço para a borda
          child: _buildCatAvatar(context, cat, colorScheme),
        ),

        // --- O Estado Selecionado (Borda Ondulante) ---
        // Usamos AnimatedOpacity para esmaecer a borda dentro e fora.
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isSelected ? 1.0 : 0.0,
          // Ignorar eventos de ponteiro para que o toque vá para o GestureDetector
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  // O tamanho deve ser grande o suficiente para conter a borda ondulante
                  // fora do avatar. (32 raio + 5 padding) * 2 = 74.
                  // Usamos 88 para espaço extra. A borda será desenhada dentro do padding de 5dp.
                  size: const Size(88, 88),
                  painter: WobblyBorderPainter(
                    color: colorScheme.primary,
                    strokeWidth: 4.0, // 4.0dp conforme especificação M3
                    animationValue: _animationController.value,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatAvatar(
    BuildContext context,
    Cat cat,
    ColorScheme colorScheme,
  ) {
    final imageUrl = cat.imageUrl;
    final hasValidImageUrl = imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    if (hasValidImageUrl) {
      final trimmedUrl = imageUrl.trim();
      return CircleAvatar(
        radius: 32,
        backgroundColor: colorScheme.surfaceContainerHighest,
        backgroundImage: CachedNetworkImageProvider(trimmedUrl),
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.pets,
        size: 32,
        color: colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Um ListView horizontal é perfeito para isso
    return SizedBox(
      height: 100, // Restringir altura da lista
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.cats.length,
        itemBuilder: (BuildContext context, int index) {
          final Cat cat = widget.cats[index];
          final bool isSelected = _selectedId == cat.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                // Alternar seleção:
                // Se tocar novamente, desselecionar. Caso contrário, selecionar.
                if (_selectedId == cat.id) {
                  _selectedId = null;
                  _animationController.stop();
                  _animationController.reset();
                } else {
                  _selectedId = cat.id;
                  _animationController.repeat(); // Iniciar animação ondulante
                }
              });

              // Notificar o widget pai
              widget.onSelected(_selectedId);
            },
            child: _buildAvatar(context, cat, isSelected),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------
// O Custom Painter para a Borda Ondulante
// -----------------------------------------------------------------

class WobblyBorderPainter extends CustomPainter {
  WobblyBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.animationValue,
  });

  final Color color;
  final double strokeWidth;
  final double animationValue; // Um valor de 0.0 a 1.0

  /// Função helper para criar um ponto "ondulante", inspirado nas especificações M3
  Offset getWavyPoint(
    Offset center,
    double radius,
    double angle,
    double amplitude,
  ) {
    // O animationValue faz a onda viajar ao redor do círculo
    final double phase = animationValue * 2 * math.pi;

    // Combinar duas ondas seno conforme especificações estilo M3
    // Esses números (14, 7) derivam da circunferência do círculo
    // e do comprimento de onda desejado de 15dp.
    final double wave1 = math.sin((angle * 14) + (phase * 2.0)); // 14 lobos, 2x velocidade
    final double wave2 = math.sin((angle * 7) + (phase * 1.0)); // 7 lobos, 1x velocidade

    // Média deles
    final double wave = (wave1 + wave2) * 0.5; // Média, resultado é -1 a 1

    // 'wave' agora está entre -1 e 1.
    final double wobble = amplitude * wave;

    final double wobblyRadius = radius + wobble;

    return Offset(
      center.dx + wobblyRadius * math.cos(angle),
      center.dy + wobblyRadius * math.sin(angle),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Centro do canvas
    final Offset center = Offset(size.width / 2, size.height / 2);

    // O raio é metade da largura, menos padding para o stroke
    final double radius = (size.width / 2) - (strokeWidth * 2.5);
    // Usar amplitude de 1.6dp diretamente da especificação
    const double amplitude = 1.6;

    final Path path = Path();

    const int segments = 64; // Segmentos aumentados para onda mais suave e rápida

    for (int i = 0; i <= segments; i++) {
      final double angle = (i / segments) * 2 * math.pi;
      final Offset point = getWavyPoint(center, radius, angle, amplitude);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        // Um lineTo simples é performático e efetivo para tantos segmentos
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WobblyBorderPainter oldDelegate) {
    // Repintar sempre que o valor da animação mudar
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

