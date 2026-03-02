import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AddBinPage extends StatefulWidget {
  const AddBinPage({super.key});

  @override
  State<AddBinPage> createState() => _AddBinPageState();
}

class _AddBinPageState extends State<AddBinPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  String _selectedBinType = 'green';
  bool _isSubmitting = false;

  final List<String> _binTypes = ['green', 'yellow', 'red', 'blue', 'orange'];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // TODO: Implement submit logic to save bin to database
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('เพิ่มถังขยะสำเร็จ')));
        }
      });
    }
  }

  void _getCurrentLocation() {
    // TODO: Implement get current location using geolocator
    setState(() {
      _latitudeController.text = '18.8037';
      _longitudeController.text = '98.9526';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ดึงตำแหน่งปัจจุบันสำเร็จ')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'เพิ่มถังขยะใหม่',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'กรอกข้อมูลถังขยะที่ต้องการเพิ่ม',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bin Name
            _buildSectionTitle('ชื่อถังขยะ'),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _nameController,
              hint: 'เช่น ถังขยะ คณะวิทยาศาสตร์',
              prefixIcon: Icons.delete_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกชื่อถังขยะ';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Location
            _buildSectionTitle('สถานที่ตั้ง'),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _locationController,
              hint: 'เช่น คณะวิทยาศาสตร์ มหาวิทยาลัยเชียงใหม่',
              prefixIcon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกสถานที่ตั้ง';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _latitudeController,
                    hint: 'ละติจูด',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.explore,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกละติจูด';
                      }
                      final lat = double.tryParse(value);
                      if (lat == null || lat < -90 || lat > 90) {
                        return 'ละติจูดไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _longitudeController,
                    hint: 'ลองจิจูด',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.explore,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกลองจิจูด';
                      }
                      final lng = double.tryParse(value);
                      if (lng == null || lng < -180 || lng > 180) {
                        return 'ลองจิจูดไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('ใช้ตำแหน่งปัจจุบัน'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bin Type
            _buildSectionTitle('ประเภทถังขยะ'),
            const SizedBox(height: 12),
            _buildBinTypeSelector(context),
            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: 'บันทึกถังขยะ',
              onPressed: _handleSubmit,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBinTypeSelector(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _binTypes.length,
      itemBuilder: (context, index) {
        final binType = _binTypes[index];
        final isSelected = _selectedBinType == binType;
        final color = AppTheme.getBinColor(binType);

        return InkWell(
          onTap: () {
            setState(() {
              _selectedBinType = binType;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.delete_outline, color: color, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTheme.getBinTypeName(binType),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? color : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
