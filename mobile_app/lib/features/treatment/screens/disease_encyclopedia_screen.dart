import 'package:flutter/material.dart';

class DiseaseEncyclopediaScreen extends StatefulWidget {
  const DiseaseEncyclopediaScreen({super.key});

  @override
  State<DiseaseEncyclopediaScreen> createState() => _DiseaseEncyclopediaScreenState();
}

class _DiseaseEncyclopediaScreenState extends State<DiseaseEncyclopediaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';

  // Dữ liệu bách khoa toàn thư cây cảnh đô thị (US-082)
  final List<Map<String, dynamic>> _diseases = [
    {
      'id': 'PM_01',
      'name': 'Bệnh Phấn Trắng',
      'sci_name': 'Erysiphe / Podosphaera spp.',
      'category': 'Nấm',
      'target_plants': 'Hoa hồng, Cúc họa mi, Dưa chuột ban công',
      'symptoms': 'Lớp bột màu trắng như phấn phủ khắp bề mặt lá non và chồi, làm lá xoăn lại và khô héo.',
      'cause': 'Độ ẩm không khí cao kết hợp bóng râm thiếu sáng, đọng sương đêm.',
      'remedy': 'Baking soda (5g) + Dầu ăn (5ml) / 1L nước, hoặc vi sinh Bacillus subtilis.',
      'prevention': 'Tăng thông gió ban công, tưới gốc không tưới lá lúc chiều tối.',
    },
    {
      'id': 'BL_02',
      'name': 'Bệnh Đốm Đen Hoa Hồng',
      'sci_name': 'Diplocarpon rosae',
      'category': 'Nấm',
      'target_plants': 'Hoa hồng bụi, hoa hồng leo',
      'symptoms': 'Đốm tròn màu đen hoặc nâu sẫm rìa tua rua viền vàng, lá vàng và rụng hàng loạt từ dưới lên.',
      'cause': 'Nước đọng trên lá quá 7 tiếng, nhiệt độ 20-27 độ C, giọt bắn mưa.',
      'remedy': 'Cắt sạch lá rụng dưới gốc; phun Dầu Neem lạnh 5ml/L nước hoặc dịch tỏi ớt.',
      'prevention': 'Rải mùn phủ mặt chậu để tránh bào tử nấm bắn ngược khi tưới.',
    },
    {
      'id': 'SM_03',
      'name': 'Nhện Đỏ Hại Lá',
      'sci_name': 'Tetranychus urticae',
      'category': 'Côn trùng / Sâu hại',
      'target_plants': 'Hoa hồng, Mai vàng, Trầu bà, Xương rồng',
      'symptoms': 'Mặt dưới lá có màng tơ mỏng, chấm li ti chuyển động, lá bạc màu lốm đốm xám.',
      'cause': 'Thời tiết hanh khô, nắng gắt, thiếu độ ẩm không khí.',
      'remedy': 'Phun vòi nước áp lực cao rửa mặt dưới lá; phun cồn 70 độ pha loãng 1:3 hoặc dầu Neem.',
      'prevention': 'Tăng độ ẩm quanh chậu cây, phun sương vào buổi sáng sớm.',
    },
    {
      'id': 'MB_04',
      'name': 'Rệp Sáp Trắng Bông',
      'sci_name': 'Pseudococcidae',
      'category': 'Côn trùng / Sâu hại',
      'target_plants': 'Cây Kim Tiền, Lưỡi Hổ, Hoa giấy, Cẩm Cù',
      'symptoms': 'Đám bông sáp trắng mềm bám chặt ở nách lá, cuống lá, tiết dịch mật ngọt thu hút kiến đen.',
      'cause': 'Cây để nơi kín gió, mật độ dày đặc, lây qua đất trồng cũ.',
      'remedy': 'Dùng tăm bông nhúng cồn lau cơ học; xịt dung dịch nước rửa chén 2ml + cồn 5ml/L nước.',
      'prevention': 'Kiểm tra kỹ nách lá cây mới mua về trước khi xếp chung vườn.',
    },
    {
      'id': 'ID_05',
      'name': 'Vàng Lá Thiếu Sắt (Iron Chlorosis)',
      'sci_name': 'Nutrient Deficiency - Iron',
      'category': 'Thiếu hụt dinh dưỡng',
      'target_plants': 'Dành dành (Gardenia), Cẩm tú cầu, Tùng la hán',
      'symptoms': 'Lá non chuyển vàng nhạt trong khi toàn bộ gân lá vẫn giữ màu xanh đậm đối xứng.',
      'cause': 'Đất kiềm hóa (pH > 7.0), tưới nước máy nhiều vôi hoặc rễ bị úng nước lâu ngày.',
      'remedy': 'Bổ sung Sắt Chelate Fe-EDDHA 1g/L nước tưới gốc, phun phân bón vi lượng qua lá.',
      'prevention': 'Dùng giấm gạo pha loãng (2ml/L) định kỳ chỉnh pH đất về khoảng 5.5 - 6.5.',
    },
    {
      'id': 'RR_06',
      'name': 'Bệnh Thối Rễ Do Úng Nước',
      'sci_name': 'Pythium / Phytophthora spp.',
      'category': 'Nấm rễ & Môi trường',
      'target_plants': 'Sen đá, Xương rồng, Monstera lá xẻ, Kim Ngân',
      'symptoms': 'Thân gốc nhũn đen có mùi hôi, lá mềm rũ rượi dù đất vẫn ướt sũng.',
      'cause': 'Đất trồng giữ nước quá lâu, đáy chậu không có lỗ thoát nước.',
      'remedy': 'Nhổ cây, gọt bỏ rễ thối đen ngâm cồn/hydrogen peroxide 3% loãng, để khô 2 ngày rồi trồng lại.',
      'prevention': 'Trộn thêm đá perlite/pumice tỷ lệ 40-50% trong giá thể trồng chậu.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _diseases.where((d) {
      final matchesCat = _selectedCategory == 'Tất cả' || d['category'] == _selectedCategory;
      final query = _searchController.text.toLowerCase();
      final matchesQuery = query.isEmpty ||
          d['name'].toString().toLowerCase().contains(query) ||
          d['target_plants'].toString().toLowerCase().contains(query) ||
          d['symptoms'].toString().toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Bách Khoa Bệnh Cây Đô Thị'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên bệnh, cây trồng, triệu chứng...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          // Lọc danh mục
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['Tất cả', 'Nấm', 'Côn trùng / Sâu hại', 'Thiếu hụt dinh dưỡng', 'Nấm rễ & Môi trường'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                    },
                    selectedColor: const Color(0xFFE8F5E9),
                    checkmarkColor: const Color(0xFF2E7D32),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF1B5E20) : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Danh sách các bệnh
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final d = filtered[index];
                return Card(
                  elevation: 1.5,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE8F5E9),
                      child: Icon(
                        d['category'] == 'Nấm'
                            ? Icons.bubble_chart
                            : (d['category'] == 'Côn trùng / Sâu hại' ? Icons.pest_control : Icons.eco),
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    title: Text(
                      d['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                    ),
                    subtitle: Text(
                      '${d['sci_name']} • Cây: ${d['target_plants']}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            _buildInfoSection('Triệu chứng nhận biết:', d['symptoms'], Icons.visibility_outlined, Colors.blue),
                            const SizedBox(height: 8),
                            _buildInfoSection('Nguyên nhân:', d['cause'], Icons.help_outline, Colors.amber[800]!),
                            const SizedBox(height: 8),
                            _buildInfoSection('Phác đồ xử lý Safe-First:', d['remedy'], Icons.health_and_safety, const Color(0xFF2E7D32)),
                            const SizedBox(height: 8),
                            _buildInfoSection('Phòng ngừa dài hạn:', d['prevention'], Icons.shield_outlined, Colors.purple),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
              children: [
                TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
