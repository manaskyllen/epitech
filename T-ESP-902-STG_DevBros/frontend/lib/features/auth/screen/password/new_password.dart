import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/core/response/generic_responce.dart';
import 'package:inspiria/features/auth/data/auth_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, required this.email, required this.otp});

  final String email;
  final String otp;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool _obscureText = true;
  String password = '';
  String confirmPassword = '';
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String password,
    String confirmPassword,
  ) async {
    if (confirmPassword.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email and password.';
      });
      return;
    }
    try {
      final GenericResponce? responce = await AuthService.resetPassword(
        email,
        otp,
        password,
        confirmPassword,
      );

      if (responce?.statusCode == 200) {
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
          context.go(SCREEN.PASSWORDCHANGED.path);
        }
      } else if (responce?.statusCode == 400) {
        setState(() {
          errorMessage = 'OTP is invalid.';
        });
      } else {
        setState(() {
          errorMessage = 'Please check your credentials. Try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred during password reset.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Partie scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Logo
                      Image.asset(
                        'assets/images/login_inspiria.png',
                        width: 128,
                        height: 47,
                      ),

                      // Back
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => context.go(SCREEN.PRELOGIN.path),
                          child: Image.asset(
                            'assets/images/back.png',
                            width: 41,
                            height: 41,
                          ),
                        ),
                      ),

                      // Welcome text
                      const Text(
                        'Create New Password',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Align(
                          alignment: Alignment.topLeft,

                          child: Text(
                            'Your new password must be different from previous used passwords.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Password
                      TextFormField(
                        obscureText: _obscureText,
                        onSaved: (value) => password = value ?? '',
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() {
                              errorMessage = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.grey[50],

                          filled: true,
                          hintStyle: const TextStyle(color: Colors.black),
                          hintText: 'Enter your password',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          suffixIcon: IconButton(
                            onPressed: _togglePasswordVisibility,
                            icon: Image.asset(
                              'assets/images/eye.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                        const SizedBox(height: 16),
                       TextFormField(
                        obscureText: _obscureText,
                        onSaved: (value) => confirmPassword = value ?? '',
                        onChanged: (value) {
                          if (errorMessage != null) {
                            setState(() {
                              errorMessage = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.grey[50],

                          filled: true,
                          hintStyle: const TextStyle(color: Colors.black),
                          hintText: 'Confirm your password',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      if (errorMessage != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.075,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              resetPassword(
                                widget.email,
                                widget.otp,
                                password,
                                password,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F1B1B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Reset Password',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
