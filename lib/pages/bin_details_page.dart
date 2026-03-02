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

                  // Bin Type Info
                  _buildBinTypeInfo(context, binColor),
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
                        const SnackBar(content: Text('Opening navigation map...')),
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
}
