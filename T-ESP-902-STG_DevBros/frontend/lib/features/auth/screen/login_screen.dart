import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspiria/core/response/user_responce.dart';
import 'package:inspiria/features/auth/data/auth_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  bool _obscureText = true;
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _generalErrorMessage;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _clearErrors({
    bool clearEmail = false,
    bool clearPassword = false,
    bool clearGeneral = false,
  }) {
    if (!mounted) {
      return;
    }

    if (!clearEmail && !clearPassword && !clearGeneral) {
      return;
    }

    if (_emailErrorMessage == null &&
        _passwordErrorMessage == null &&
        _generalErrorMessage == null) {
      return;
    }

    setState(() {
      if (clearEmail) {
        _emailErrorMessage = null;
      }
      if (clearPassword) {
        _passwordErrorMessage = null;
      }
      if (clearGeneral) {
        _generalErrorMessage = null;
      }
    });
  }

  String? _validateEmail(String? value) {
    final String trimmedValue = (value ?? '').trim();

    if (trimmedValue.isEmpty) {
      return 'Please enter your email.';
    }

    if (!_emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address.';
    }

    return _emailErrorMessage;
  }

  String? _validatePassword(String? value) {
    final String currentValue = value ?? '';

    if (currentValue.isEmpty) {
      return 'Please enter your password.';
    }

    return _passwordErrorMessage;
  }

  void _applyLoginError(int? statusCode, String? errorMessage) {
    final String resolvedMessage =
        errorMessage != null && errorMessage.trim().isNotEmpty
            ? errorMessage.trim()
            : 'An unknown error occurred. Please try again.';
    final String normalizedMessage = resolvedMessage.toLowerCase();

    setState(() {
      _emailErrorMessage = null;
      _passwordErrorMessage = null;
      _generalErrorMessage = null;

      if (normalizedMessage.contains('email')) {
        _emailErrorMessage = resolvedMessage;
      } else if (normalizedMessage.contains('password') ||
          normalizedMessage.contains('credential') ||
          normalizedMessage.contains('login') ||
          statusCode == 401 ||
          statusCode == 403) {
        _passwordErrorMessage = resolvedMessage;
      } else {
        _generalErrorMessage = resolvedMessage;
      }
    });

    _formKey.currentState?.validate();
  }

  Future<void> login(String email, String password) async {
    _clearErrors(clearEmail: true, clearPassword: true, clearGeneral: true);

    try {
      final UserResponce? userResponce = await AuthService.login(
        email,
        password,
      );

      if (!mounted) {
        return;
      }

      if (userResponce?.statusCode == 200) {
        _clearErrors(clearEmail: true, clearPassword: true, clearGeneral: true);
        // Le réacteur va maintenant détecter le token et rediriger
        context.go(SCREEN.HOMEPAGE.path);
      } else {
        _applyLoginError(userResponce?.statusCode, userResponce?.errorMessage);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _applyLoginError(500, e.toString());
    }
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      login(email.trim(), password);
    }
  }

  Widget _buildEmailField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: _validateEmail,
          onSaved: (value) => email = (value ?? '').trim(),
          onChanged: (value) {
            _clearErrors(clearEmail: true, clearGeneral: true);
          },
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            hintStyle: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
            hintText: 'Email',
            prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withValues(alpha: 0.6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color.fromARGB(255, 255, 120, 120)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          obscureText: _obscureText,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.done,
          validator: _validatePassword,
          onSaved: (value) => password = value ?? '',
          onChanged: (value) {
            setState(() {
              _passwordErrorMessage = null;
              _generalErrorMessage = null;
            });
          },
          onFieldSubmitted: (_) => _submitLogin(),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            hintStyle: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color.fromARGB(255, 255, 120, 120)),
            ),
            suffixIcon: IconButton(
              onPressed: _togglePasswordVisibility,
              icon: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => context.go(SCREEN.FORGOTPASSWORD.path),
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 255, 255, 255),
            const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submitLogin,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'Login',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () => context.go(SCREEN.REGISTER.path),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an account? ',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: 'Sign up',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = viewInsetsBottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Hero Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/pre_loginv2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark Gradient Overlay
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content with Glassmorphism
          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(16, 12, 16, viewInsetsBottom + 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Back Button
                            if (!isKeyboardOpen)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () => context.go(SCREEN.PRELOGIN.path),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    alignment: Alignment.centerLeft,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 24,
                                  ),
                                ),
                              ),
                            if (!isKeyboardOpen) const SizedBox(height: 8),

                            // Glass Card Container
                            ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 30,
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Title
                                        Text(
                                          'Welcome back!',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        // Subtitle
                                        Text(
                                          'Sign in to your account',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Email Field
                                        _buildEmailField(),

                                        const SizedBox(height: 14),

                                        // Password Field
                                        _buildPasswordField(),

                                        // Error Message
                                        if (_generalErrorMessage != null) ...[
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 255, 100, 100).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: const Color.fromARGB(255, 255, 100, 100).withValues(alpha: 0.5),
                                              ),
                                            ),
                                            child: Text(
                                              _generalErrorMessage!,
                                              style: GoogleFonts.poppins(
                                                color: const Color.fromARGB(255, 255, 150, 150),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 10),

                                        // Forgot Password
                                        _buildForgotPasswordButton(),

                                        const SizedBox(height: 16),

                                        // Login Button
                                        _buildLoginButton(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Register Link
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
