import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/core/app_state.dart';
import 'package:urban_plants/features/auth/services/auth_api_service.dart';
import 'package:urban_plants/features/auth/screens/login_screen.dart';
import 'package:urban_plants/features/commerce/screens/vip_subscription_screen.dart';
import 'package:urban_plants/features/commerce/screens/expert_consultation_screen.dart';
import 'package:urban_plants/features/commerce/screens/affiliate_store_screen.dart';
import 'package:urban_plants/features/treatment/screens/disease_encyclopedia_screen.dart';
import 'package:urban_plants/features/admin/screens/admin_dashboard_screen.dart';
import 'package:urban_plants/features/admin/screens/admin_user_management_screen.dart';
import 'package:urban_plants/features/voice/screens/voice_assistant_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthApiService _authService = AuthApiService();
  bool _biometricEnabled = true;

  void _showDeleteAccountConfirmation() {
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.criticalRed),
            SizedBox(width: 8),
            Text('Xóa tài khoản vĩnh viễn', style: TextStyle(fontSize: 16, color: AppTheme.criticalRed)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hành động này sẽ XÓA VĨNH VIỄN toàn bộ danh sách cây, nhật ký sinh trưởng, bệnh án và lịch tưới của bạn theo chuẩn Google Play. Không thể khôi phục.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 14),
            const Text('Để xác nhận, vui lòng nhập chính xác cụm từ:'),
            const SelectableText(
              'XOA TAI KHOAN',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.criticalRed),
            ),
            const SizedBox(height: 10),
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
                await _authService.deleteAccountPermanently(null);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tài khoản đã được xóa vĩnh viễn khỏi hệ thống.')),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
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
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Tài Khoản & Dịch Vụ Mở Rộng'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              final nav = Navigator.of(context);
              await _authService.clearAuth();
              nav.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // User Avatar & Name Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: appState.isVip ? const Color(0xFFFFD700) : AppTheme.mintSurface,
                      child: Icon(
                        appState.isVip ? Icons.workspace_premium : Icons.person,
                        size: 40,
                        color: appState.isVip ? const Color(0xFF1B5E20) : AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.userName,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appState.userEmail,
                            style: const TextStyle(fontSize: 12, color: AppTheme.neutralMuted),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: appState.isVip ? const Color(0xFFFFD700) : AppTheme.mintSurface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  appState.isVip ? 'HỘI VIÊN VIP PRO' : 'TÀI KHOẢN MIỄN PHÍ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: appState.isVip ? Colors.black : AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                              Text(
                                '📍 ${appState.currentLocationName}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // DANH MỤC THƯƠNG MẠI & DỊCH VỤ (US-083 .. US-092)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFFBEB),
                      child: Icon(Icons.workspace_premium, color: Color(0xFFD97706)),
                    ),
                    title: const Text('Gói Hội Viên Urban Plants Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      appState.isVip ? 'Đang hoạt động (Không giới hạn lượt quét AI)' : 'Chỉ 29k/tháng hoặc 299k/năm',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VipSubscriptionScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF0FDF4),
                      child: Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryGreen),
                    ),
                    title: const Text('Cửa Hàng Vật Tư Sinh Học & Affiliate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Liên kết Shopee/Lazada chuẩn Safe-First', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AffiliateStoreScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFEF2F2),
                      child: Icon(Icons.videocam_outlined, color: Colors.deepOrange),
                    ),
                    title: const Text('Tư Vấn 1-1 Chuyên Gia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Video Call 1-1 trực tiếp với kỹ sư cây trồng', style: TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber.shade200, borderRadius: BorderRadius.circular(6)),
                          child: const Text('BẢO TRÌ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExpertConsultationScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF1F5F9),
                      child: Icon(Icons.menu_book, color: Color(0xFF475569)),
                    ),
                    title: const Text('Từ Điển Bách Khoa Sâu Bệnh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Tra cứu nguyên nhân và phác đồ theo từng loài cây', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DiseaseEncyclopediaScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF0FDF4),
                      child: Icon(Icons.mic, color: AppTheme.primaryGreen),
                    ),
                    title: const Text('Trợ Lý Giọng Nói Tiếng Việt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Điều khiển rảnh tay bằng giọng nói tiếng Việt', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VoiceAssistantScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ADMIN CMS & QUẢN TRỊ NỀN TẢNG (US-093 .. US-098)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEFF6FF),
                      child: Icon(Icons.analytics_outlined, color: Colors.blue),
                    ),
                    title: const Text('Admin Dashboard & Thống Kê', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Biểu đồ DAU/MAU, doanh thu & bản đồ nhiệt dịch bệnh', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFAF5FF),
                      child: Icon(Icons.admin_panel_settings_outlined, color: Colors.purple),
                    ),
                    title: const Text('Quản Trị Người Dùng & Phân Quyền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Quản trị tài khoản, kiểm duyệt và OTA Model Update', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // BẢO MẬT & CÀI ĐẶT
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint, color: AppTheme.primaryGreen),
                    title: const Text('Xác thực Sinh trắc học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Mở khóa nhanh bằng Vân tay hoặc FaceID', style: TextStyle(fontSize: 11)),
                    value: _biometricEnabled,
                    activeThumbColor: AppTheme.primaryGreen,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: AppTheme.criticalRed),
                    title: const Text('Xóa tài khoản vĩnh viễn', style: TextStyle(color: AppTheme.criticalRed, fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Tuân thủ chính sách dữ liệu Google Play Store', style: TextStyle(fontSize: 11)),
                    onTap: _showDeleteAccountConfirmation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
