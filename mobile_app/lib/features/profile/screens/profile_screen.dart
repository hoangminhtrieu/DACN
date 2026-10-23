import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/features/auth/services/auth_api_service.dart';
import 'package:urban_plants/features/auth/screens/login_screen.dart';
import 'package:urban_plants/features/admin/screens/admin_user_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _user;
  final AuthApiService _authService = AuthApiService();
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.userData);
    _biometricEnabled = _user['is_biometric_enabled'] ?? false;
  }

  // US-010: Cập nhật thông tin cá nhân
  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _user['full_name']);
    final cityCtrl = TextEditingController(text: _user['location_city'] ?? 'TP. Hồ Chí Minh');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật thông tin cá nhân'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ và tên')),
            const SizedBox(height: 12),
            TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'Thành phố sinh sống')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _user['full_name'] = nameCtrl.text;
                _user['location_city'] = cityCtrl.text;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật thông tin thành công!'), backgroundColor: AppTheme.primaryGreen),
              );
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  // US-013: Xóa vĩnh viễn tài khoản chuẩn CH Play
  void _showDeleteAccountConfirmation() {
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.criticalRed),
            SizedBox(width: 8),
            Text('Xóa tài khoản vĩnh viễn', style: TextStyle(fontSize: 18, color: AppTheme.criticalRed)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hành động này sẽ XÓA VĨNH VIỄN toàn bộ danh sách cây, nhật ký sinh trưởng, bệnh án và lịch tưới của bạn theo chuẩn Google Play. Không thể khôi phục.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text('Để xác nhận, vui lòng nhập chính xác cụm từ:'),
            const SelectableText(
              'XOA TAI KHOAN',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.criticalRed),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              decoration: const InputDecoration(
                hintText: 'Nhập XOA TAI KHOAN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.criticalRed),
            onPressed: () async {
              if (confirmCtrl.text.trim().toUpperCase() == 'XOA TAI KHOAN') {
                Navigator.pop(ctx);
                final deleted = await _authService.deleteAccountPermanently(null);
                if (deleted && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tài khoản đã được xóa vĩnh viễn khỏi hệ thống.')),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cụm từ xác nhận không chính xác!'), backgroundColor: AppTheme.criticalRed),
                );
              }
            },
            child: const Text('Xác nhận Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _user['role'] == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & Tài khoản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final nav = Navigator.of(context);
              await _authService.clearAuth();
              if (!mounted) return;
              nav.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Avatar & Name Card
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.mintSurface,
                    child: Icon(Icons.person, size: 54, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _user['full_name'] ?? 'Người làm vườn',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user['email'] ?? _user['phone'] ?? '',
                    style: const TextStyle(fontSize: 13, color: AppTheme.neutralMuted),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppTheme.warningAmber.withValues(alpha: 0.2) : AppTheme.mintSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Vai trò: ${_user['role'] ?? 'USER'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAdmin ? Colors.deepOrange : AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Profile & Preferences
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: AppTheme.primaryGreen),
                    title: const Text('Chỉnh sửa thông tin cá nhân'),
                    subtitle: Text('Vị trí: ${_user['location_city'] ?? 'TP. Hồ Chí Minh'} (Dự báo thời tiết)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showEditProfileDialog,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint, color: AppTheme.primaryGreen),
                    title: const Text('Xác thực Sinh trắc học'),
                    subtitle: const Text('Mở khóa nhanh bằng Vân tay hoặc FaceID'),
                    value: _biometricEnabled,
                    activeThumbColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setState(() => _biometricEnabled = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? 'Đã kích hoạt sinh trắc học' : 'Đã tắt sinh trắc học')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_reset, color: AppTheme.primaryGreen),
                    title: const Text('Đổi mật khẩu định kỳ'),
                    subtitle: const Text('Bảo mật tài khoản khu vườn của bạn'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đổi mật khẩu đang mở')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // US-014, US-015: Admin Panel Section
            if (isAdmin) ...[
              Card(
                color: Colors.amber.shade50,
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.deepOrange),
                  title: const Text('Quản trị Người dùng (Admin CMS)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Phân quyền VIP/Chuyên gia & Khóa tài khoản vi phạm'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.deepOrange),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // US-013: Danger Zone - Delete Account
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: AppTheme.criticalRed),
                title: const Text('Xóa tài khoản vĩnh viễn', style: TextStyle(color: AppTheme.criticalRed, fontWeight: FontWeight.bold)),
                subtitle: const Text('Tuân thủ quyền riêng tư dữ liệu Google Play Store'),
                onTap: _showDeleteAccountConfirmation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
