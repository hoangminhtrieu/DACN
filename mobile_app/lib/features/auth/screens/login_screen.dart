import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/auth/services/auth_api_service.dart';
import 'package:urban_plants/features/auth/screens/register_screen.dart';
import 'package:urban_plants/features/auth/screens/forgot_password_screen.dart';
import 'package:urban_plants/features/home/screens/home_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthApiService _authService = AuthApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final res = await _authService.login(
        _identifierController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeDashboardScreen(userData: res['user'])),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: $e'),
            backgroundColor: AppTheme.criticalRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBiometricLogin() async {
    final success = await _authService.authenticateWithBiometrics();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác thực vân tay/FaceID thành công! Đang truy cập vườn...'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeDashboardScreen(userData: {
            'id': 'usr_trieu',
            'full_name': 'Hoàng Minh Triều',
            'email': 'trieu.urbanplants@gmail.com',
            'role': 'USER',
            'location_city': 'TP. Hồ Chí Minh',
          }),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.eco_rounded, size: 56, color: AppTheme.primaryGreen),
                const SizedBox(height: 16),
                const Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đăng nhập để theo dõi sức khỏe và lịch tưới khu vườn của bạn.',
                  style: TextStyle(fontSize: 14, color: AppTheme.neutralMuted),
                ),
                const SizedBox(height: 32),

                // Identifier Field
                TextFormField(
                  controller: _identifierController,
                  decoration: const InputDecoration(
                    labelText: 'Email hoặc Số điện thoại',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập email hoặc SĐT' : null,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                ),
                const SizedBox(height: 12),

                // Forgot Password link (US-009)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text('Quên mật khẩu? (Lấy lại qua OTP)', style: TextStyle(color: AppTheme.primaryGreen)),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Đăng nhập'),
                ),
                const SizedBox(height: 16),

                // US-011: Nút Sinh trắc học
                OutlinedButton.icon(
                  onPressed: _handleBiometricLogin,
                  icon: const Icon(Icons.fingerprint, color: AppTheme.primaryGreen, size: 24),
                  label: const Text('Đăng nhập nhanh bằng Vân tay / FaceID', style: TextStyle(color: AppTheme.neutralDark)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // Social Logins (US-008)
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Hoặc đăng nhập với', style: TextStyle(color: AppTheme.neutralMuted, fontSize: 13)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // US-008 Google SignIn Flow
                          _authService.oauthLogin(
                            provider: 'google',
                            idToken: 'demo_google_token',
                            fullName: 'Google User',
                          );
                        },
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Google'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // US-008 Apple SignIn Flow
                          _authService.oauthLogin(
                            provider: 'apple',
                            idToken: 'demo_apple_token',
                            fullName: 'Apple User',
                          );
                        },
                        icon: const Icon(Icons.apple, size: 24),
                        label: const Text('Apple ID'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Link to Register (US-007)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản? ', style: TextStyle(color: AppTheme.neutralMuted)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text('Đăng ký ngay', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
