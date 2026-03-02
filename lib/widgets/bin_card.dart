import 'package:flutter/material.dart';
import '../models/bin.dart';
import '../themes/app_theme.dart';

class BinCard extends StatelessWidget {
  final Bin bin;
  final VoidCallback? onTap;
  final VoidCallback? onReport;

  const BinCard({super.key, required this.bin, this.onTap, this.onReport});

  @override
  Widget build(BuildContext context) {
    final binColor = AppTheme.getBinColor(bin.binType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Bin Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: binColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_outline, color: binColor, size: 32),
              ),
              const SizedBox(width: 16),
              // Bin Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bin.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bin.location,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(context, bin.status),
                        const SizedBox(width: 8),
                        _buildTypeChip(context, bin.binType, binColor),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, BinStatus status) {
    Color chipColor;
    String label;

    switch (status) {
      case BinStatus.available:
        chipColor = AppTheme.success;
        label = status.displayName;
        break;
      case BinStatus.halfFull:
        chipColor = Colors.amber[700]!;
        label = status.displayName;
        break;
      case BinStatus.almostFull:
        chipColor = AppTheme.warning;
        label = status.displayName;
        break;
      case BinStatus.full:
        chipColor = AppTheme.error;
        label = status.displayName;
        break;
      case BinStatus.maintenance:
        chipColor = Colors.blue;
        label = status.displayName;
        break;
      case BinStatus.damaged:
        chipColor = Colors.red[900]!;
        label = status.displayName;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String binType, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        AppTheme.getBinTypeName(binType),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
