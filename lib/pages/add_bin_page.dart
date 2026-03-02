import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import '../services/bin_service.dart';

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
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _submissionError;
  StreamSubscription? _authSubscription;

  String _selectedBinType = 'green';
  bool _isSubmitting = false;

  final List<String> _binTypes = ['green', 'yellow', 'red', 'blue', 'orange'];

  @override
  void dispose() {
    _authSubscription?.cancel();
    _nameController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authSubscription = AuthService.authStateChanges.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1440,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!AuthService.isLoggedIn) {
      await _promptLogin();
      return;
    }

    final user = AuthService.currentUser!;
    final latitude = double.parse(_latitudeController.text.trim());
    final longitude = double.parse(_longitudeController.text.trim());
    final description = _descriptionController.text.trim();

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      await BinService.createBin(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        binType: _selectedBinType,
        addedByName: user.name,
        addedById: user.id,
        description: description.isEmpty ? null : description,
        imageFile: _selectedImage,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _selectedImage = null;
        _selectedBinType = 'green';
      });
      _formKey.currentState!.reset();
      _nameController.clear();
      _locationController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มถังขยะเรียบร้อยแล้ว')),
      );
    } catch (error) {
      setState(() {
        _isSubmitting = false;
        _submissionError = error.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเพิ่มถังขยะได้: $error')),
      );
    }
  }

  void _getCurrentLocation() {
    // TODO: Implement get current location using geolocator
    setState(() {
      _latitudeController.text = '18.8037';
      _longitudeController.text = '98.9526';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current location fetched successfully')),
    );
  }

  Future<void> _promptLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    if (mounted) {
      setState(() {});
    }
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

            if (!AuthService.isLoggedIn)
              _buildLoginReminder(context)
            else
              _buildAdderInfoCard(context),
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

            // Description
            _buildSectionTitle('รายละเอียดเพิ่มเติม'),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _descriptionController,
              hint: 'อธิบายลักษณะถังขยะโดยย่อ',
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกรายละเอียดสั้น ๆ';
                }
                if (value.length < 10) {
                  return 'รายละเอียดควรมีอย่างน้อย 10 ตัวอักษร';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Image Upload
            _buildSectionTitle('อัปโหลดรูปภาพถังขยะ'),
            const SizedBox(height: 12),
            _buildImageUploader(context),
            const SizedBox(height: 24),

            // Bin Type
            _buildSectionTitle('ประเภทถังขยะ'),
            const SizedBox(height: 12),
            _buildBinTypeSelector(context),
            const SizedBox(height: 32),

            if (_submissionError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _submissionError!,
                  style: TextStyle(color: AppTheme.error),
                ),
              ),

            // Submit Button
            CustomButton(
              text: 'บันทึกถังขยะ',
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (!AuthService.isLoggedIn) {
                        await _promptLogin();
                        return;
                      }
                      await _handleSubmit();
                    },
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginReminder(BuildContext context) {
    return Card(
      color: AppTheme.primary.withOpacity(0.05),
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
                    color: AppTheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'เข้าสู่ระบบเพื่อเพิ่มถังขยะ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'ข้อมูลผู้เพิ่มถังขยะจะถูกใช้เป็นผู้รายงาน',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'เข้าสู่ระบบ',
              onPressed: () async => _promptLogin(),
              icon: Icons.login,
              type: ButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdderInfoCard(BuildContext context) {
    final user = AuthService.currentUser!;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppTheme.primaryDark),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Chip(
          label: const Text('ผู้รายงาน'),
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          labelStyle: const TextStyle(color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildImageUploader(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _pickImage(ImageSource.gallery),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.grey[50],
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'แตะเพื่อเลือกรูปภาพ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'รองรับไฟล์ JPG, PNG',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('ถ่ายภาพ'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('เลือกรูป'),
              ),
            ),
          ],
        ),
      ],
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
