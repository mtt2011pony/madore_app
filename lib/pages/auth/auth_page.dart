import 'package:flutter/material.dart';

import '../../services/auth/auth_controller.dart';

class AuthPage extends StatefulWidget {
  final AuthController controller;

  const AuthPage({
    super.key,
    required this.controller,
  });

  @override
  State<AuthPage> createState() =>
      _AuthPageState();
}

class _AuthPageState
    extends State<AuthPage> {
  late final TextEditingController
      emailController;

  late final TextEditingController
      passwordController;

  late final TextEditingController
      confirmPasswordController;

  bool isRegister = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;

  AuthController get controller =>
      widget.controller;

  @override
  void initState() {
    super.initState();

    emailController =
        TextEditingController();

    passwordController =
        TextEditingController();

    confirmPasswordController =
        TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController
        .dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context)
        .unfocus();

    final email =
        emailController.text.trim();

    final password =
        passwordController.text;

    if (email.isEmpty) {
      _showError(
        'Please enter your email',
      );
      return;
    }

    if (password.length < 8) {
      _showError(
        'Password must contain at least 8 characters',
      );
      return;
    }

    if (isRegister) {
      if (password !=
          confirmPasswordController
              .text) {
        _showError(
          'Passwords do not match',
        );
        return;
      }

      await controller.register(
        email: email,
        password: password,
      );
    } else {
      await controller.login(
        email: email,
        password: password,
      );
    }

    if (!mounted) {
      return;
    }

    if (controller.errorMessage !=
        null) {
      _showError(
        controller.errorMessage!,
      );
    }
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      isRegister = !isRegister;
    });

    controller.clearError();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7F9),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 420,
            ),
            child: Card(
              elevation: 0,
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    const Text(
                      'Madore',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      isRegister
                          ? 'Create your account'
                          : 'Welcome back',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    TextField(
                      controller:
                          emailController,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      autofillHints: const [
                        AutofillHints.email,
                      ],
                      decoration:
                          const InputDecoration(
                        labelText: 'Email',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    TextField(
                      controller:
                          passwordController,
                      obscureText:
                          obscurePassword,
                      autofillHints: [
                        isRegister
                            ? AutofillHints
                                .newPassword
                            : AutofillHints
                                .password,
                      ],
                      decoration:
                          InputDecoration(
                        labelText:
                            'Password',
                        border:
                            const OutlineInputBorder(),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons
                                    .visibility
                                : Icons
                                    .visibility_off,
                          ),
                        ),
                      ),
                    ),
                    if (isRegister) ...[
                      const SizedBox(
                        height: 14,
                      ),
                      TextField(
                        controller:
                            confirmPasswordController,
                        obscureText:
                            obscureConfirm,
                        decoration:
                            InputDecoration(
                          labelText:
                              'Confirm password',
                          border:
                              const OutlineInputBorder(),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirm =
                                    !obscureConfirm;
                              });
                            },
                            icon: Icon(
                              obscureConfirm
                                  ? Icons
                                      .visibility
                                  : Icons
                                      .visibility_off,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: 20,
                    ),
                    AnimatedBuilder(
                      animation:
                          controller,
                      builder:
                          (context, child) {
                        return SizedBox(
                          height: 48,
                          child:
                              ElevatedButton(
                            onPressed:
                                controller
                                        .isLoading
                                    ? null
                                    : _submit,
                            child:
                                controller
                                        .isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                        ),
                                      )
                                    : Text(
                                        isRegister
                                            ? 'Create account'
                                            : 'Login',
                                      ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextButton(
                      onPressed:
                          controller
                                  .isLoading
                              ? null
                              : _toggleMode,
                      child: Text(
                        isRegister
                            ? 'Already have an account? Login'
                            : 'New to Madore? Create account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}