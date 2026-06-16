import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../services/auth_service.dart';
import 'otp_dialog.dart';

class LoginView extends StatefulWidget {
  final bool isFirebaseMode;

  const LoginView({
    Key? key,
    required this.isFirebaseMode,
  }) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Common states
  bool _isSignUp = false;
  bool _isPhoneAuth = false;
  bool _isLoading = false;
  String _errorMessage = '';

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message.replaceFirst('Exception: ', '');
      _isLoading = false;
    });
  }

  void _clearError() {
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  void _handleEmailSubmit(AuthService authService) async {
    if (!_formKey.currentState!.validate()) return;
    _clearError();
    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await authService.registerWithEmail(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _phoneController.text.trim(),
        );
      } else {
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handlePhoneSubmit(AuthService authService) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !phone.startsWith('+')) {
      _showError('Please enter phone number starting with + (e.g., +15550199)');
      return;
    }
    _clearError();
    setState(() => _isLoading = true);

    try {
      await authService.sendOtp(phone, (verificationId) {
        setState(() => _isLoading = false);
        // Show OTP dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OtpDialog(
            phoneNumber: phone,
            verificationId: verificationId,
            onVerify: (smsCode) async {
              await authService.verifyOtp(verificationId, smsCode, phone);
            },
          ),
        );
      });
    } catch (e) {
      _showError(e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignIn(AuthService authService) async {
    _clearError();
    setState(() => _isLoading = true);

    try {
      final user = await authService.signInWithGoogle();
      if (user == null) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mode Banner Indicator
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.isFirebaseMode 
                                  ? Colors.green.withOpacity(0.15) 
                                  : Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.isFirebaseMode ? Colors.green : Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.isFirebaseMode ? 'Live Firebase Mode' : 'Demo Mode (Local)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isFirebaseMode ? Colors.green[800] : Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Logo & Brand Name
                        Center(
                          child: Hero(
                            tag: 'app_logo',
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary.withOpacity(0.05),
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome to Aura',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp 
                              ? 'Create an account to unlock fashion, food, & groceries'
                              : 'Your multi-niche shopping universe starts here',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Authentication Method Toggle (Tabs)
                        if (!_isSignUp) ...[
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _clearError();
                                    setState(() => _isPhoneAuth = false);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: !_isPhoneAuth 
                                              ? theme.colorScheme.primary 
                                              : Colors.transparent,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Email Login',
                                      style: TextStyle(
                                        fontWeight: !_isPhoneAuth ? FontWeight.bold : FontWeight.normal,
                                        color: !_isPhoneAuth 
                                            ? theme.colorScheme.primary 
                                            : theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _clearError();
                                    setState(() => _isPhoneAuth = true);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _isPhoneAuth 
                                              ? theme.colorScheme.primary 
                                              : Colors.transparent,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Phone Login',
                                      style: TextStyle(
                                        fontWeight: _isPhoneAuth ? FontWeight.bold : FontWeight.normal,
                                        color: _isPhoneAuth 
                                            ? theme.colorScheme.primary 
                                            : theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Input fields
                        if (_isSignUp) ...[
                          CustomTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Please enter your name';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (_isSignUp || !_isPhoneAuth) ...[
                          // Email inputs
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (val) {
                              if (val == null || val.isEmpty || !val.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (_isSignUp || (_isPhoneAuth && !_isSignUp)) ...[
                          // Phone Input
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: '+15550199',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (_errorMessage.isNotEmpty) ...[
                          Text(
                            _errorMessage,
                            style: TextStyle(color: theme.colorScheme.error, fontSize: 13, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Action Button
                        CustomButton(
                          text: _isSignUp 
                              ? 'Create Account' 
                              : (_isPhoneAuth ? 'Send OTP Code' : 'Sign In'),
                          isLoading: _isLoading,
                          onPressed: () {
                            if (_isSignUp) {
                              _handleEmailSubmit(authService);
                            } else if (_isPhoneAuth) {
                              _handlePhoneSubmit(authService);
                            } else {
                              _handleEmailSubmit(authService);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Switch signup/login toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isSignUp ? 'Already have an account?' : "Don't have an account?",
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            TextButton(
                              onPressed: () {
                                _clearError();
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                  _isPhoneAuth = false;
                                });
                              },
                              child: Text(
                                _isSignUp ? 'Sign In' : 'Sign Up',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        // Social login divider
                        if (!_isSignUp) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.1))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.1))),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Google sign in button
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.15)),
                              backgroundColor: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
                            ),
                            onPressed: _isLoading ? null : () => _handleGoogleSignIn(authService),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.google,
                                  color: Color(0xFFDE4032),
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
