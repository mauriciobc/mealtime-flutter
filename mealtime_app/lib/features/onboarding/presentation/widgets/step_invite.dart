import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:material_3_expressive/components/buttons/styles/m3e_button_decoration.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:mealtime_app/features/onboarding/presentation/widgets/onboarding_illustration.dart';
import 'package:mealtime_app/services/api/homes_api_service.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class StepInvite extends StatefulWidget {
  const StepInvite({
    super.key,
    required this.accentColor,
    required this.onAccentColor,
    required this.householdId,
    this.inviteCode,
  });

  final Color accentColor;
  final Color onAccentColor;
  final String householdId;

  /// Populated when the full household detail is available;
  /// leave null to show a placeholder until fetched.
  final String? inviteCode;

  @override
  State<StepInvite> createState() => _StepInviteState();
}

class _StepInviteState extends State<StepInvite> {
  final _emailController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  bool _isSending = false;
  bool _codeCopied = false;
  String? _loadedInviteCode;
  bool _inviteCodeLoading = false;
  String? _inviteCodeError;
  String? _sendInviteError;

  @override
  void initState() {
    super.initState();
    if (widget.householdId.isNotEmpty) _loadInviteCode();
  }

  Future<void> _loadInviteCode() async {
    if (_loadedInviteCode != null || _inviteCodeLoading) return;
    setState(() => _inviteCodeLoading = true);
    _inviteCodeError = null;
    try {
      final api = sl<HomesApiService>();
      final response = await api.getHouseholdById(widget.householdId);
      if (!mounted) return;
      if (response.success && response.data != null) {
        setState(() {
          _loadedInviteCode = response.data!.inviteCode;
          _inviteCodeLoading = false;
          _inviteCodeError = null;
        });
      } else {
        setState(() {
          _inviteCodeLoading = false;
          _inviteCodeError =
              response.error ?? 'Não foi possível carregar o código';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _inviteCodeLoading = false;
          _inviteCodeError = 'Erro ao carregar código: $e';
        });
      }
    }
  }

  String? get _displayInviteCode =>
      widget.inviteCode ?? _loadedInviteCode;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _copyCode() async {
    final code = _displayInviteCode;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    setState(() => _codeCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _codeCopied = false);
    });
  }

  Future<void> _sendInvite() async {
    if (!_emailFormKey.currentState!.validate()) return;
    if (widget.householdId.isEmpty) return;
    setState(() {
      _isSending = true;
      _sendInviteError = null;
    });
    final email = _emailController.text.trim();
    try {
      final api = sl<HomesApiService>();
      final response = await api.inviteMember(
        widget.householdId,
        <String, dynamic>{'email': email},
      );
      if (!mounted) return;
      setState(() => _isSending = false);
      if (response.success) {
        _sendInviteError = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convite enviado!')),
        );
        _emailController.clear();
      } else {
        setState(() {
          _sendInviteError =
              response.error ?? 'Erro ao enviar convite';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
          _sendInviteError = 'Erro ao enviar convite: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        OnboardingIllustration(
          illustrationKey: 'invite',
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Convide Pessoas 💌',
                        style: theme.textTheme.headlineMediumEmphasized
                            ?.copyWith(color: widget.accentColor),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => context
                          .read<OnboardingBloc>()
                          .add(const OnboardingCompleted()),
                      child: const Text('Pular'),
                    ),
                  ],
                ),
                SizedBox(height: M3SpacingToken.space8.value),
                Text(
                  'Compartilhe o código ou convide por e-mail — você pode fazer isso depois também.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: M3SpacingToken.space24.value),

                // ── Share invite code card ────────────────────────────
                _SectionLabel(label: 'Código de convite', accentColor: widget.accentColor),
                SizedBox(height: M3SpacingToken.space8.value),
                _InviteCodeCard(
                  code: _displayInviteCode,
                  loading: _inviteCodeLoading,
                  loadError: _inviteCodeError,
                  accentColor: widget.accentColor,
                  copied: _codeCopied,
                  onCopy: _copyCode,
                ),
                SizedBox(height: M3SpacingToken.space24.value),

                // ── Invite by email ───────────────────────────────────
                _SectionLabel(label: 'Convidar por e-mail', accentColor: widget.accentColor),
                SizedBox(height: M3SpacingToken.space8.value),
                if (_sendInviteError != null) ...[
                  SelectableText.rich(
                    TextSpan(
                      text: _sendInviteError!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: M3SpacingToken.space12.value),
                ],
                Form(
                  key: _emailFormKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'amigo@email.com',
                            floatingLabelStyle:
                                TextStyle(color: widget.accentColor),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: M3Shapes.shapeMedium,
                              borderSide: BorderSide(
                                  color: widget.accentColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: M3Shapes.shapeMedium,
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: M3Shapes.shapeMedium,
                              borderSide: BorderSide(
                                  color: theme.colorScheme.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: M3Shapes.shapeMedium,
                              borderSide: BorderSide(
                                  color: theme.colorScheme.error, width: 2),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'E-mail obrigatório';
                            }
                            final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(v.trim())) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      M3EButton(
                        style: M3EButtonStyle.filled,
                        size: M3EButtonSize.md,
                        shape: M3EButtonShape.round,
                        decoration: M3EButtonDecoration.styleFrom(
                          backgroundColor: widget.accentColor,
                          foregroundColor: widget.onAccentColor,
                        ),
                        onPressed: _isSending ? null : _sendInvite,
                        child: _isSending
                            ? const Material3LoadingIndicator(size: 18)
                            : const Icon(Icons.send_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: M3SpacingToken.space32.value),

                // ── Finish button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: M3EButton(
                    style: M3EButtonStyle.filled,
                    size: M3EButtonSize.md,
                    shape: M3EButtonShape.round,
                    decoration: M3EButtonDecoration.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: widget.onAccentColor,
                    ),
                    onPressed: () => context
                        .read<OnboardingBloc>()
                        .add(const OnboardingCompleted()),
                    child: Text(
                      'Concluir',
                      style: theme.textTheme.titleLargeEmphasized,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({
    required this.code,
    required this.accentColor,
    required this.copied,
    required this.onCopy,
    this.loading = false,
    this.loadError,
  });

  final String? code;
  final Color accentColor;
  final bool copied;
  final VoidCallback onCopy;
  final bool loading;
  final String? loadError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = code != null
        ? code!
        : (loadError != null
            ? loadError!
            : 'Carregando…');
    final isCode = code != null;
    final isError = loadError != null && !isCode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: M3Shapes.shapeMedium,
        border: Border.all(color: accentColor.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: loading && code == null
                ? Row(
                    children: [
                      const Material3LoadingIndicator(size: 18),
                      const SizedBox(width: 12),
                      Text(
                        'Carregando…',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : Text(
                    displayText,
                    style: (isCode
                            ? theme.textTheme.titleMediumEmphasized
                            : theme.textTheme.bodyMedium)
                        ?.copyWith(
                          letterSpacing: isCode ? 2 : 0,
                          color: isError
                              ? theme.colorScheme.error
                              : accentColor,
                        ),
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: M3EIconButton(
              key: ValueKey(copied),
              icon: Icon(
                copied ? Icons.check_rounded : Icons.copy_rounded,
                color: accentColor,
              ),
              tooltip: copied ? 'Copiado!' : 'Copiar código',
              onPressed: code != null ? onCopy : null,
            ),
          ),
        ],
      ),
    );
  }
}
