import 'package:flutter/material.dart';

class AffiliateStoreScreen extends StatefulWidget {
  const AffiliateStoreScreen({Key? key}) : super(key: key);

  @override
  State<AffiliateStoreScreen> createState() => _AffiliateStoreScreenState();
}

class _AffiliateStoreScreenState extends State<AffiliateStoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _affiliateProducts = [
    {
      'id': 'p1',
      'name': 'Dầu Neem Ép Lạnh Nguyên Chất Docneem 100ml',
      'brand': 'Docneem Vietnam',
      'price': '85.000 đ',
      'platform': 'Shopee Mall',
      'color': Colors.deepOrange,
      'badge': 'Safe-First Hữu Cơ',
      'desc': 'Trị sạch nhện đỏ, bọ trĩ, rệp sáp, an toàn tuyệt đối cho trẻ nhỏ và thú cưng.',
    },
    {
      'id': 'p2',
      'name': 'Chế Phẩm Vi Sinh Bacillus Subtilis Phòng Trị Nấm Lá',
      'brand': 'Bio-Green Agri',
      'price': '65.000 đ',
      'platform': 'Lazada Mall',
      'color': Colors.blue[800]!,
      'badge': 'Vi Sinh Đối Kháng',
      'desc': 'Xử lý triệt để phấn trắng, đốm đen hoa hồng mà không gây tồn dư độc hại.',
    },
    {
      'id': 'p3',
      'name': 'Sắt Chelate Fe-EDDHA 6% Chống Vàng Lá Gân Xanh',
      'brand': 'Agri-Care',
      'price': '45.000 đ',
      'platform': 'TikTok Shop',
      'color': Colors.black87,
      'badge': 'Vi Lượng Cao Cấp',
      'desc': 'Đặc trị hiện tượng thiếu sắt (Iron Chlorosis) cho kiểng lá, cẩm tú cầu, dành dành.',
    },
    {
      'id': 'p4',
      'name': 'Kéo Cắt Tỉa Cành Thép SK5 Nhật Bản Chống Gỉ',
      'brand': 'Sada Japan',
      'price': '120.000 đ',
      'platform': 'Shopee',
      'color': Colors.deepOrange,
      'badge': 'Dụng Cụ Tiệt Trùng',
      'desc': 'Lưỡi thép siêu bén giúp vết cắt ngọt, ngăn ngừa mầm bệnh vi khuẩn xâm nhập.',
    },
  ];

  final List<Map<String, dynamic>> _stores = [
    {
      'name': 'Nông Nghiệp Phố - Chi nhánh Cầu Giấy',
      'address': 'Số 10A Nguyễn Phong Sắc, Dịch Vọng, Cầu Giấy, Hà Nội',
      'distance': '1.2 km',
      'rating': 4.9,
      'phone': '0968 123 456',
      'isOpen': true,
    },
    {
      'name': 'Trạm Xanh Nông Nghiệp Đô Thị',
      'address': '84 Hoàng Hoa Thám, Ba Đình, Hà Nội',
      'distance': '3.5 km',
      'rating': 4.8,
      'phone': '0912 345 678',
      'isOpen': true,
    },
    {
      'name': 'Vườn Xanh Ban Công Sài Gòn',
      'address': '128 Nguyễn Đình Chiểu, Phường 6, Quận 3, TP.HCM',
      'distance': '4.1 km',
      'rating': 4.9,
      'phone': '0903 888 999',
      'isOpen': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Vật Tư & Cửa Hàng Nông Nghiệp'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Mua Online (Affiliate)'),
            Tab(icon: Icon(Icons.storefront_outlined), text: 'Cửa Hàng Gần Nhất'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOnlineAffiliateList(),
          _buildStoresList(),
        ],
      ),
    );
  }

  Widget _buildOnlineAffiliateList() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _affiliateProducts.length,
      itemBuilder: (context, index) {
        final p = _affiliateProducts[index];
        return Card(
          elevation: 1.5,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p['badge'],
                        style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (p['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p['platform'],
                        style: TextStyle(color: p['color'], fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  p['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  p['desc'],
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p['price'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đang mở liên kết sản phẩm trên ${p['platform']}...'),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Mua Ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoresList() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _stores.length,
      itemBuilder: (context, index) {
        final s = _stores[index];
        return Card(
          elevation: 1.5,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE8F5E9),
                  radius: 24,
                  child: const Icon(Icons.store, color: Color(0xFF1B5E20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['address'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' ${s['rating']} ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('• Cách đây ${s['distance']}', style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.directions_outlined, color: Color(0xFF0277BD)),
                  tooltip: 'Chỉ đường',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đang mở bản đồ chỉ đường đến ${s['name']}')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
