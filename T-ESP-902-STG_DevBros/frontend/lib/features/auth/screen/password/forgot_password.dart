import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/core/response/generic_responce.dart';
import 'package:inspiria/features/auth/data/auth_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email = '';
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;

  Future<void> forgetPassword(String email) async {
    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email.';
      });
      return;
    }
    try {
      final GenericResponce? responce = await AuthService.forgetPassword(email);
      if (responce?.statusCode == 200) {
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
          context.go('${SCREEN.VALIDATERESETPASSWORD.path}?email=$email', extra: {'from': 'forgotPassword'});
        }
      } else if (responce?.statusCode == 404) {
        setState(() {
          errorMessage = 'Email not found. Please check and try again.';
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

                      const Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Forgot Password ?',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      
                       Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                        textAlign: TextAlign.left,
                        'Don\'t worry! It happens. Please enter the email associated with your account.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),

                      const SizedBox(height: 40),

                      // Email
                      TextFormField(
                        onSaved: (value) => email = value ?? '',
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
                          hintText: 'Enter your email',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
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
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.075,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              forgetPassword(email);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F1B1B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Send Code',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      context.go(SCREEN.LOGIN.path);
                    },
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Remember Password? ',
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          TextSpan(
                            text: 'Login Now',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
