import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/supabase_service.dart';
import 'login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  StreamSubscription? _authSubscription;
  bool _notificationsEnabled = true;
  bool _uploadingImage = false;
  final ImagePicker _imagePicker = ImagePicker();
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    _authSubscription = AuthService.authStateChanges.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Show options dialog
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Photo Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      // Pick image
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() {
        _uploadingImage = true;
      });

      // Upload to Supabase Storage
      final user = AuthService.currentUser;
      if (user == null) throw Exception('User not logged in');

      final fileName =
          'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile = File(image.path);
      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage
      final storagePath = await SupabaseService.client.storage
          .from('profileImage')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Get public URL
      final imageUrl = SupabaseService.client.storage
          .from('profileImage')
          .getPublicUrl(fileName);

      // Check if profile exists, create or update
      final profileExists = await UserService.profileExists(user.id);
      if (profileExists) {
        await UserService.updateProfile(
          userId: user.id,
          profileImage: imageUrl,
        );
      } else {
        await UserService.createProfile(
          userId: user.id,
          email: user.email,
          name: user.name,
          profileImage: imageUrl,
        );
      }

      // Update auth metadata
      await SupabaseService.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': imageUrl}),
      );

      setState(() {
        _uploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _uploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show login prompt if not logged in
    if (!AuthService.isLoggedIn) {
      return _buildLoginPrompt(context);
    }

    final user = AuthService.currentUser!;
    final userName = user.name;
    final userEmail = user.email;

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, userName, userEmail),
            const SizedBox(height: 24),

            const SizedBox(height: 16),

            _buildMenuSection(context, [
              _MenuItem(
                icon: Icons.info_outline,
                title: 'About App',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ]),
            const SizedBox(height: 16),

            _buildMenuSection(context, [
              _MenuItem(
                icon: Icons.logout,
                title: 'Logout',
                titleColor: AppTheme.error,
                iconColor: AppTheme.error,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Login Required',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Please login to access your account',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ).then((result) {
                    if (result == true) {
                      setState(() {}); // Refresh to check login status
                    }
                  });
                },
                icon: Icons.login,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String userName,
    String userEmail,
  ) {
    return FutureBuilder(
      future: AuthService.getUserProfile(),
      builder: (context, snapshot) {
        final profileImageUrl = snapshot.data?.profileImage;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Profile Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl == null || profileImageUrl.isEmpty
                        ? Icon(Icons.person, size: 60, color: AppTheme.primary)
                        : _uploadingImage
                        ? const CircularProgressIndicator()
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _uploadingImage ? null : _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _uploadingImage ? Colors.grey : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _uploadingImage
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.camera_alt_outlined,
                                size: 20,
                                color: AppTheme.primary,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context, List<_MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Column(
          children: items
              .map(
                (item) => Column(
                  children: [
                    _buildMenuItem(context, item),
                    if (item != items.last) const Divider(height: 1),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (item.iconColor ?? AppTheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                color: item.iconColor ?? AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: item.titleColor),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (item.trailing != null) item.trailing!,
            if (item.trailing == null)
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                AuthService.logout();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete_outline, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              const Text('About Binner'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Binner',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'A cross-platform mobile application designed to tackle solid waste management challenges at Chiang Mai University.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Flutter project for 953464 — Mobile App Dev course',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Group Members:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 652115059 Xiaoyou Fung\n'
                  '• 662115019 Thippharake Na Chiengmai\n'
                  '• 662115022 Thanatchanan Kanjina\n'
                  '• 662115032 Pongpiphat Kalasuk\n'
                  '• 662115047 Watcharapong Wanna',
                  style: TextStyle(fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 16),
                const Text('© 2026 Pentagon Team (Binner createors)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.iconColor,
    this.trailing,
    this.onTap,
  });
}
