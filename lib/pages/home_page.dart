import 'dart:async';

import 'package:binner/pages/register_page.dart';
import 'package:binner/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/bin_card.dart';
import '../models/bin.dart';
import '../widgets/bin_map_view.dart';
import 'bin_details_page.dart';
import 'account_page.dart';
import 'add_bin_page.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import '../services/bin_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<String> _pages = ['map', 'add_bin', 'account'];
  List<Bin> _bins = [];
  bool _isLoadingBins = true;
  String? _binError;
  StreamSubscription<List<Bin>>? _binSubscription;
  StreamSubscription? _authSubscription;

  int get _adjustedIndex {
    if (_selectedIndex >= 1) return _selectedIndex - 1;
    return _selectedIndex;
  }

  @override
  void initState() {
    super.initState();
    // Refresh the page when returning from login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    _loadBins();
    _listenToBinStream();
    _authSubscription = AuthService.authStateChanges.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _binSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

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
            icon: const Icon(Icons.refresh),
            onPressed: _loadBins,
            tooltip: 'Refresh bins',
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
          _buildAddBinView(context),
          _buildAccountViewInline(context),
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
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_outlined),
            activeIcon: Icon(Icons.add),
            label: 'Add Bin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(BuildContext context) {
    final filteredBins = _filterBins();

    if (_isLoadingBins) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_binError != null && filteredBins.isEmpty) {
      return _buildNoBinsState(context, error: _binError);
    }

    if (filteredBins.isEmpty) {
      return _buildNoBinsState(context);
    }

    return Stack(
      children: [
        Positioned.fill(child: BinMapView(bins: filteredBins)),
        Positioned(right: 16, top: 16, child: _buildFilterChip(context)),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context) {
    final typeName = _selectedBinType == 'all'
        ? 'All Types'
        : AppTheme.getBinTypeName(_selectedBinType);
    return FilterChip(
      label: Text('Filter: $typeName'),
      selected: _selectedBinType != 'all',
      onSelected: (_) => _showFilterBottomSheet(context),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildNoBinsState(BuildContext context, {String? error}) {
    final message = error != null
        ? 'Unable to load data\n$error'
        : 'No bins in the system yet\nAdd a new bin to get started';
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              error != null ? Icons.wifi_off : Icons.delete_outline,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              CustomButton(
                text: 'Try Again',
                onPressed: () => _loadBins(),
                type: ButtonType.outline,
              ),
            ],
          ],
        ),
      ),
    );
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
              'No bins found',
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
                      '$count bins',
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

  Widget _buildAddBinView(BuildContext context) {
    return AddBinPage(
      onBinAdded: () {
        _loadBins();
      },
    );
  }

  Widget _buildAccountView(BuildContext context) {
    return const AccountPage();
  }

  // Simple account view for bottom nav
  Widget _buildAccountViewInline(BuildContext context) {
    // Show login prompt if not logged in
    if (!AuthService.isLoggedIn) {
      return _buildGuestAccountView(context);
    }

    final user = AuthService.currentUser;

    return _buildAccountView(context);
  }

  // Guest account view - shows login prompt
  Widget _buildGuestAccountView(BuildContext context) {
    return Center(
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
                Icons.person_outline,
                size: 64,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'User Account',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Login to access all features',
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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                ).then((result) {
                  if (result == true) {
                    setState(() {}); // Refresh to check login status
                  }
                });
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppTheme.primary),
        title: Text(title),
        trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }

  List<Bin> _filterBins() {
    if (_selectedBinType == 'all') {
      return _bins;
    }
    return _bins.where((bin) => bin.binType == _selectedBinType).toList();
  }

  Future<void> _loadBins() async {
    if (mounted) {
      setState(() {
        _isLoadingBins = true;
        _binError = null;
      });
    }
    try {
      final bins = await BinService.fetchBins();
      if (!mounted) return;
      setState(() {
        _bins = bins;
        _isLoadingBins = false;
        _binError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingBins = false;
        _binError = error.toString();
      });
    }
  }

  void _listenToBinStream() {
    _binSubscription = BinService.watchBins().listen(
      (bins) {
        if (!mounted) return;
        setState(() {
          _bins = bins;
          _isLoadingBins = false;
          _binError = null;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _binError = error.toString();
        });
      },
    );
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
                    'Filter by bin type',
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
                          type == 'all' ? 'All' : AppTheme.getBinTypeName(type),
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
                    text: 'Reset',
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
