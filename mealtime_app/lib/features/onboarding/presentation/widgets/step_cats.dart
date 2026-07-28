import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/constants/m3_animation.dart';
import 'package:mealtime_app/core/theme/contrast_utils.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/m3e.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:mealtime_app/features/onboarding/presentation/widgets/onboarding_illustration.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class StepCats extends StatefulWidget {
  const StepCats({
    super.key,
    required this.accentColor,
    required this.onAccentColor,
    required this.householdId,
  });

  final Color accentColor;
  final Color onAccentColor;
  final String householdId;

  @override
  State<StepCats> createState() => _StepCatsState();
}

class _StepCatsState extends State<StepCats> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  String? _selectedGender;
  bool _isAdding = false;
  String? _addCatError;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _breedController.clear();
    setState(() => _selectedGender = null);
  }

  void _addCat() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isAdding = true;
      _addCatError = null;
    });

    final cat = Cat(
      id: '',
      name: _nameController.text.trim(),
      homeId: widget.householdId,
      breed: _breedController.text.trim().isEmpty
          ? null
          : _breedController.text.trim(),
      gender: _selectedGender,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<CatsBloc>().add(CreateCat(cat));
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingBloc>().state;
    final addedCats = onboarding.addedCats;

    return BlocListener<CatsBloc, CatsState>(
      listener: (context, state) {
        if (!_isAdding) return;
        if (state is CatOperationSuccess) {
          setState(() {
            _isAdding = false;
            _addCatError = null;
          });
          final newCat = state.updatedCat ??
              (state.cats.isNotEmpty ? state.cats.last : null);
          if (newCat != null) {
            context.read<OnboardingBloc>().add(OnboardingCatAdded(cat: newCat));
          }
          _resetForm();
        } else if (state is CatsLoaded && state.cats.isNotEmpty) {
          setState(() {
            _isAdding = false;
            _addCatError = null;
          });
          final newCat = state.cats.last;
          context.read<OnboardingBloc>().add(OnboardingCatAdded(cat: newCat));
          _resetForm();
        } else if (state is CatsError) {
          setState(() {
            _isAdding = false;
            _addCatError = state.failure.toString();
          });
        }
      },
      child: Column(
        children: [
          OnboardingIllustration(
            illustrationKey: 'cats',
            accentColor: widget.accentColor,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: M3SpacingToken.space24.value,
                vertical: M3SpacingToken.space24.value,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seus Gatos 🐱',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMediumEmphasized
                        ?.copyWith(color: widget.accentColor),
                  ),
                  SizedBox(height: M3SpacingToken.space8.value),
                  Text(
                    'Adicione pelo menos um gatinho para começar.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                  if (_addCatError != null)
                    SelectableText.rich(
                      TextSpan(
                        text: _addCatError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  SizedBox(height: M3SpacingToken.space16.value),

                  // Added cats mini-list
                  if (addedCats.isNotEmpty) ...[
                    SizedBox(height: M3SpacingToken.space16.value),
                    ...addedCats.map(
                      (c) => _CatChip(
                        cat: c,
                        accentColor: widget.accentColor,
                      ),
                    ),
                  ],

                  SizedBox(height: M3SpacingToken.space24.value),

                  // Add cat form
                  _CatForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    breedController: _breedController,
                    selectedGender: _selectedGender,
                    accentColor: widget.accentColor,
                    onGenderChanged: (g) => setState(() => _selectedGender = g),
                  ),

                  SizedBox(height: M3SpacingToken.space24.value),

                  Row(
                    children: [
                      if (addedCats.isNotEmpty)
                        Expanded(
                          child: M3EButton(
                            style: M3EButtonStyle.outlined,
                            size: M3EButtonSize.md,
                            shape: M3EButtonShape.round,
                            decoration: M3EButtonDecoration.styleFrom(
                              foregroundColor: widget.accentColor,
                              side: BorderSide(color: widget.accentColor),
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleMediumEmphasized,
                            ),
                            onPressed: _isAdding ? null : _addCat,
                            child: const Text('Adicionar Outro'),
                          ),
                        ),
                      if (addedCats.isNotEmpty) SizedBox(width: M3SpacingToken.space12.value),
                      Expanded(
                        child: M3EButton(
                          style: M3EButtonStyle.filled,
                          size: M3EButtonSize.md,
                          shape: M3EButtonShape.round,
                          decoration: M3EButtonDecoration.styleFrom(
                            backgroundColor: widget.accentColor,
                            foregroundColor: widget.onAccentColor,
                          ),
                          onPressed: _isAdding
                              ? null
                              : () {
                                  if (addedCats.isEmpty) {
                                    _addCat();
                                  } else {
                                    context
                                        .read<OnboardingBloc>()
                                        .add(const OnboardingNextStep());
                                  }
                                },
                          child: _isAdding
                              ? const Material3LoadingIndicator(size: 20)
                              : Text(
                                  addedCats.isEmpty
                                      ? 'Adicionar Gato'
                                      : 'Continuar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMediumEmphasized,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({required this.cat, required this.accentColor});

  final Cat cat;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: M3Shapes.shapeMedium,
        border: Border.all(color: accentColor.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Text('🐱', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cat.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Icon(Icons.check_circle, color: accentColor, size: 18),
        ],
      ),
    );
  }
}

class _CatForm extends StatelessWidget {
  const _CatForm({
    required this.formKey,
    required this.nameController,
    required this.breedController,
    required this.selectedGender,
    required this.accentColor,
    required this.onGenderChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController breedController;
  final String? selectedGender;
  final Color accentColor;
  final ValueChanged<String?> onGenderChanged;

  InputDecoration _dec(BuildContext context, String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelStyle: TextStyle(color: accentColor),
      focusedBorder: OutlineInputBorder(
        borderRadius: M3Shapes.shapeMedium,
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: M3Shapes.shapeMedium,
        borderSide: BorderSide(
          color:
              Theme.of(context).colorScheme.outline,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: M3Shapes.shapeMedium,
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: M3Shapes.shapeMedium,
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
            decoration: _dec(context, 'Nome do gato *', 'Ex: Mimi'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          TextFormField(
            controller: breedController,
            decoration:
                _dec(context, 'Raça (opcional)', 'Ex: Siamês, Vira-lata'),
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          Text(
            'Sexo',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _GenderChip(
                label: '♂ Macho',
                value: 'male',
                selected: selectedGender == 'male',
                accentColor: accentColor,
                onTap: () => onGenderChanged(
                    selectedGender == 'male' ? null : 'male'),
              ),
              const SizedBox(width: 10),
              _GenderChip(
                label: '♀ Fêmea',
                value: 'female',
                selected: selectedGender == 'female',
                accentColor: accentColor,
                onTap: () => onGenderChanged(
                    selectedGender == 'female' ? null : 'female'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: M3Animation.durationShort2,
        curve: M3Animation.standardCurve,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accentColor : accentColor.withValues(alpha: 0.08),
          borderRadius: M3Shapes.shapeXLarge,
          border: Border.all(
            color: accentColor,
            width: selected ? 0 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? ContrastUtils.getContrastText(
                    accentColor,
                    minRatio: 3.0,
                    lightOption: Colors.white,
                    darkOption: Colors.black,
                  )
                : accentColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
