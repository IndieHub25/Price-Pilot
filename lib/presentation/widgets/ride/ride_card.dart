import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/ride_model.dart';
import '../../../core/utils/price_utils.dart';

/// Displays a single ride option in the comparison list.
class RideCard extends StatelessWidget {
  final RideModel ride;
  final bool isBestPrice;
  final VoidCallback? onTap;

  const RideCard({
    super.key,
    required this.ride,
    this.isBestPrice = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isBestPrice ? AppColors.cardGradient : null,
          color: isBestPrice ? null : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBestPrice ? AppColors.success : AppColors.divider,
            width: isBestPrice ? 1.5 : 1,
          ),
          boxShadow: isBestPrice
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Service icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getServiceColor(
                      ride.service,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getServiceIcon(ride.service),
                      color: _getServiceColor(ride.service),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Service and vehicle info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ride.service,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ride.vehicleType,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ride.estimatedTimeMinutes} min',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textHint),
                          ),
                          if (ride.seatingCapacity != null) ...[
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${ride.seatingCapacity}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textHint),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      PriceUtils.format(ride.price),
                      style: AppTypography.monoMedium.copyWith(
                        color: isBestPrice
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (ride.hasSurge) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${ride.surgeMultiplier.toStringAsFixed(1)}x surge',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            if (isBestPrice) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Best Price Available',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getServiceColor(String service) {
    switch (service) {
      case 'Uber':
        return AppColors.textPrimary;
      case 'Ola':
        return AppColors.ola;
      case 'Rapido':
        return AppColors.rapido;
      default:
        return AppColors.primary;
    }
  }

  IconData _getServiceIcon(String service) {
    switch (service) {
      case 'Uber':
        return Icons.local_taxi_rounded;
      case 'Ola':
        return Icons.directions_car_rounded;
      case 'Rapido':
        return Icons.two_wheeler_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }
}
