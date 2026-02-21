import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/main.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/constants/m3_animation.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/shared/widgets/themed_svg.dart';

class ExpressiveLoginPage extends StatefulWidget {
  const ExpressiveLoginPage({super.key});

  @override
  State<ExpressiveLoginPage> createState() => _ExpressiveLoginPageState();
}

class _ExpressiveLoginPageState extends State<ExpressiveLoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: M3Animation.durationLong1,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.30),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimpleAuthBloc, SimpleAuthState>(
      listener: (context, state) {
        if (state is SimpleAuthSuccess) {
          context.go(AppRouter.home);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const M3EdgeInsets.all(M3SpacingToken.space24),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _offsetAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: child,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: M3SpacingToken.space32.value),
                  _buildHeader(context),
                  SizedBox(height: M3SpacingToken.space32.value),
                  _buildForm(context),
                  BlocBuilder<SimpleAuthBloc, SimpleAuthState>(
                    buildWhen: (prev, curr) =>
                        curr is SimpleAuthFailure || prev is SimpleAuthFailure,
                    builder: (context, state) {
                      if (state is SimpleAuthFailure) {
                        return Padding(
                          padding: const M3EdgeInsets.only(
                            top: M3SpacingToken.space16,
                          ),
                          child: SelectableText.rich(
                            TextSpan(
                              text: state.message,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  SizedBox(height: M3SpacingToken.space24.value),
                  _buildGoogleSignInButton(context),
                  SizedBox(height: M3SpacingToken.space24.value),
                  _buildToggleButton(context),
                  SizedBox(height: M3SpacingToken.space16.value),
                  if (!_isSignUp) _buildForgotPasswordButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ThemedSvg(
            assetPath: 'assets/images/mealtime-symbol.svg',
            size: 56,
            colorSchemeColor: colorScheme.onPrimaryContainer,
          ),
        ),
        SizedBox(height: M3SpacingToken.space24.value),
        Text(
          'MealTime',
          style: theme.textTheme.displayLargeEmphasized?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: M3SpacingToken.space8.value),
        Text(
          _isSignUp ? context.l10n.auth_register : context.l10n.auth_welcomeBack,
          style: theme.textTheme.headlineMediumEmphasized?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: M3SpacingToken.space8.value),
        Text(
          context.l10n.auth_managementDescription,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const M3EdgeInsets.all(M3SpacingToken.space24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: M3Shapes.shapeLarge,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSignUp) ...[
            _buildTextField(
              context: context,
              controller: _nameController,
              label: context.l10n.auth_fullName,
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: M3SpacingToken.space16.value),
          ],
          _buildTextField(
            context: context,
            controller: _emailController,
            label: context.l10n.common_email,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          _buildTextField(
            context: context,
            controller: _passwordController,
            label: context.l10n.auth_passwordPlaceholder,
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          SizedBox(height: M3SpacingToken.space24.value),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Container(
          padding: const M3EdgeInsets.all(M3SpacingToken.space12),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: M3Shapes.shapeMedium,
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: M3Shapes.shapeMedium,
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: M3Shapes.shapeMedium,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const M3EdgeInsets.symmetric(
          horizontal: M3SpacingToken.space16,
          vertical: M3SpacingToken.space16,
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SimpleAuthBloc, SimpleAuthState>(
      builder: (context, state) {
        final isLoading = state is SimpleAuthLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: isLoading ? null : _handleAuth,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: M3Shapes.shapeXLarge,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: Material3LoadingIndicator(size: 20),
                  )
                : Text(
                    _isSignUp ? context.l10n.auth_register : context.l10n.auth_signIn,
                    style: theme.textTheme.titleMediumEmphasized?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Google branding guidelines: Light fill #FFFFFF stroke #747775 text #1F1F1F;
    // Dark fill #131314 stroke #8E918F text #E3E3E3. Roboto Medium 14px.
    const Color lightFill = Color(0xFFFFFFFF);
    const Color lightStroke = Color(0xFF747775);
    const Color lightText = Color(0xFF1F1F1F);
    const Color darkFill = Color(0xFF131314);
    const Color darkStroke = Color(0xFF8E918F);
    const Color darkText = Color(0xFFE3E3E3);

    final fillColor = isDark ? darkFill : lightFill;
    final borderColor = isDark ? darkStroke : lightStroke;
    final textColor = isDark ? darkText : lightText;

    return BlocBuilder<SimpleAuthBloc, SimpleAuthState>(
      buildWhen: (prev, curr) =>
          curr is SimpleAuthLoading || prev is SimpleAuthLoading,
      builder: (context, state) {
        final isLoading = state is SimpleAuthLoading;
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: Material(
            color: fillColor,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: isLoading
                  ? null
                  : () {
                      context
                          .read<SimpleAuthBloc>()
                          .add(const SimpleAuthGoogleSignInRequested());
                    },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Material3LoadingIndicator(size: 20),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _GoogleLogo(size: 24),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              context.l10n.auth_signInWithGoogle,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                                height: 20 / 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextButton(
      onPressed: _toggleMode,
      style: TextButton.styleFrom(
        padding: const M3EdgeInsets.symmetric(
          horizontal: M3SpacingToken.space16,
          vertical: M3SpacingToken.space8,
        ),
      ),
      child: RichText(
        text: TextSpan(
          text: _isSignUp ? context.l10n.auth_alreadyHaveAccount : context.l10n.auth_noAccount,
          style: theme.textTheme.bodyLargeEmphasized?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          children: [
            TextSpan(
              text: _isSignUp ? context.l10n.auth_signInShort : context.l10n.auth_registerShort,
              style: theme.textTheme.bodyLargeEmphasized?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.showSnackBar(context.l10n.auth_featureInDevelopment);
      },
      child: Text(
        context.l10n.auth_forgotPassword,
        style: Theme.of(context).textTheme.bodyLargeEmphasized?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showErrorSnackBar(context.l10n.auth_emailRequired, context);
      return;
    }

    if (password.isEmpty) {
      _showErrorSnackBar(context.l10n.auth_passwordRequired, context);
      return;
    }

    if (_isSignUp) {
      final name = _nameController.text.trim();

      if (name.isEmpty) {
        _showErrorSnackBar(context.l10n.auth_nameRequired, context);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.auth_registerInDevelopment,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: M3Shapes.shapeMedium),
        ),
      );
      return;
    }

    context.read<SimpleAuthBloc>().add(
      SimpleAuthLoginRequested(email: email, password: password),
    );
  }

  void _showErrorSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: M3Shapes.shapeMedium),
      ),
    );
  }
}

/// Ícone oficial do Google "G" (diretrizes de marca).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/google_logo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
