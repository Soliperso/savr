import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _resetEmailSent = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _autoDisposeTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _loadLastEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fadeController.dispose();
    _cooldownTimer?.cancel();
    _autoDisposeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEmail = prefs.getString('last_email');
    if (lastEmail != null && mounted) {
      _emailController.text = lastEmail;
    }
  }

  Future<void> _saveLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_email', email);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCooldown > 0) {
            _resendCooldown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _saveLastEmail(_emailController.text);

      final success = await context.read<AuthProvider>().forgotPassword(
        _emailController.text,
      );

      if (success && mounted) {
        setState(() => _resetEmailSent = true);
        _fadeController.forward();
        _startResendCooldown();

        // Auto-dispose success message after 5 minutes
        _autoDisposeTimer = Timer(const Duration(minutes: 5), () {
          if (mounted) {
            setState(() => _resetEmailSent = false);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDark
                  ? [Colors.blue.shade900, Colors.black]
                  : [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back to login',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),

                  // Title
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16.h),

                  // Description
                  Text(
                    'Enter your email address and we\'ll send you instructions to reset your password.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40.h),

                  if (!_resetEmailSent) ...[
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.sp,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                        prefixIcon: Icon(
                          Icons.mail_outline,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white30 : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      validator: _validateEmail,
                    ),

                    SizedBox(height: 24.h),

                    // Submit Button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.isLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? Colors.white : Colors.blue,
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark ? Colors.white : Colors.blue,
                              foregroundColor:
                                  isDark ? Colors.blue : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Send Reset Instructions',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Error Message
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.error != null) {
                          return Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: Text(
                              auth.error!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                                color: Colors.red[300],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ] else ...[
                    // Success Message with Animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64.w,
                            color: isDark ? Colors.white : Colors.green,
                          ),

                          SizedBox(height: 24.h),

                          Text(
                            'Password Reset Email Sent',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 16.h),

                          Text(
                            'Please check your email for instructions to reset your password.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 32.h),

                          // Resend Button with Cooldown
                          TextButton.icon(
                            onPressed:
                                _resendCooldown > 0 ? null : _handleSubmit,
                            icon: Icon(
                              Icons.refresh,
                              color: isDark ? Colors.white70 : Colors.blue,
                            ),
                            label: Text(
                              _resendCooldown > 0
                                  ? 'Resend in ${_resendCooldown}s'
                                  : 'Resend Email',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                                color: isDark ? Colors.white70 : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Back to Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password? ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
