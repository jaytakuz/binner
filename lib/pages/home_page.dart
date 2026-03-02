import 'package:binner/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/bin_card.dart';
import '../models/bin.dart';
import 'bin_details_page.dart';
import 'report_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Bin> _bins = [
    Bin(
      id: '1',
      name: 'ถังขยะ คณะวิทยาศาสตร์',
      location: 'คณะวิทยาศาสตร์ มหาวิทยาลัยเชียงใหม่',
      latitude: 18.8037,
      longitude: 98.9526,
      binType: 'green',
      status: BinStatus.available,
      capacity: 75,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Bin(
      id: '2',
      name: 'ถังขยะ หอพักนักศึกษา',
      location: 'หอพักนักศึกษา มหาวิทยาลัยเชียงใหม่',
      latitude: 18.8047,
      longitude: 98.9536,
      binType: 'yellow',
      status: BinStatus.halfFull,
      capacity: 50,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Bin(
      id: '3',
      name: 'ถังขยะ อาคารเรียนรวม',
      location: 'อาคารเรียนรวม มหาวิทยาลัยเชียงใหม่',
      latitude: 18.8057,
      longitude: 98.9546,
      binType: 'blue',
      status: BinStatus.available,
      capacity: 90,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Bin(
      id: '4',
      name: 'ถังขยะ โรงอาหารกลาง',
      location: 'โรงอาหารกลาง มหาวิทยาลัยเชียงใหม่',
      latitude: 18.8067,
      longitude: 98.9556,
      binType: 'green',
      status: BinStatus.almostFull,
      capacity: 20,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  String _selectedBinType = 'all';
  final List<String> _binTypes = [
    'all',
    'green',
    'yellow',
    'red',
    'blue',
    'orange',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMapView(context),
          _buildListView(context),
          _buildBinTypesView(context),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'แผนที่',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            activeIcon: Icon(Icons.list),
            label: 'รายการ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'ประเภท',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportPage()),
          );
        },
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('รายงาน'),
      ),
    );
  }

  Widget _buildMapView(BuildContext context) {
    return Stack(
      children: [
        // TODO: Replace with actual map widget (Google Maps / Mapbox)
        Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 100, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'แผนที่ถังขยะ',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'จะแสดงแผนที่จริงเมื่อเชื่อมต่อกับ Google Maps',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
        // Bin markers overlay (placeholder)
        ..._buildBinMarkers(context),
      ],
    );
  }

  List<Widget> _buildBinMarkers(BuildContext context) {
    // TODO: Replace with actual map markers
    final List<Widget> markers = [];
    for (int i = 0; i < _bins.length; i++) {
      final bin = _bins[i];
      markers.add(
        Positioned(
          left: 50 + (i * 80) % 280,
          top: 100 + (i * 100) % 400,
          child: GestureDetector(
            onTap: () => _showBinDetails(context, bin),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.getBinColor(bin.binType),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 24),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildListView(BuildContext context) {
    final filteredBins = _filterBins();

    if (filteredBins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ไม่พบถังขยะ',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredBins.length,
      itemBuilder: (context, index) {
        final bin = filteredBins[index];
        return BinCard(bin: bin, onTap: () => _showBinDetails(context, bin));
      },
    );
  }

  Widget _buildBinTypesView(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _binTypes.length - 1, // Exclude 'all'
      itemBuilder: (context, index) {
        final binType = _binTypes[index + 1];
        final color = AppTheme.getBinColor(binType);
        final count = _bins.where((b) => b.binType == binType).length;

        return Card(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedBinType = binType;
                _selectedIndex = 1; // Switch to list view
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.delete_outline, color: color, size: 32),
                    ),
                    const Spacer(),
                    Text(
                      AppTheme.getBinTypeName(binType),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count ถัง',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Bin> _filterBins() {
    if (_selectedBinType == 'all') {
      return _bins;
    }
    return _bins.where((bin) => bin.binType == _selectedBinType).toList();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'กรองตามประเภทถังขยะ',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _binTypes.map((type) {
                      final isSelected = _selectedBinType == type;
                      final color = type == 'all'
                          ? AppTheme.primary
                          : AppTheme.getBinColor(type);

                      return FilterChip(
                        label: Text(
                          type == 'all'
                              ? 'ทั้งหมด'
                              : AppTheme.getBinTypeName(type),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedBinType = type;
                          });
                          setState(() {
                            _selectedBinType = type;
                          });
                          Navigator.pop(context);
                        },
                        selectedColor: color.withOpacity(0.3),
                        checkmarkColor: color,
                        labelStyle: TextStyle(
                          color: isSelected ? color : AppTheme.textSecondary,
                        ),
                        side: BorderSide(
                          color: isSelected ? color : Colors.grey[300]!,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'รีเซ็ต',
                    onPressed: () {
                      setModalState(() {
                        _selectedBinType = 'all';
                      });
                      setState(() {
                        _selectedBinType = 'all';
                      });
                      Navigator.pop(context);
                    },
                    type: ButtonType.outline,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBinDetails(BuildContext context, Bin bin) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BinDetailsPage(bin: bin)),
    );
  }
}
