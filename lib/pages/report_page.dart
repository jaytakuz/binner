import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../models/report.dart';

class ReportPage extends StatefulWidget {
  final String? binId;

  const ReportPage({super.key, this.binId});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  ReportType _selectedReportType = ReportType.full;
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleImagePick() async {
    final List<XFile>? images = await _imagePicker.pickMultiImage();
    if (images != null && mounted) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _handleCameraPick() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null && mounted) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please attach at least 1 image')),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      // TODO: Implement submit logic
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Bin Problem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Type Selection
              _buildSectionTitle('Problem Type'),
              const SizedBox(height: 12),
              _buildReportTypeSelector(context),
              const SizedBox(height: 24),

              // Description
              _buildSectionTitle('Additional Details'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                hint: 'Describe the problem...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Images
              _buildSectionTitle('Attached Images (At least 1 image)'),
              const SizedBox(height: 12),
              _buildImageSection(context),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Submit Report',
                onPressed: _handleSubmit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
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

  Widget _buildReportTypeSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReportType.values.map((type) {
        final isSelected = _selectedReportType == type;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedReportType = type;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primary : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getReportTypeIcon(type),
                  size: 20,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  type.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.full:
        return Icons.delete_outline;
      case ReportType.damaged:
        return Icons.broken_image;
      case ReportType.missing:
        return Icons.remove_circle_outline;
      case ReportType.overflow:
        return Icons.publish;
      case ReportType.badOdor:
        return Icons.air;
      case ReportType.other:
        return Icons.help_outline;
    }
  }

  Widget _buildImageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Preview Grid
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _selectedImages[index].path,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 12),

        // Image Pick Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleImagePick,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Select Image'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleCameraPick,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
