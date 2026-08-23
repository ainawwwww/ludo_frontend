import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';

import 'package:ludo_vibe/shared/widgets/ludo_loading_overlay.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;
  Timer? _timer;
  bool _showLogin = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showLogin = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _loadingController.dispose();
    super.dispose();
  }

  /// Perform guest login via the API, then navigate to home
  Future<void> _handleGuestLogin() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final success = await ref.read(authProvider.notifier).guestLogin();
      if (mounted) {
        if (success) {
          context.go(AppConstants.homeRoute);
        } else {
          final error = ref.read(authProvider).error ?? 'Guest login failed.';
          _showError(error);
        }
      }
    } catch (e) {
      if (mounted) _showError('Guest login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  /// Google Sign-In handler (Native SDK for mobile / OAuth 2.0 popup for web)
  Future<void> _handleGoogleSignIn() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '741692358771-gr8b608j5l7ck4bufcare9stoerqvfav.apps.googleusercontent.com'
            : null,
        scopes: ['email', 'profile', 'openid'],
      );

      final account = await googleSignIn.signIn();
      if (account == null) {
        // Sign-in cancelled by user
        if (mounted) setState(() => _isAuthenticating = false);
        return;
      }

      final authentication = await account.authentication;
      final token = (authentication.idToken != null && authentication.idToken!.isNotEmpty)
          ? authentication.idToken!
          : authentication.accessToken;

      if (token == null || token.isEmpty) {
        if (mounted) {
          _showError('Could not retrieve Google authentication token.');
          setState(() => _isAuthenticating = false);
        }
        return;
      }

      final success = await ref.read(authProvider.notifier).googleSignIn(token);
      if (mounted) {
        if (success) {
          context.go(AppConstants.homeRoute);
        } else {
          final error = ref.read(authProvider).error ?? 'Google sign-in failed.';
          _showError(error);
        }
      }
    } catch (e) {
      debugPrint('Google Sign-In Exception: $e');
      if (mounted) _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  /// Show a login/register dialog for "Bind with Email"
  Future<void> _handleEmailBind() async {
    if (_isAuthenticating) return;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();
    final countryController = TextEditingController(text: 'PK');
    bool isRegisterMode = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;
            return AlertDialog(
              backgroundColor: const Color(0xFF160A4F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: const Color(0xFF8C7DF5).withOpacity(0.5)),
              ),
              title: Text(
                isRegisterMode ? 'REGISTER ACCOUNT' : 'LOGIN ACCOUNT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRegisterMode) ...[
                      _buildDialogField(usernameController, 'Username', Icons.person, scale),
                      SizedBox(height: 12 * scale),
                      _buildDialogField(emailController, 'Email Address', Icons.email, scale),
                      SizedBox(height: 12 * scale),
                      _buildDialogField(countryController, 'Country Code (e.g. PK, US)', Icons.flag, scale),
                    ] else ...[
                      _buildDialogField(usernameController, 'Username or Email', Icons.person, scale),
                    ],
                    SizedBox(height: 12 * scale),
                    _buildDialogField(passwordController, 'Password', Icons.lock, scale, obscure: true),
                    SizedBox(height: 16 * scale),
                    GestureDetector(
                      onTap: () => setDialogState(() => isRegisterMode = !isRegisterMode),
                      child: Text(
                        isRegisterMode ? 'Already have an account? Login' : 'No account? Register now',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12 * scale,
                          color: const Color(0xFFCCA3FF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 14 * scale)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C3EC8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    isRegisterMode ? 'Register' : 'Login',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14 * scale),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) return;

    final usernameOrInput = usernameController.text.trim();
    final password = passwordController.text;

    if (usernameOrInput.isEmpty || password.isEmpty) {
      _showError('Please fill in all required fields.');
      return;
    }

    setState(() => _isAuthenticating = true);

    try {
      bool success;
      if (isRegisterMode) {
        final email = emailController.text.trim();
        final country = countryController.text.trim().isEmpty ? 'PK' : countryController.text.trim().toUpperCase();
        if (email.isEmpty) {
          _showError('Email is required for registration.');
          setState(() => _isAuthenticating = false);
          return;
        }
        success = await ref.read(authProvider.notifier).register(
              usernameOrInput,
              email,
              password,
              country: country,
            );
      } else {
        success = await ref.read(authProvider.notifier).login(
              usernameOrInput,
              password,
            );
      }

      if (mounted) {
        if (success) {
          context.go(AppConstants.homeRoute);
        } else {
          final error = ref.read(authProvider).error ?? 'Authentication failed.';
          _showError(error);
        }
      }
    } catch (e) {
      if (mounted) _showError('Authentication failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }

    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    countryController.dispose();
  }


  Widget _buildDialogField(
    TextEditingController controller,
    String hint,
    IconData icon,
    double scale, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Colors.white, fontSize: 14 * scale),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white38, fontSize: 14 * scale),
        prefixIcon: Icon(icon, color: const Color(0xFF8C7DF5), size: 20 * scale),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF8C7DF5).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF8C7DF5).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8C7DF5)),
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoon(String provider) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider sign-in coming soon!'),
        backgroundColor: const Color(0xFF4C3EC8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;
    final authState = ref.watch(authProvider);
    final isLoading = _isAuthenticating || authState.isLoading;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Splash background pattern image
          Image.asset(
            'assets/graphics/bg_splash.png',
            fit: BoxFit.cover,
          ),
          
          if (!_showLogin) ...[
            // Connecting spinner and tip text at the bottom area
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * 0.12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: _loadingController,
                        child: CustomPaint(
                          size: Size(32 * scale, 32 * scale),
                          painter: const _DashedCirclePainter(),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Text(
                        'Connecting',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                    child: Text(
                      'Tip: If Your microphone is not working, check the microphone setting in the phone',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFCCA3FF),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Login panel containing Bind with Apple, Facebook, Email and Guest options!
            Center(
              child: Container(
                width: 310 * scale,
                padding: EdgeInsets.symmetric(vertical: 24 * scale, horizontal: 20 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF160A4F).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24 * scale),
                  border: Border.all(color: const Color(0xFF8C7DF5).withOpacity(0.5), width: 1.5 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20 * scale,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BIND ACCOUNT',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    
                    // Bind with Apple Button
                    _buildLoginButton(
                      label: 'Bind with Apple',
                      icon: Icons.apple,
                      color: Colors.black.withOpacity(0.9),
                      borderColor: Colors.white24,
                      scale: scale,
                      onTap: () => _showComingSoon('Apple'),
                    ),
                    SizedBox(height: 12 * scale),
                    
                    // Bind with Facebook Button
                    _buildLoginButton(
                      label: 'Bind with Facebook',
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      scale: scale,
                      onTap: () => _showComingSoon('Facebook'),
                    ),
                    SizedBox(height: 12 * scale),

                    // Bind with Google Button
                    _buildLoginButton(
                      label: 'Bind with Google',
                      icon: Icons.g_mobiledata,
                      color: const Color(0xFFEA4335),
                      borderColor: const Color(0xFFFBBC05),
                      scale: scale,
                      onTap: _handleGoogleSignIn,
                    ),
                    SizedBox(height: 12 * scale),
                    
                    // Bind with Email Button — now shows login/register dialog
                    _buildLoginButton(
                      label: 'Bind with Email',
                      icon: Icons.email_rounded,
                      color: const Color(0xFF4C3EC8),
                      borderColor: const Color(0xFF8C7DF5),
                      scale: scale,
                      onTap: _handleEmailBind,
                    ),
                    SizedBox(height: 24 * scale),
                    
                    // Enter as Guest Option — now calls guest login API
                    GestureDetector(
                      onTap: _handleGuestLogin,
                      child: Text(
                        'Enter as Guest',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFCCA3FF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (isLoading) const LudoLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    required String label,
    required IconData icon,
    required Color color,
    Color? borderColor,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48 * scale,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24 * scale),
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5 * scale) : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8 * scale,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22 * scale),
            SizedBox(width: 8 * scale),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const dashCount = 10;
    const gapAngle = pi / 12;
    const sweepAngle = (2 * pi - dashCount * gapAngle) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (sweepAngle + gapAngle) - pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
