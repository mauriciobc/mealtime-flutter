import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:material_3_expressive/components/buttons/styles/m3e_button_decoration.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:mealtime_app/features/onboarding/presentation/widgets/onboarding_illustration.dart';
import 'package:mealtime_app/services/api/homes_api_service.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class StepHousehold extends StatefulWidget {
  const StepHousehold({
    super.key,
    required this.accentColor,
    required this.onAccentColor,
  });

  final Color accentColor;
  final Color onAccentColor;

  @override
  State<StepHousehold> createState() => _StepHouseholdState();
}

class _StepHouseholdState extends State<StepHousehold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _createFormKey = GlobalKey<FormState>();
  final _joinFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _isCreating = false;
  bool _isJoining = false;
  String? _createError;
  String? _joinError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _createHousehold() {
    if (!_createFormKey.currentState!.validate()) return;
    setState(() {
      _isCreating = true;
      _createError = null;
    });
    context.read<HomesBloc>().add(
          CreateHomeEvent(
            name: _nameController.text.trim(),
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          ),
        );
  }

  Future<void> _joinHousehold() async {
    if (!_joinFormKey.currentState!.validate()) return;
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _isJoining = true;
      _joinError = null;
    });
    try {
      final homesApi = sl<HomesApiService>();
      final authLocal = sl<AuthLocalDataSource>();
      final response = await homesApi.joinHousehold({'inviteCode': code});
      if (!mounted) return;
      if (response.success && response.data != null) {
        final householdId = response.data!.id;
        final user = await authLocal.getUser();
        if (user != null) {
          await authLocal.saveUser(
            user.copyWith(householdId: householdId, currentHomeId: householdId),
          );
        }
        if (!mounted) return;
        context.read<OnboardingBloc>().add(
              OnboardingHouseholdJoined(householdId: householdId),
            );
      } else {
        setState(() {
          _joinError = response.error ?? 'Não foi possível entrar. Tente novamente.';
          _isJoining = false;
        });
      }
    } on DioException catch (e) {
      final msg = _joinErrorMessage(e);
      if (mounted) {
        setState(() {
          _joinError = msg;
          _isJoining = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _joinError = 'Tente novamente mais tarde.';
          _isJoining = false;
        });
      }
    }
  }

  /// Mapeia status/body da API para mensagens amigáveis.
  static String _joinErrorMessage(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final String? serverMessage = body is Map<String, dynamic>
        ? (body['error'] as String? ?? body['message'] as String?)
        : null;
    final lower = (serverMessage ?? '').toLowerCase();
    if (status == 404 || lower.contains('inválido') || lower.contains('código')) {
      return 'Código inválido ou expirado.';
    }
    if (status == 400) {
      if (lower.contains('este domicínio') || lower.contains('esta residência')) {
        return 'Você já faz parte desta residência.';
      }
      if (lower.contains('outro domicínio') || lower.contains('outra residência')) {
        return 'Você já está em outra residência. Saia dela antes de entrar em uma nova.';
      }
    }
    if (status == 409 || status == 500) {
      return 'Tente novamente mais tarde.';
    }
    return serverMessage?.isNotEmpty == true
        ? serverMessage!
        : 'Não foi possível entrar. Tente novamente.';
  }

  static double _tabBarViewHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final preferred = h * 0.32;
    return preferred.clamp(220.0, 320.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomesBloc, HomesState>(
      listener: (context, state) {
        if (!_isCreating) return;
        if (state is HomesLoaded && state.homes.isNotEmpty) {
          setState(() {
            _isCreating = false;
            _createError = null;
          });
          final newHome = state.homes.last;
          context
              .read<OnboardingBloc>()
              .add(OnboardingHouseholdCreated(householdId: newHome.id));
        } else if (state is HomesError) {
          setState(() {
            _isCreating = false;
            _createError = state.message;
          });
        }
      },
      child: Column(
        children: [
          OnboardingIllustration(
            illustrationKey: 'household',
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
                    'Sua Residência 🏠',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMediumEmphasized
                        ?.copyWith(color: widget.accentColor),
                  ),
                  SizedBox(height: M3SpacingToken.space8.value),
                  Text(
                    'Crie um novo lar ou entre em um existente com código de convite.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              // Remover alpha - usar role semântico correto
                              ,
                          height: 1.5,
                        ),
                  ),
                  if (_createError != null) ...[
                    SelectableText.rich(
                      TextSpan(
                        text: _createError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: M3SpacingToken.space16.value),
                  ],
                  SizedBox(height: M3SpacingToken.space24.value),

                  // Tab toggle
                  Container(
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.08),
                      borderRadius: M3Shapes.shapeMedium,
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: widget.accentColor,
                        borderRadius: M3Shapes.shapeSmall,
                      ),
                      labelColor: widget.onAccentColor,
                      unselectedLabelColor: widget.accentColor,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .titleMediumEmphasized,
                      dividerColor: Theme.of(context).colorScheme.outlineVariant,
                      tabs: const [
                        Tab(text: 'Criar'),
                        Tab(text: 'Entrar'),
                      ],
                    ),
                  ),
                  SizedBox(height: M3SpacingToken.space24.value),

                  SizedBox(
                    height: _tabBarViewHeight(context),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _CreateTab(
                          formKey: _createFormKey,
                          nameController: _nameController,
                          descController: _descController,
                          accentColor: widget.accentColor,
                          onAccentColor: widget.onAccentColor,
                          isLoading: _isCreating,
                          onSubmit: _createHousehold,
                        ),
                        _JoinTab(
                          formKey: _joinFormKey,
                          codeController: _inviteCodeController,
                          accentColor: widget.accentColor,
                          onAccentColor: widget.onAccentColor,
                          isLoading: _isJoining,
                          joinError: _joinError,
                          onSubmit: _joinHousehold,
                        ),
                      ],
                    ),
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

