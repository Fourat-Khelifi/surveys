import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/services/auth_service.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/text_field.dart';
import 'package:surveys/shared/widgets/wordmark.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode _confirmPasswordFocus = FocusNode();

  String? errorMessage;
  bool isLoading = false;
  bool success = false;

  void handleUpdatePassword() async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    setState(() => errorMessage = null);

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() => errorMessage = "Please fill in all fields");
      return;
    }

    if (password.length < 6) {
      setState(() => errorMessage = "Password must be at least 6 characters");
      return;
    }

    if (password != confirmPassword) {
      setState(() => errorMessage = "Passwords do not match");
      return;
    }

    try {
      setState(() => isLoading = true);
      await _authService.updatePassword(password);
      setState(() => success = true);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                "Set new password",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                "Your reset link is verified. Choose a new password.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              _buildFormCard(),
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
      child: success ? _buildSuccessContent() : _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            hint: "New Password",
            showCounter: false,
            controller: passwordController,
            maxLength: 72,
            obscureText: true,
            showObscureToggle: true,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
          ),
          const SizedBox(height: 14),
          AppTextField(
            hint: "Confirm New Password",
            showCounter: false,
            controller: confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            maxLength: 72,
            obscureText: true,
            showObscureToggle: true,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => isLoading ? null : handleUpdatePassword(),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _buildError(errorMessage!),
          ],
          const SizedBox(height: 18),
          AppButton(
            text: isLoading ? "Updating..." : "Update Password",
            onPressed: isLoading ? null : handleUpdatePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 48,
          color: AppColors.success,
        ),
        const SizedBox(height: 16),
        const Text(
          "Password updated!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "You can now use your new password to sign in.",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
}
