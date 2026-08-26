import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/enums.dart';

import 'package:surveys/services/auth_service.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/text_field.dart';
import 'package:surveys/shared/widgets/wordmark.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthService authService = AuthService();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  String? errorMessage;
  bool isLoading = false;
  bool emailConfirmationRequired = false;

  void handleSignup() async {
    final fullname = fullnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    setState(() => errorMessage = null);

    if (fullname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => errorMessage = "Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      setState(() => errorMessage = "Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await authService.signUp(email, password, fullname);
      if (response.session == null) {
        setState(() => emailConfirmationRequired = true);
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
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
      await authService.resendConfirmationEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Confirmation email sent again.")),
        );
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
                "Create account",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                "Sign up to start earning rewards.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              _buildFormCard(),

              const SizedBox(height: 36),

              Center(child: _buildLoginPrompt()),
            ],
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
      child: AutofillGroup(
        child: emailConfirmationRequired
            ? _buildConfirmationSent()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    hint: "Full Name",
                    showCounter: false,
                    controller: fullnameController,
                    maxLength: 40,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _emailFocus.requestFocus(),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    hint: "Email",
                    showCounter: false,
                    controller: emailController,
                    focusNode: _emailFocus,
                    maxLength: 40,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.newUsername,
                      AutofillHints.email,
                    ],
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
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    hint: "Confirm Password",
                    showCounter: false,
                    controller: confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    maxLength: 72,
                    obscureText: true,
                    showObscureToggle: true,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => isLoading ? null : handleSignup(),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 14),
                    _buildError(errorMessage!),
                  ],
                  const SizedBox(height: 18),
                  AppButton(
                    text: isLoading ? "Signing up..." : "Sign Up",
                    onPressed: isLoading ? null : handleSignup,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildConfirmationSent() {
    return Column(
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 48,
          color: AppColors.success,
        ),
        const SizedBox(height: 16),
        const Text(
          "Confirm your email",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "We sent a confirmation link to ${emailController.text.trim()}. Click it to activate your account, then sign in.",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildError(errorMessage!),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: isLoading ? "Resending..." : "Resend Email",
            type: ButtonType.outlined,
            onPressed: isLoading ? null : handleResendConfirmation,
          ),
        ),
      ],
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

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Already have an account?",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.burnttangerine,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Sign In",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
