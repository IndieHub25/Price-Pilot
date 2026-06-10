import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/location_provider.dart';
import '../../../navigation/app_router.dart';
import '../../widgets/common/app_text_field.dart';

/// Main home screen with map placeholder, location inputs, and quick actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().fetchCurrentLocation();
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  void _comparePrices() {
    final locationProvider = context.read<LocationProvider>();

    if (_pickupController.text.isNotEmpty) {
      locationProvider.setPickupFromAddress(_pickupController.text.trim());
    }
    if (_dropoffController.text.isNotEmpty) {
      locationProvider.setDropoffFromAddress(_dropoffController.text.trim());
    }

    if (_pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both pickup and drop-off locations'),
        ),
      );
      return;
    }

    Navigator.pushNamed(context, AppRouter.rideComparison);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 36,
                      height: 36,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Pilot',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Consumer<LocationProvider>(
                          builder: (context, loc, _) {
                            return Text(
                              loc.currentLocation?.address ??
                                  'Detecting location...',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textHint),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.profile),
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return CircleAvatar(
                            backgroundColor: AppColors.backgroundSurface,
                            radius: 20,
                            child: Text(
                              auth.currentUser?.name.isNotEmpty == true
                                  ? auth.currentUser!.name[0].toUpperCase()
                                  : 'U',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Map placeholder
              Expanded(
                child: Stack(
                  children: [
                    // Map area
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Consumer<LocationProvider>(
                        builder: (context, loc, _) {
                          if (loc.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map_rounded,
                                  size: 64,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  loc.currentLocation != null
                                      ? 'Location detected'
                                      : 'Map will appear here',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                if (loc.currentLocation != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${loc.currentLocation!.latitude.toStringAsFixed(4)}, '
                                    '${loc.currentLocation!.longitude.toStringAsFixed(4)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppColors.textHint),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Location input card (overlay at bottom)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.overlay,
                              blurRadius: 20,
                              offset: Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Where are you going?',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 16),

                            // Pickup
                            AppTextField(
                              controller: _pickupController,
                              hintText: 'Pickup location',
                              prefixIcon: Icons.radio_button_checked_rounded,
                            ),
                            const SizedBox(height: 12),

                            // Dropoff
                            AppTextField(
                              controller: _dropoffController,
                              hintText: 'Drop-off location',
                              prefixIcon: Icons.location_on_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Compare button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _comparePrices,
                                  icon: const Icon(
                                    Icons.compare_arrows_rounded,
                                  ),
                                  label: const Text('Compare Prices'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _QuickAction(
                      icon: Icons.history_rounded,
                      label: 'History',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.bookingHistory,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.work_rounded,
                      label: 'Work',
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.bookmark_rounded,
                      label: 'Saved',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 1:
              Navigator.pushNamed(context, AppRouter.bookingHistory);
              break;
            case 2:
              Navigator.pushNamed(context, AppRouter.profile);
              break;
            case 3:
              Navigator.pushNamed(context, AppRouter.settings);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
