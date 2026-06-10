import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/booking_provider.dart';
import '../../../navigation/app_router.dart';

/// Simulated ride tracking screen with driver info and progress.
class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Ride')),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          final booking = bookingProvider.activeBooking;
          if (booking == null) {
            return const Center(child: Text('No active ride'));
          }

          return Column(
            children: [
              // Map placeholder
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return Opacity(
                          opacity: 0.5 + (_pulseController.value * 0.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.navigation_rounded,
                                size: 64,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tracking in progress...',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Ride info card
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.backgroundSurface,
                            radius: 24,
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver Assigned',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                                Text(
                                  '${booking.service} ${booking.vehicleType}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.textHint),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\u20B9${booking.price.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _InfoItem(
                            icon: Icons.access_time_rounded,
                            label: booking.durationMinutes != null
                                ? '${booking.durationMinutes} min'
                                : '--',
                            subtitle: 'ETA',
                          ),
                          _InfoItem(
                            icon: Icons.straighten_rounded,
                            label: booking.distanceKm != null
                                ? '${booking.distanceKm!.toStringAsFixed(1)} km'
                                : '--',
                            subtitle: 'Distance',
                          ),
                          _InfoItem(
                            icon: Icons.info_outline_rounded,
                            label: booking.status,
                            subtitle: 'Status',
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await bookingProvider.updateStatus(
                              booking.id,
                              AppConstants.statusCompleted,
                            );
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRouter.home,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Complete Ride'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textHint, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary),
        ),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}
