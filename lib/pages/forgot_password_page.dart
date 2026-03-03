import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  String? _error;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Send password reset email via Supabase
      await AuthService.requestPasswordReset(_emailController.text.trim());

      if (!mounted) return;

      setState(() {
        _emailSent = true;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset link sent to ${_emailController.text.trim()}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      // Go back to login after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to send reset email. Please check your email address.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 48),

                  if (!_emailSent) ...[
                    // Email Field
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your registered email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    // Success message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.mark_email_read,
                            size: 48,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Check Your Email',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'ve sent a password reset link to your email. Click the link to set a new password.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Error message
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: AppTheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Submit button
                  if (!_emailSent)
                    CustomButton(
                      text: 'Send Reset Link',
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      type: ButtonType.primary,
                      isLoading: _isSubmitting,
                    )
                  else
                    CustomButton(
                      text: 'Back to Login',
                      onPressed: () => Navigator.pop(context),
                      type: ButtonType.secondary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.lock_reset, size: 60, color: AppTheme.primary),
        ),
        const SizedBox(height: 24),
        Text(
          'Reset Password',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email and we\'ll send you a link to reset your password',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
