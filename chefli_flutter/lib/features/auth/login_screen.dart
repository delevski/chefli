import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onClose;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onClose,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isPasswordVisible = false;
  bool _isCreateAccount = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();
    
    if (success && mounted) {
      widget.onLoginSuccess?.call();
    } else if (authProvider.errorMessage != null && mounted) {
      _showError(authProvider.errorMessage!);
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isCreateAccount) {
      success = await authProvider.createAccount(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      widget.onLoginSuccess?.call();
    } else if (authProvider.errorMessage != null && mounted) {
      _showError(authProvider.errorMessage!);
    }
  }

  Future<void> _handleForgotPassword() async {
    final l10n = AppLocalizations.of(context);
    if (_emailController.text.trim().isEmpty) {
      _showError(l10n.pleaseEnterEmailFirst);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordResetEmailSent),
          backgroundColor: ChefliTheme.accent,
        ),
      );
    } else if (authProvider.errorMessage != null && mounted) {
      _showError(authProvider.errorMessage!);
    }
  }

  void _showError(String message) {
    // Clean up error message
    String cleanMessage = message;
    if (cleanMessage.startsWith('Exception: ')) {
      cleanMessage = cleanMessage.substring(11);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cleanMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a1410),
              ChefliTheme.bgMain,
              const Color(0xFF0d0a08),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background glow effect
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ChefliTheme.primary.withOpacity(0.15),
                          ChefliTheme.primary.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.7],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Close button
              if (widget.onClose != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(
                      LucideIcons.x,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),

              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    
                    // Logo
                    _buildLogo(),
                    const SizedBox(height: 48),
                    
                    // Google Sign In Button
                    _buildGoogleButton(),
                    const SizedBox(height: 28),
                    
                    // OR Divider
                    _buildOrDivider(),
                    const SizedBox(height: 28),
                    
                    // Email/Password Form
                    _buildForm(),
                    const SizedBox(height: 40),
                    
                    // Create Account Link
                    _buildCreateAccountLink(),
                    const SizedBox(height: 32),
                    
                    // Footer Links
                    _buildFooterLinks(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Crossed utensils icon
        Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: -0.4,
              child: Icon(
                LucideIcons.utensils,
                size: 48,
                color: ChefliTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Chefli',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.aiCulinaryAssistant,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 3,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildGoogleButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final l10n = AppLocalizations.of(context);
        final isLoading = auth.status == AuthStatus.loading;
        
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white.withOpacity(0.03),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Logo
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.continueWithGoogle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildOrDivider() {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.2),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.or,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final l10n = AppLocalizations.of(context);
        final isLoading = auth.status == AuthStatus.loading;
        
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email Field
              Text(
                l10n.emailAddress,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: l10n.emailPlaceholder,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: ChefliTheme.primary.withOpacity(0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      LucideIcons.atSign,
                      color: Colors.white.withOpacity(0.3),
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterEmail;
                  }
                  if (!value.contains('@')) {
                    return l10n.pleaseEnterValidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Password Field
              Text(
                l10n.password,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: l10n.passwordPlaceholder,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: ChefliTheme.primary.withOpacity(0.5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: Colors.white.withOpacity(0.3),
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterPassword;
                  }
                  if (_isCreateAccount && value.length < 6) {
                    return l10n.passwordMinLength;
                  }
                  return null;
                },
              ),
              
              // Forgot Password Link (only show when not creating account)
              if (!_isCreateAccount)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      l10n.forgotPassword,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ChefliTheme.primary,
                      ),
                    ),
                  ),
                ),
              
              SizedBox(height: _isCreateAccount ? 24 : 8),
              
              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleEmailSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChefliTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : Text(
                          _isCreateAccount ? l10n.createAccount : l10n.signIn,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildCreateAccountLink() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final l10n = AppLocalizations.of(context);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isCreateAccount ? l10n.alreadyHaveAccount : l10n.dontHaveAccount,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            TextButton(
              onPressed: () {
                // Clear any errors when switching modes
                auth.clearError();
                setState(() {
                  _isCreateAccount = !_isCreateAccount;
                  // Clear form errors
                  _formKey.currentState?.reset();
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                _isCreateAccount ? l10n.signIn : l10n.createAccount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms);
      },
    );
  }

  Widget _buildFooterLinks() {
    final l10n = AppLocalizations.of(context);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.35),
        ),
        children: [
          TextSpan(
            text: l10n.privacyPolicy.toUpperCase(),
            style: TextStyle(letterSpacing: 0.5),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Navigate to privacy policy
              },
          ),
          TextSpan(text: '   •   '),
          TextSpan(
            text: l10n.termsOfService.toUpperCase(),
            style: TextStyle(letterSpacing: 0.5),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Navigate to terms of service
              },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

