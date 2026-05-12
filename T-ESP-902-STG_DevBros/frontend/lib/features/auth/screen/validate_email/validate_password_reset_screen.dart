import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/core/response/generic_responce.dart';
import 'package:inspiria/features/auth/data/auth_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class ValidateResetPasswordScreen extends StatefulWidget {
  const ValidateResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ValidateResetPasswordScreen> createState() => _ValidateResetPasswordScreenState();
}

class _ValidateResetPasswordScreenState extends State<ValidateResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String otp = '';
  String? errorMessage;

  // OTP controllers and focus nodes
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> passwordResetVerify(String otp) async {
    if (otp.isEmpty || otp.length < 6) {
      setState(() {
        errorMessage = 'Please enter your OTP.';
      });
      return;
    }
    try {
      final GenericResponce response = await AuthService.passwordResetVerify(
        widget.email,
        otp,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
            context.go('${SCREEN.NEWPASSWORD.path}?email=${widget.email}&otp=$otp');
        }
      } else if (response.statusCode == 400) {
        setState(() {
          errorMessage = 'Invalid OTP. Please try again.';
        });
      } else {
        setState(() {
          errorMessage = 'Please check your OTP and try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred during verification.';
      });
    }
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          height: 60,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }

              // Update OTP
              otp = _controllers.map((c) => c.text).join();
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Image.asset(
                        'assets/images/login_inspiria.png',
                        width: 128,
                        height: 47,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => context.go(SCREEN.REGISTER.path),
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
                            'OTP Verification',
                            textAlign: TextAlign.start,
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
                            'Verify your email',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            _buildOtpFields(),

                            if (errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),

                            const SizedBox(height: 40),

                            SizedBox(
                              width: double.infinity,
                              height: screenHeight * 0.075,
                              child: ElevatedButton(
                                onPressed: () {
                                  passwordResetVerify(otp);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F1B1B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Verify Email',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextButton(
                onPressed: () => context.go(SCREEN.REGISTER.path),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Didn\'t receive the email? ',
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                      TextSpan(
                        text: 'Resend Email',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 15,
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
