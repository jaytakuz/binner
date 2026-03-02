import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    // Show login prompt if not logged in
    if (!AuthService.isLoggedIn) {
      return _buildLoginPrompt(context);
    }

    // TODO: Replace with actual user data
    final userName = 'ชื่อผู้ใช้';
    final userEmail = 'user@example.com';

    return Scaffold(
      appBar: AppBar(title: const Text('บัญชีของฉัน')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, userName, userEmail),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuSection(context, [
              _MenuItem(
                icon: Icons.person_outline,
                title: 'ข้อมูลส่วนตัว',
                onTap: () {
                  // TODO: Navigate to profile edit
                },
              ),
              _MenuItem(
                icon: Icons.history_outlined,
                title: 'ประวัติการรายงาน',
                onTap: () {
                  // TODO: Navigate to report history
                },
              ),
              _MenuItem(
                icon: Icons.favorite_outline,
                title: 'รายการโปรด',
                onTap: () {
                  // TODO: Navigate to favorites
                },
              ),
            ]),
            const SizedBox(height: 16),

            _buildMenuSection(context, [
              _MenuItem(
                icon: Icons.notifications_outlined,
                title: 'การแจ้งเตือน',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Toggle notifications
                  },
                ),
              ),
              _MenuItem(
                icon: Icons.language_outlined,
                title: 'ภาษา',
                subtitle: 'ไทย',
                onTap: () {
                  // TODO: Show language selection
                },
              ),
              _MenuItem(
                icon: Icons.help_outline,
                title: 'ช่วยเหลือ',
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
              _MenuItem(
                icon: Icons.info_outline,
                title: 'เกี่ยวกับแอพ',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ]),
            const SizedBox(height: 16),

            _buildMenuSection(context, [
              _MenuItem(
                icon: Icons.logout,
                title: 'ออกจากระบบ',
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
      appBar: AppBar(title: const Text('บัญชีของฉัน')),
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
                'ต้องเข้าสู่ระบบ',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'กรุณาเข้าสู่ระบบเพื่อเข้าถึงบัญชีของคุณ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'เข้าสู่ระบบ',
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Profile Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: AppTheme.primary),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: AppTheme.primary,
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Binner'),
              Text(
                'Version 1.0.0',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text('Bin finder application for Chiang Mai University'),
              const SizedBox(height: 16),
              const Text('© 2024 Binner Team'),
            ],
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
