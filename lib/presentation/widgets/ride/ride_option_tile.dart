import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/ride_model.dart';

/// Compact tile for a ride option, used in selection flows.
class RideOptionTile extends StatelessWidget {
  final RideModel ride;
  final bool isSelected;
  final VoidCallback? onTap;

  const RideOptionTile({
    super.key,
    required this.ride,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.backgroundSurface,
        child: Icon(
          _vehicleIcon(ride.vehicleType),
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        '${ride.service} ${ride.vehicleType}',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        '${ride.estimatedTimeMinutes} min away',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
      ),
      trailing: Text(
        '\u20B9${ride.price.toStringAsFixed(0)}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  IconData _vehicleIcon(String type) {
    switch (type) {
      case 'Bike':
        return Icons.two_wheeler_rounded;
      case 'Auto':
        return Icons.electric_rickshaw_rounded;
      case 'SUV':
      case 'Premium':
        return Icons.directions_car_filled_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }
}
