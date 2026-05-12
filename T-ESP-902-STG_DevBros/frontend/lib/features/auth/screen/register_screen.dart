import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspiria/core/response/user_responce.dart';
import 'package:inspiria/features/auth/data/auth_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  bool _obscureText = true;
  String firstname = '';
  String lastname = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  final _formKey = GlobalKey<FormState>();
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _confirmPasswordErrorMessage;
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
    bool clearConfirmPassword = false,
    bool clearGeneral = false,
  }) {
    if (!mounted) {
      return;
    }

    if (!clearEmail &&
        !clearPassword &&
        !clearConfirmPassword &&
        !clearGeneral) {
      return;
    }

    if (_emailErrorMessage == null &&
        _passwordErrorMessage == null &&
        _confirmPasswordErrorMessage == null &&
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
      if (clearConfirmPassword) {
        _confirmPasswordErrorMessage = null;
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

  String? _validateConfirmPassword(String? value) {
    final String currentValue = value ?? '';

    if (currentValue.isEmpty) {
      return 'Please confirm your password.';
    }

    if (currentValue != password) {
      return 'Passwords do not match.';
    }

    return _confirmPasswordErrorMessage;
  }

  void _applyRegisterError(int? statusCode, String? errorMessage) {
    final String resolvedMessage =
        errorMessage != null && errorMessage.trim().isNotEmpty
            ? errorMessage.trim()
            : 'Registration failed. Please check your details and try again.';
    final String normalizedMessage = resolvedMessage.toLowerCase();

    setState(() {
      _emailErrorMessage = null;
      _passwordErrorMessage = null;
      _confirmPasswordErrorMessage = null;
      _generalErrorMessage = null;

      if (normalizedMessage.contains('email')) {
        _emailErrorMessage = resolvedMessage;
      } else if (normalizedMessage.contains('confirm') ||
          normalizedMessage.contains('confirmation') ||
          normalizedMessage.contains('match')) {
        _confirmPasswordErrorMessage = resolvedMessage;
      } else if (normalizedMessage.contains('password') ||
          statusCode == 401 ||
          statusCode == 403) {
        _passwordErrorMessage = resolvedMessage;
      } else {
        _generalErrorMessage = resolvedMessage;
      }
    });

    _formKey.currentState?.validate();
  }

  Future<void> register(
    String firstname,
    String lastname,
    String email,
    String password,
    String confirmPassword,
  ) async {
    _clearErrors(
      clearEmail: true,
      clearPassword: true,
      clearConfirmPassword: true,
      clearGeneral: true,
    );

    try {
      final UserResponce? userResponce = await AuthService.register(
        firstname,
        lastname,
        email,
        password,
        confirmPassword,
        null,
        null,
      );

      if (!mounted) {
        return;
      }

      if (userResponce?.statusCode == 201) {
        _clearErrors(
          clearEmail: true,
          clearPassword: true,
          clearConfirmPassword: true,
          clearGeneral: true,
        );
        context.go(
          '${SCREEN.VALIDATEEMAIL.path}?email=$email',
          extra: {'from': 'register'},
        );
      } else {
        _applyRegisterError(
          userResponce?.statusCode,
          userResponce?.errorMessage,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _applyRegisterError(500, e.toString());
    }
  }

  void _submitRegister() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      register(firstname, lastname, email.trim(), password, confirmPassword);
    }
  }

  Widget _buildFirstNameField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          onSaved: (value) => firstname = value ?? '',
          onChanged: (value) {
            _clearErrors(clearGeneral: true);
          },
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            hintStyle: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
            hintText: 'First Name',
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

  Widget _buildLastNameField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          onSaved: (value) => lastname = value ?? '',
          onChanged: (value) {
            _clearErrors(clearGeneral: true);
          },
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            hintStyle: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
            hintText: 'Last Name',
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
          textInputAction: TextInputAction.next,
          validator: _validatePassword,
          onSaved: (value) => password = value ?? '',
          onChanged: (value) {
            password = value;
            _clearErrors(
              clearPassword: true,
              clearConfirmPassword: true,
              clearGeneral: true,
            );
          },
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

  Widget _buildConfirmPasswordField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          obscureText: _obscureText,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.done,
          validator: _validateConfirmPassword,
          onSaved: (value) => confirmPassword = value ?? '',
          onChanged: (value) {
            _clearErrors(
              clearConfirmPassword: true,
              clearGeneral: true,
            );
          },
          onFieldSubmitted: (_) => _submitRegister(),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            hintStyle: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
            hintText: 'Confirm Password',
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

  Widget _buildRegisterButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submitRegister,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'Register',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => context.go(SCREEN.LOGIN.path),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an account? ',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: 'Login',
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
                        child: Form(
                          key: _formKey,
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
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Title
                                        FadeTransition(
                                          opacity: _fadeAnimation,
                                          child: Text(
                                            'Create Account',
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // Subtitle
                                        FadeTransition(
                                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                            CurvedAnimation(
                                              parent: _fadeController,
                                              curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
                                            ),
                                          ),
                                          child: Text(
                                            'Join us and start exploring!',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white.withValues(alpha: 0.7),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // First Name and Last Name Row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'First Name',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  _buildFirstNameField(),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Last Name',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  _buildLastNameField(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Email
                                        Text(
                                          'Email',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        _buildEmailField(),
                                        const SizedBox(height: 16),

                                        // Password
                                        Text(
                                          'Password',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        _buildPasswordField(),
                                        const SizedBox(height: 16),

                                        // Confirm Password
                                        Text(
                                          'Confirm Password',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        _buildConfirmPasswordField(),

                                        // General Error
                                        if (_generalErrorMessage != null) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.red.withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Text(
                                              _generalErrorMessage!,
                                              style: GoogleFonts.poppins(
                                                color: const Color.fromARGB(255, 255, 120, 120),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 24),

                                        // Register Button
                                        _buildRegisterButton(),
                                        const SizedBox(height: 12),

                                        // Login Link
                                        Center(
                                          child: _buildLoginLink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
