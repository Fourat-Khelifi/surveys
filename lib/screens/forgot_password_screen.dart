import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/services/auth_service.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/text_field.dart';
import 'package:surveys/shared/widgets/wordmark.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;
  bool emailSent = false;

  void handleSendResetLink() async {
    final email = emailController.text.trim();

    setState(() => errorMessage = null);

    if (email.isEmpty) {
      setState(() => errorMessage = "Please enter your email address");
      return;
    }

    try {
      setState(() => isLoading = true);
      await _authService.sendPasswordReset(email);
      setState(() => emailSent = true);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void handleResend() async {
    final email = emailController.text.trim();
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      await _authService.sendPasswordReset(email);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),

              const SizedBox(height: 40),

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
                "Reset password",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                "Enter your email and we'll send you a reset link.",
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
      child: emailSent ? _buildSuccessContent() : _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return AutofillGroup(
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
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => isLoading ? null : handleSendResetLink(),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _buildError(errorMessage!),
          ],
          const SizedBox(height: 18),
          AppButton(
            text: isLoading ? "Sending..." : "Send Reset Link",
            onPressed: isLoading ? null : handleSendResetLink,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 48,
          color: AppColors.success,
        ),
        const SizedBox(height: 16),
        const Text(
          "Check your inbox",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "If an account exists for ${emailController.text.trim()}, a password reset link is on its way.",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: "Back to Sign In",
            type: ButtonType.outlined,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: isLoading ? "Resending..." : "Resend Email",
            type: ButtonType.text,
            onPressed: isLoading ? null : handleResend,
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
}
