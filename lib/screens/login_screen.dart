import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/screens/forgot_password_screen.dart';
import 'package:surveys/screens/signup_screen.dart';
import 'package:surveys/services/auth_service.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/text_field.dart';
import 'package:surveys/shared/widgets/wordmark.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode _passwordFocus = FocusNode();

  String? errorMessage;
  bool isLoading = false;
  bool emailNotConfirmed = false;

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      errorMessage = null;
      emailNotConfirmed = false;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all fields";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await _authService.signIn(email, password);
      // MainApp's auth listener routes to the app on success.
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        emailNotConfirmed = e is EmailNotConfirmedFailure;
      });
    } finally {
      // A successful sign-in makes MainApp swap the root widget, disposing this
      // screen before the future completes — whether that happens before or
      // after this line is a race.
      if (mounted) setState(() => isLoading = false);
    }
  }

  void handleResendConfirmation() async {
    final email = emailController.text.trim();

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await _authService.resendConfirmationEmail(email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Confirmation email sent again.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  void openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          // AutofillGroup lets the platform password manager treat the two
          // fields as one credential rather than two unrelated boxes.
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),

                const AppWordmark(),
                const SizedBox(height: 8),
                Text(
                  "Earn points for your opinions",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 52),

                Text(
                  "Welcome back",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  "Sign in to pick up where you left off.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                _buildFormCard(),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : openForgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSubtle,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Forgot your password?",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                Center(child: _buildSignupPrompt()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.authCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.authShadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            hint: "Email",
            showCounter: false,
            controller: emailController,
            maxLength: 40,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),

          const SizedBox(height: 14),

          AppTextField(
            hint: "Password",
            showCounter: false,
            controller: passwordController,
            focusNode: _passwordFocus,
            maxLength: 72,
            obscureText: true,
            showObscureToggle: true,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => isLoading ? null : handleLogin(),
          ),

          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _buildError(errorMessage!),
          ],

          if (emailNotConfirmed) ...[
            const SizedBox(height: 4),
            AppButton(
              type: ButtonType.text,
              text: "Resend confirmation email",
              onPressed: isLoading ? null : handleResendConfirmation,
            ),
          ],

          const SizedBox(height: 18),

          AppButton(
            text: isLoading ? "Signing in..." : "Sign In",
            onPressed: isLoading ? null : handleLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupPrompt() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "New here?",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: isLoading ? null : openSignup,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accentDark,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Create an account",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
