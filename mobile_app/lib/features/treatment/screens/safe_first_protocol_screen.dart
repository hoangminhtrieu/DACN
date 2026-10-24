import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plants/core/theme.dart';
import 'package:urban_plants/core/app_state.dart';
import 'package:urban_plants/features/diagnosis/screens/ai_camera_scanner_screen.dart';

class SafeFirstProtocolScreen extends StatefulWidget {
  final Map<String, dynamic>? protocolData;
  final Map<String, dynamic>? verificationResult;
  final Map<String, dynamic>? protocol;

  const SafeFirstProtocolScreen({
    super.key,
    this.protocolData,
    this.verificationResult,
    this.protocol,
  });

  @override
  State<SafeFirstProtocolScreen> createState() => _SafeFirstProtocolScreenState();
}

class _SafeFirstProtocolScreenState extends State<SafeFirstProtocolScreen> {
  // Danh mục cửa hàng vật tư đô thị gần nhất (US-084)
  final List<Map<String, dynamic>> _nearbyStores = [
    {
      'name': 'Vật Tư Nông Nghiệp Đô Thị Sài Gòn',
      'distance': '0.8 km',
      'address': '124 Điện Biên Phủ, Phường Đa Kao, Quận 1, TP.HCM',
      'phone': '0908 123 456',
    },
    {
      'name': 'Cửa Hàng Sinh Học Ban Công Xanh',
      'distance': '1.5 km',
      'address': '45 Nguyễn Hữu Cảnh, Bình Thạnh, TP.HCM',
      'phone': '0933 888 999',
    },
    {
      'name': 'Vườn Ươm Cây Cảnh & Vật Tư Hữu Cơ',
      'distance': '2.4 km',
      'address': '210 Nguyễn Thị Minh Khai, Quận 3, TP.HCM',
      'phone': '0912 345 678',
    },
  ];

  // Danh mục vật tư sinh học chuẩn Safe-First (US-083)
  final List<Map<String, dynamic>> _bioSupplies = [
    {
      'name': 'Dầu Neem Nguyên Chất Ép Lạnh (Chai 100ml)',
      'brand': 'Docneem Organic',
      'price': '85.000 đ',
      'active': 'Azadirachtin tự nhiên',
      'target': 'Đặc trị nhện đỏ, bọ trĩ, phấn trắng',
    },
    {
      'name': 'Chế Phẩm Vi Sinh Bacillus Subtilis (Hũ 200g)',
      'brand': 'Bio-Plant Vietnam',
      'price': '65.000 đ',
      'active': 'Bào tử vi khuẩn Bacillus subtilis',
      'target': 'Đối kháng vi nấm đốm lá, thán thư, phấn trắng',
    },
    {
      'name': 'Nấm Đối Kháng Trichoderma Harzianum (Gói 500g)',
      'brand': 'Đại Học Nông Lâm',
      'price': '55.000 đ',
      'active': 'Trichoderma harzianum 10^9 CFU/g',
      'target': 'Bảo vệ bộ rễ, phòng chống thối rễ, lở cổ rễ',
    },
  ];

