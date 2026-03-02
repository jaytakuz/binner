import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement register logic
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registered successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'สร้างบัญชีใหม่',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'กรอกข้อมูลเพื่อสมัครสมาชิก',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  CustomTextField(
                    label: 'ชื่อ-นามสกุล',
                    hint: 'กรอกชื่อและนามสกุลของคุณ',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อ-นามสกุล';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  CustomTextField(
                    label: 'อีเมล',
                    hint: 'กรอกอีเมลของคุณ',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมล';
                      }
                      if (!value.contains('@')) {
                        return 'กรุณากรอกอีเมลที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  PasswordField(
                    label: 'รหัสผ่าน',
                    hint: 'กรอกรหัสผ่านของคุณ',
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรหัสผ่าน';
                      }
                      if (value.length < 6) {
                        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  PasswordField(
                    label: 'ยืนยันรหัสผ่าน',
                    hint: 'กรอกรหัสผ่านอีกครั้ง',
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณายืนยันรหัสผ่าน';
                      }
                      if (value != _passwordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Terms and Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppTheme.primary,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            children: [
                              const Text('ฉันยอมรับ'),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('เงื่อนไขและข้อตกลง'),
                              ),
                              const Text('และ'),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('นโยบายความเป็นส่วนตัว'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  CustomButton(
                    text: 'สมัครสมาชิก',
                    onPressed: _handleRegister,
                    type: ButtonType.primary,
                  ),
                  const SizedBox(height: 16),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('มีบัญชีอยู่แล้ว?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('เข้าสู่ระบบ'),
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
