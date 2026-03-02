import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/bin.dart';
import '../widgets/custom_button.dart';
import 'report_page.dart';

class BinDetailsPage extends StatelessWidget {
  final Bin bin;

  const BinDetailsPage({super.key, required this.bin});

  @override
  Widget build(BuildContext context) {
    final binColor = AppTheme.getBinColor(bin.binType);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(bin.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // TODO: Replace with actual image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [binColor, binColor.withOpacity(0.7)],
                      ),
                    ),
                  ),
                  if (bin.imageUrl != null)
                    Image.network(
                      bin.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [binColor, binColor.withOpacity(0.7)],
                            ),
                          ),
                        );
                      },
                    ),
                  Center(
                    child: Icon(
                      Icons.delete_outline,
                      size: 100,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Card
                  _buildLocationCard(context, binColor),
                  const SizedBox(height: 20),

                  // Status Card
                  _buildStatusCard(context, binColor),
                  const SizedBox(height: 20),

                  // Bin Type Info
                  _buildBinTypeInfo(context, binColor),
                  const SizedBox(height: 20),

                  // Capacity
                  _buildCapacityCard(context, binColor),
                  const SizedBox(height: 20),

                  // Description
                  if (bin.description != null && bin.description!.isNotEmpty)
                    _buildDescriptionCard(context),
                  const SizedBox(height: 20),

                  // Report Button
                  CustomButton(
                    text: 'รายงานปัญหา',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportPage(binId: bin.id),
                        ),
                      );
                    },
                    icon: Icons.report_problem_outlined,
                  ),
                  const SizedBox(height: 20),

                  // Navigate Button
                  CustomButton(
                    text: 'นำทางไปยังถังขยะ',
                    onPressed: () {
                      // TODO: Implement navigation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('เปิดแผนที่นำทาง...')),
                      );
                    },
                    type: ButtonType.outline,
                    icon: Icons.navigation_outlined,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, Color binColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: binColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_on_outlined, color: binColor),
                ),
                const SizedBox(width: 12),
                Text(
                  'ตำแหน่ง',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(bin.location, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              'พิกัด: ${bin.latitude.toStringAsFixed(6)}, ${bin.longitude.toStringAsFixed(6)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Color binColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: binColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info_outline, color: binColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สถานะ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(context, bin.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBinTypeInfo(BuildContext context, Color binColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: binColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.category_outlined, color: binColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ประเภทถังขยะ',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppTheme.getBinTypeName(bin.binType),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: binColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBinTypeDescription(context, bin.binType),
          ],
        ),
      ),
    );
  }

  Widget _buildBinTypeDescription(BuildContext context, String binType) {
    final descriptions = {
      'green':
          'ขยะเปื้อนอาหาร เช่น เศษอาหาร เปลือกผัก/ผลไม้ ของเปียกที่เน่าเสียได้',
      'yellow': 'ขยะพลาสติก เช่น ขวดน้ำพลาสติก หลอดฟัน กล่องพลาสติก',
      'red': 'ขยะอันตราย เช่น แบตเตอรี่ หลอดไฟฟลูออเรสเซนต์ ยาสีฟัน',
      'blue': 'ขยะกระดาษ เช่น กระดาษ นิตยสาร กล่องกระดาษ',
      'orange': 'ขยะทั่วไป เช่น ไม้ยางจุก ถุงยางอนามัย ซิงค์หิ้ว',
    };

    final description = descriptions[binType] ?? '-';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(description, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  Widget _buildCapacityCard(BuildContext context, Color binColor) {
    final capacityColor = bin.capacity > 50
        ? AppTheme.success
        : bin.capacity > 20
        ? AppTheme.warning
        : AppTheme.error;

    return Card(
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: capacityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline, color: capacityColor),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ความจุ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${bin.capacity}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: capacityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: bin.capacity / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(capacityColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'รายละเอียด',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bin.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, BinStatus status) {
    Color chipColor;
    IconData icon;

    switch (status) {
      case BinStatus.available:
        chipColor = AppTheme.success;
        icon = Icons.check_circle_outline;
        break;
      case BinStatus.halfFull:
        chipColor = Colors.amber[700]!;
        icon = Icons.remove_circle_outline;
        break;
      case BinStatus.almostFull:
        chipColor = AppTheme.warning;
        icon = Icons.warning_outlined;
        break;
      case BinStatus.full:
        chipColor = AppTheme.error;
        icon = Icons.block;
        break;
      case BinStatus.maintenance:
        chipColor = Colors.blue;
        icon = Icons.build_outlined;
        break;
      case BinStatus.damaged:
        chipColor = Colors.red[900]!;
        icon = Icons.dangerous_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: chipColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
