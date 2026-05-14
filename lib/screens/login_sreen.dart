import 'package:flutter/material.dart';
import 'package:surveys/screens/main_screen.dart';
import 'package:surveys/screens/signup_screen.dart';
import 'package:surveys/services/auth_service.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      errorMessage = null;
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
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
    emailController.dispose();
    passwordController.dispose();
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
                "Welcome Back",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Sign in to continue and explore surveys",
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
                        text: isLoading ? "Signing in..." : "Sign In",
                        onPressed: isLoading ? null : handleLogin,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
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