class _CreateTab extends StatelessWidget {
  const _CreateTab({
    required this.formKey,
    required this.nameController,
    required this.descController,
    required this.accentColor,
    required this.onAccentColor,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descController;
  final Color accentColor;
  final Color onAccentColor;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
            decoration: _inputDecoration(
              context,
              label: 'Nome da residência *',
              hint: 'Ex: Casa da família Silva',
              accentColor: accentColor,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          TextFormField(
            controller: descController,
            decoration: _inputDecoration(
              context,
              label: 'Descrição (opcional)',
              hint: 'Ex: Apartamento em São Paulo',
              accentColor: accentColor,
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: M3EButton(
              style: M3EButtonStyle.filled,
              size: M3EButtonSize.md,
              shape: M3EButtonShape.round,
              decoration: M3EButtonDecoration.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: onAccentColor,
              ),
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const Material3LoadingIndicator(size: 20)
                  : Text(
                      'Criar Residência',
                      style: Theme.of(context)
                          .textTheme
                          .titleMediumEmphasized,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinTab extends StatelessWidget {
  const _JoinTab({
    required this.formKey,
    required this.codeController,
    required this.accentColor,
    required this.onAccentColor,
    required this.isLoading,
    required this.joinError,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final Color accentColor;
  final Color onAccentColor;
  final bool isLoading;
  final String? joinError;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: codeController,
            decoration: _inputDecoration(
              context,
              label: 'Código de convite *',
              hint: 'Cole o código aqui',
              accentColor: accentColor,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Código obrigatório' : null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          SizedBox(height: M3SpacingToken.space8.value),
          Text(
            'Peça o código para quem já tem uma residência no MealTime.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          if (joinError != null) ...[
            SizedBox(height: M3SpacingToken.space16.value),
            SelectableText.rich(
              TextSpan(
                text: joinError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: M3EButton(
              style: M3EButtonStyle.filled,
              size: M3EButtonSize.md,
              shape: M3EButtonShape.round,
              decoration: M3EButtonDecoration.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: onAccentColor,
              ),
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const Material3LoadingIndicator(size: 20)
                  : Text(
                      'Entrar',
                      style: Theme.of(context)
                          .textTheme
                          .titleMediumEmphasized,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context, {
  required String label,
  required String hint,
  required Color accentColor,
}) {
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
        color: Theme.of(context).colorScheme.outline,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: M3Shapes.shapeMedium,
      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: M3Shapes.shapeMedium,
      borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
    ),
  );
}
