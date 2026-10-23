import 'package:flutter/material.dart';

class VipSubscriptionScreen extends StatefulWidget {
  const VipSubscriptionScreen({super.key});

  @override
  State<VipSubscriptionScreen> createState() => _VipSubscriptionScreenState();
}

class _VipSubscriptionScreenState extends State<VipSubscriptionScreen> {
  String _selectedPlan = 'MONTHLY'; // MONTHLY (29k) or YEARLY (299k)
  String _selectedPayment = 'VIETQR'; // VIETQR, MOMO, ZALOPAY
  bool _isProcessing = false;
  Map<String, dynamic>? _paymentResult;

  void _processPayment() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _isProcessing = false;
        final amount = _selectedPlan == 'MONTHLY' ? 29000 : 299000;
        _paymentResult = {
          'invoice_number': 'INV-UP-20261023-A9B8',
          'amount_vnd': amount,
          'method': _selectedPayment,
          'qr_code_url': 'https://img.vietqr.io/image/MB-0968888999-compact2.png?amount=$amount&addInfo=VIP_UP_PRO&accountName=CONG%20TY%20URBAN%20PLANTS',
          'status': 'SUCCESS',
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Gói Hội Viên Urban Plants Pro'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: _paymentResult != null ? _buildReceiptView() : _buildSubscriptionView(),
    );
  }

  Widget _buildSubscriptionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner quyền lợi VIP
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 48),
                const SizedBox(height: 8),
                const Text(
                  'NÂNG CẤP URBAN PLANTS PRO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bảo vệ trọn vẹn khu vườn ban công với trợ lý AI không giới hạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _buildBenefitRow(Icons.all_inclusive, 'Không giới hạn lượt quét bệnh lá bằng AI On-Device'),
                _buildBenefitRow(Icons.layers, 'Bản đồ nhiệt Grad-CAM độ nét cao khoanh vùng tổn thương'),
                _buildBenefitRow(Icons.record_voice_over, 'Trợ lý giọng nói tiếng Việt rảnh tay điều khiển thông minh'),
                _buildBenefitRow(Icons.history_edu, 'Hồ sơ bệnh án và nhật ký sinh trưởng không giới hạn cây'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Chọn gói cước (US-085)
          const Text('Chọn gói thời hạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPlanCard(
                  id: 'MONTHLY',
                  title: 'Gói 1 Tháng',
                  price: '29.000 đ',
                  subtext: 'Chỉ ~1k / ngày',
                  badge: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlanCard(
                  id: 'YEARLY',
                  title: 'Gói 1 Năm',
                  price: '299.000 đ',
                  subtext: 'Tiết kiệm 20%',
                  badge: 'TIẾT KIỆM NHẤT',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chọn phương thức thanh toán (US-086)
          const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          _buildPaymentOption('VIETQR', 'Mã VietQR động (Quét app ngân hàng bất kỳ)', Icons.qr_code_scanner, Colors.blue),
          _buildPaymentOption('MOMO', 'Ví điện tử MoMo', Icons.account_balance_wallet, Colors.pink),
          _buildPaymentOption('ZALOPAY', 'Ví điện tử ZaloPay', Icons.payment, Colors.teal),
          const SizedBox(height: 24),

          // Nút thanh toán
          ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isProcessing
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    _selectedPlan == 'MONTHLY' ? 'Thanh toán 29.000 đ' : 'Thanh toán 299.000 đ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12.5))),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required String subtext,
    String? badge,
  }) {
    final isSelected = _selectedPlan == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.green.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(6)),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text(subtext, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String id, String label, IconData icon, Color color) {
    final isSelected = _selectedPayment == id;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent, width: 1.5),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedPayment = id),
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildReceiptView() {
    final res = _paymentResult!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 60),
                const SizedBox(height: 12),
                const Text(
                  'KÍCH HOẠT VIP THÀNH CÔNG!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tài khoản của bạn đã được nâng cấp lên Urban Plants Pro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const Divider(height: 30),
                _buildReceiptRow('Mã hóa đơn:', res['invoice_number']),
                _buildReceiptRow('Số tiền thanh toán:', '${res['amount_vnd']} đ'),
                _buildReceiptRow('Phương thức:', res['method']),
                _buildReceiptRow('Thời hạn kích hoạt:', '30 ngày kể từ hôm nay'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Bắt đầu trải nghiệm VIP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
