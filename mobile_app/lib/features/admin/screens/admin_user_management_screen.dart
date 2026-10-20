import 'package:flutter/material.dart';
import 'package:urban_plants/core/theme.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  // Mock danh sách người dùng quản trị
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'u1',
      'full_name': 'Nguyễn Văn Làm Vườn',
      'email': 'gardener@urbanplants.vn',
      'role': 'USER',
      'is_active': true,
    },
    {
      'id': 'u2',
      'full_name': 'ThS. Lê Nông Học',
      'email': 'expert.le@urbanplants.vn',
      'role': 'EXPERT',
      'is_active': true,
    },
    {
      'id': 'u3',
      'full_name': 'Trần Thị Spam Link',
      'email': 'spammer@tempmail.com',
      'role': 'USER',
      'is_active': false,
    },
  ];

  // US-014: Phân quyền người dùng
  void _changeUserRole(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Phân quyền người dùng (US-014)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...['USER', 'VIP', 'EXPERT', 'ADMIN'].map((role) {
              return ListTile(
                title: Text(role),
                trailing: user['role'] == role ? const Icon(Icons.check, color: AppTheme.primaryGreen) : null,
                onTap: () {
                  setState(() => user['role'] = role);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã cập nhật vai trò của ${user['full_name']} thành $role')),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // US-015: Khóa / Mở khóa tài khoản
  void _toggleUserStatus(Map<String, dynamic> user) {
    final bool currentStatus = user['is_active'];
    setState(() {
      user['is_active'] = !currentStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !currentStatus
              ? 'Đã mở khóa tài khoản ${user['full_name']}'
              : 'Đã khóa tài khoản ${user['full_name']} do vi phạm tiêu chuẩn cộng đồng',
        ),
        backgroundColor: !currentStatus ? AppTheme.primaryGreen : AppTheme.criticalRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị Người dùng & Phân quyền'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) {
          final u = _users[index];
          final bool isActive = u['is_active'];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isActive ? AppTheme.mintSurface : Colors.red.shade100,
                child: Icon(
                  isActive ? Icons.person : Icons.block,
                  color: isActive ? AppTheme.primaryGreen : AppTheme.criticalRed,
                ),
              ),
              title: Text(u['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u['email'], style: const TextStyle(fontSize: 12, color: AppTheme.neutralMuted)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          u['role'],
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? 'Đang hoạt động' : 'Đã bị khóa',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppTheme.primaryGreen : AppTheme.criticalRed,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'role') _changeUserRole(u);
                  if (val == 'toggle_status') _toggleUserStatus(u);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        Icon(Icons.security, size: 20),
                        SizedBox(width: 8),
                        Text('Đổi vai trò'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Row(
                      children: [
                        Icon(isActive ? Icons.lock : Icons.lock_open, size: 20),
                        SizedBox(width: 8),
                        Text(isActive ? 'Khóa tài khoản' : 'Mở khóa'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
