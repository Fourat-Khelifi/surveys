import 'dart:math';

import 'package:flutter/material.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/screens/login_sreen.dart';
import 'package:surveys/services/auth_service.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/text_field.dart';

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

  String? errorMessage;
  bool isLoading = false;

  void handleSignup() async {
    final AuthService authService = AuthService();
    final fullname = fullnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    setState(() {
      errorMessage = null;
    });

    if (fullname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all fields";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.signUp(email, password, fullname);

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f3f1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              const Image(
                image: NetworkImage("https://placehold.co/200x100.png"),
              ),

              const SizedBox(height: 30),

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Sign up to continue and explore surveys",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              const SizedBox(height: 50),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AppTextField(
                      hint: "Full Name",
                      showCounter: false,
                      controller: fullnameController,
                      maxLength: 40,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      hint: "Email",
                      showCounter: false,
                      controller: emailController,
                      maxLength: 40,
                    ),

                    const SizedBox(height: 16),
                    AppTextField(
                      hint: "Password",
                      showCounter: false,
                      controller: passwordController,
                      obscureText: true,
                      maxLength: 40,
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      hint: "Confirm Password",
                      showCounter: false,
                      controller: confirmPasswordController,
                      obscureText: true,
                      maxLength: 40,
                    ),

                    const SizedBox(height: 16),

                    // ❗ Error message
                    if (errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: isLoading ? "Signing up..." : "Sign Up",
                        onPressed: isLoading ? null : handleSignup,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 6),
                  AppButton(
                    type: ButtonType.text,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    text: "Sign In",
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