  void _showNearbyStoresModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.storefront, color: AppTheme.primaryGreen, size: 24),
                SizedBox(width: 8),
                Text(
                  'Cửa Hàng Vật Tư Nông Nghiệp Gần Nhất (GPS)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._nearbyStores.map((store) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.mintSurface,
                      child: Icon(Icons.location_on, color: AppTheme.primaryGreen),
                    ),
                    title: Text(store['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${store['address']}\nSĐT: ${store['phone']}', style: const TextStyle(fontSize: 11)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                      child: Text(store['distance'], style: const TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showBioSuppliesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.eco, color: AppTheme.primaryGreen, size: 24),
                SizedBox(width: 8),
                Text(
                  'Vật Tư Sinh Học Khuyến Nghị (Safe-First)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._bioSupplies.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.mintSurface,
                      child: Icon(Icons.medical_services, color: AppTheme.primaryGreen),
                    ),
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('Hoạt chất: ${item['active']}\nCông dụng: ${item['target']}', style: const TextStyle(fontSize: 11)),
                    trailing: Text(item['price'], style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                )),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showNearbyStoresModal();
                },
                icon: const Icon(Icons.store),
                label: const Text('Xem danh sách cửa hàng gần nhất để mua ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // RÀNG BUỘC ĐIỀU KIỆN TIÊN QUYẾT (PRECONDITION CONSTRAINT - US-075)
    // Nếu người dùng chưa quét ảnh hoặc chưa chọn chậu cây nào đang bệnh, hiển thị thông báo yêu cầu
    if (!appState.hasActiveDiagnosis && widget.verificationResult == null && widget.protocol == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAF9),
        appBar: AppBar(
          title: const Text('Phác Đồ Safe-First 3 Bước'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.mintSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medical_services_outlined, size: 72, color: AppTheme.primaryGreen),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Chưa có ca bệnh nào đang chọn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Để tạo phác đồ điều trị 3 bước Safe-First chuẩn xác, vui lòng chụp/tải ảnh lá cây qua Camera AI hoặc chọn một chậu cây đang bệnh trong Vườn của bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.4, color: AppTheme.neutralMuted),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AICameraScannerScreen()),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Mở Camera Quét Lá Cây Bệnh', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Dữ liệu ca bệnh đang điều trị
    final String plantName = appState.activeDiagnosedPlantName;
    final String diseaseName = appState.activeDiseaseName;
    final String diseaseSci = appState.activeDiseaseSci;
    final double confidence = appState.activeConfidence;
    final double volume = appState.sprayBottleVolumeLiters;

    // Tính toán công thức pha chế tự động theo thể tích bình xịt (US-076)
    final double neemMl = volume * 5.0; // 5ml / 1 Lít
    final double soapMl = volume * 2.0; // 2ml / 1 Lít
    final double sodaGram = volume * 5.0; // 5g / 1 Lít

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Phác Đồ Safe-First 3 Bước'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront),
            tooltip: 'Cửa hàng vật tư gần nhất (US-084)',
            onPressed: _showNearbyStoresModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header kết quả chẩn đoán
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plantName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.neutralDark),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                diseaseName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepOrange),
                              ),
                              Text(
                                diseaseSci,
                                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppTheme.neutralMuted),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.mintSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(confidence * 100).toStringAsFixed(1)}% AI Tin Cậy',
                            style: const TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.blue, size: 16),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Nguyên tắc Safe-First: Ưu tiên cách ly & hữu cơ an toàn cho trẻ nhỏ và thú cưng.',
                              style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ================= BƯỚC 1: CÁCH LY & CẮT TỈA CƠ HỌC =================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.primaryGreen,
                              child: Text('1', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Bước 1: Cách Ly & Cắt Tỉa Cơ Học',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.neutralDark),
                            ),
                          ],
                        ),
                        if (appState.step1Completed)
                          const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 22)
                        else
                          const Icon(Icons.lock_open, color: Colors.orange, size: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('• Dùng kéo sạch cắt bỏ 100% các lá và đọt có vết đốm phấn bệnh.', style: TextStyle(fontSize: 12, height: 1.3)),
                    const Text('• Khử trùng lưỡi kéo bằng cồn 70 độ trước và sau khi thao tác.', style: TextStyle(fontSize: 12, height: 1.3)),
                    const Text('• Di chuyển chậu cách xa các cây khác tối thiểu 1.5 mét.', style: TextStyle(fontSize: 12, height: 1.3)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appState.step1Completed ? Colors.grey.shade400 : AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: appState.step1Completed
                            ? null
                            : () {
                                appState.completeStep1();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✓ Đã xác nhận hoàn thành Bước 1! Mở khóa Bước 2.'),
                                    backgroundColor: AppTheme.primaryGreen,
                                  ),
                                );
                              },
                        icon: Icon(appState.step1Completed ? Icons.check : Icons.cut),
                        label: Text(appState.step1Completed ? 'Đã hoàn thành Bước 1' : 'Xác nhận Đã Cách Ly & Cắt Tỉa'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ================= BƯỚC 2: GIẢI PHÁP HỮU CƠ / NHÀ LÀM =================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: appState.step1Completed ? Colors.white : Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: appState.step1Completed ? Colors.amber.shade700 : Colors.grey,
                              child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Bước 2: Giải Pháp Hữu Cơ / Nhà Làm',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.neutralDark),
                            ),
                          ],
                        ),
                        if (!appState.step1Completed)
                          const Row(
                            children: [
                              Icon(Icons.lock, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Cần xong B1', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          )
                        else if (appState.step2Completed)
                          const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 22),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (appState.step1Completed) ...[
                      // Bộ tính toán công thức pha chế tự động theo thể tích bình xịt
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '🧪 Thể tích bình xịt của bạn:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                DropdownButton<double>(
                                  value: appState.sprayBottleVolumeLiters,
                                  isDense: true,
                                  items: const [
                                    DropdownMenuItem(value: 0.5, child: Text('0.5 Lít (Bình nhỏ)')),
                                    DropdownMenuItem(value: 1.0, child: Text('1.0 Lít (Chuẩn)')),
                                    DropdownMenuItem(value: 2.0, child: Text('2.0 Lít (Bình lớn)')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) appState.setSprayVolume(val);
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 14),
                            Text('• Dầu Neem nguyên chất: ${neemMl.toStringAsFixed(1)} ml', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown)),
                            Text('• Nước rửa chén sinh học (nhũ hóa): ${soapMl.toStringAsFixed(1)} ml', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                            Text('• Baking Soda kháng nấm: ${sodaGram.toStringAsFixed(1)} gram', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                            const SizedBox(height: 6),
                            const Text(
                              '💡 Hòa tan trong nước ấm 40°C, lắc đều và phun ướt 2 mặt lá lúc 17h30 chiều mát.',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nút Đặt lịch nhắc xịt sau 3-5 ngày (US-078)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryGreen),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: appState.hasScheduledSprayReminder
                              ? null
                              : () {
                                  appState.setScheduledSprayReminder(true);
                                  appState.addSprayReminderSchedule(diseaseName, 3);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✓ Đã tự động thêm lịch nhắc xịt thuốc sau 3 ngày vào Trang Chủ!'),
                                      backgroundColor: AppTheme.primaryGreen,
                                    ),
                                  );
                                },
                          icon: Icon(
                            appState.hasScheduledSprayReminder ? Icons.check : Icons.notification_add_outlined,
                            color: appState.hasScheduledSprayReminder ? Colors.grey : AppTheme.primaryGreen,
                          ),
                          label: Text(
                            appState.hasScheduledSprayReminder ? '✓ Đã đặt lịch nhắc (Hẹn 3 ngày sau)' : 'Đặt Lịch Nhắc Xịt Thuốc Sau 3 Ngày',
                            style: TextStyle(
                              color: appState.hasScheduledSprayReminder ? Colors.grey : AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Nút Xác nhận đã xịt xong Bước 2
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appState.step2Completed ? Colors.grey.shade400 : Colors.amber.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: appState.step2Completed
                              ? null
                              : () {
                                  appState.completeStep2();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✓ Đã hoàn thành xịt dung dịch hữu cơ Bước 2!'),
                                      backgroundColor: AppTheme.primaryGreen,
                                    ),
                                  );
                                },
                          icon: Icon(appState.step2Completed ? Icons.check : Icons.science_outlined),
                          label: Text(appState.step2Completed ? 'Đã hoàn thành Bước 2' : 'Xác nhận Đã Phun Xịt Bước 2'),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Vui lòng hoàn thành Bước 1 (Cách ly & Cắt tỉa cơ học) để mở khóa công thức pha chế.',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ================= BƯỚC 3: HOẠT CHẤT SINH HỌC ĐẶC TRỊ =================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: appState.step3Unlocked ? Colors.white : Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: appState.step3Unlocked ? Colors.purple : Colors.grey,
                              child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Bước 3: Hoạt Chất Sinh Học Đặc Trị',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.neutralDark),
                            ),
                          ],
                        ),
                        if (!appState.step3Unlocked)
                          const Row(
                            children: [
                              Icon(Icons.lock, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Khóa', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          )
                        else
                          const Icon(Icons.verified, color: Colors.purple, size: 22),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (appState.step3Unlocked) ...[
                      const Text('Áp dụng khi bệnh nặng hoặc Bước 2 chưa dứt điểm:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('• Bacillus subtilis (Chế phẩm vi sinh đối kháng nấm mốc).', style: TextStyle(fontSize: 12, height: 1.3)),
                      const Text('• Trichoderma harzianum (Nấm đối kháng bảo vệ gốc rễ).', style: TextStyle(fontSize: 12, height: 1.3)),
                      const Text('• Copper Hydroxide (Đồng sinh học phổ rộng, tỷ lệ an toàn đô thị).', style: TextStyle(fontSize: 12, height: 1.3)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _showBioSuppliesModal,
                              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                              label: const Text('Mua Vật Tư', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _showNearbyStoresModal,
                              icon: const Icon(Icons.storefront, size: 18),
                              label: const Text('Cửa Hàng Gần', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text(
                        'Chỉ kích hoạt Bước 3 khi đã thực hiện Bước 2 hoặc cây có diễn biến xấu hơn.',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ================= CẬP NHẬT KẾT QUẢ ĐIỀU TRỊ =================
            const Text(
              'Đánh Giá Phục Hồi Của Cây:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.neutralDark),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      appState.markDiseaseCured();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Chúc mừng! Chậu "$plantName" đã được cập nhật thành KHỎE MẠNH.'),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.sentiment_very_satisfied),
                    label: const Text('Đã Khỏi Bệnh', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.criticalRed,
                      side: const BorderSide(color: AppTheme.criticalRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      appState.markDiseaseWorsened();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cảnh báo: Bệnh tăng nặng! Đã mở khóa khẩn cấp Bước 3 (Thuốc sinh học đặc trị).'),
                          backgroundColor: AppTheme.criticalRed,
                        ),
                      );
                    },
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Bệnh Nặng Hơn', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
