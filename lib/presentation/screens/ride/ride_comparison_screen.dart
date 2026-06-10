import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/location_utils.dart';
import '../../../data/providers/ride_provider.dart';
import '../../../data/providers/location_provider.dart';
import '../../../data/providers/booking_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/ride_model.dart';
import '../../../navigation/app_router.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/ride/price_comparison_list.dart';

/// Displays ride price comparisons for the selected route.
class RideComparisonScreen extends StatefulWidget {
  const RideComparisonScreen({super.key});

  @override
  State<RideComparisonScreen> createState() => _RideComparisonScreenState();
}

class _RideComparisonScreenState extends State<RideComparisonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRides());
  }

  void _fetchRides() {
    final locationProvider = context.read<LocationProvider>();
    if (locationProvider.pickupLocation != null &&
        locationProvider.dropoffLocation != null) {
      context.read<RideProvider>().fetchRides(
        pickup: locationProvider.pickupLocation!,
        dropoff: locationProvider.dropoffLocation!,
      );
    }
  }

  void _onRideSelected(RideModel ride) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => _BookingConfirmSheet(ride: ride),
    );

    if (confirmed == true && mounted) {
      final locationProvider = context.read<LocationProvider>();
      final authProvider = context.read<AuthProvider>();
      final bookingProvider = context.read<BookingProvider>();

      final distanceKm = LocationUtils.haversineDistance(
        locationProvider.pickupLocation!.latitude,
        locationProvider.pickupLocation!.longitude,
        locationProvider.dropoffLocation!.latitude,
        locationProvider.dropoffLocation!.longitude,
      );

      await bookingProvider.createBooking(
        userId: authProvider.currentUser!.id,
        pickup: locationProvider.pickupLocation!,
        dropoff: locationProvider.dropoffLocation!,
        service: ride.service,
        vehicleType: ride.vehicleType,
        price: ride.price,
        distanceKm: distanceKm,
        durationMinutes: ride.estimatedTimeMinutes,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.bookingConfirmation);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Prices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<RideProvider, LocationProvider>(
        builder: (context, rideProvider, locationProvider, _) {
          if (rideProvider.isLoading) {
            return const LoadingIndicator(
              message: 'Finding the best rides for you...',
            );
          }

          if (rideProvider.error != null) {
            return AppErrorWidget(
              message: rideProvider.error!,
              onRetry: _fetchRides,
            );
          }

          final distanceKm =
              locationProvider.pickupLocation != null &&
                  locationProvider.dropoffLocation != null
              ? LocationUtils.haversineDistance(
                  locationProvider.pickupLocation!.latitude,
                  locationProvider.pickupLocation!.longitude,
                  locationProvider.dropoffLocation!.latitude,
                  locationProvider.dropoffLocation!.longitude,
                )
              : 0.0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route summary
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      _RouteRow(
                        icon: Icons.radio_button_checked_rounded,
                        iconColor: AppColors.success,
                        text:
                            locationProvider.pickupLocation?.address ??
                            'Pickup',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 11),
                        child: Container(
                          width: 2,
                          height: 20,
                          color: AppColors.divider,
                        ),
                      ),
                      _RouteRow(
                        icon: Icons.location_on_rounded,
                        iconColor: AppColors.error,
                        text:
                            locationProvider.dropoffLocation?.address ??
                            'Drop-off',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _InfoChip(
                            icon: Icons.straighten_rounded,
                            label: LocationUtils.formatDistance(distanceKm),
                          ),
                          _InfoChip(
                            icon: Icons.local_offer_rounded,
                            label: '${rideProvider.allRides.length} options',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Filter chips
                if (rideProvider.availableVehicleTypes.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: rideProvider.selectedVehicleFilter == null,
                          onSelected: (_) =>
                              rideProvider.setVehicleFilter(null),
                        ),
                        const SizedBox(width: 8),
                        ...rideProvider.availableVehicleTypes.map(
                          (type) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(type),
                              selected:
                                  rideProvider.selectedVehicleFilter == type,
                              onSelected: (_) =>
                                  rideProvider.setVehicleFilter(type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Ride list
                PriceComparisonList(
                  rides: rideProvider.rides,
                  onRideSelected: _onRideSelected,
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _BookingConfirmSheet extends StatelessWidget {
  final RideModel ride;

  const _BookingConfirmSheet({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Confirm Booking',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ride.service} ${ride.vehicleType}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '\u20B9${ride.price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ETA: ${ride.estimatedTimeMinutes} minutes',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
