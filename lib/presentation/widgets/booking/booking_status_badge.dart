import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// A colored badge that displays the booking status.
class BookingStatusBadge extends StatelessWidget {
  final String status;

  const BookingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _statusLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (status) {
      case AppConstants.statusCompleted:
        return AppColors.success;
      case AppConstants.statusCancelled:
        return AppColors.error;
      case AppConstants.statusInProgress:
      case AppConstants.statusEnRoute:
        return AppColors.accent;
      case AppConstants.statusConfirmed:
      case AppConstants.statusArrived:
        return AppColors.info;
      case AppConstants.statusPending:
      default:
        return AppColors.warning;
    }
  }

  String get _statusLabel {
    switch (status) {
      case AppConstants.statusPending:
        return 'Pending';
      case AppConstants.statusConfirmed:
        return 'Confirmed';
      case AppConstants.statusEnRoute:
        return 'En Route';
      case AppConstants.statusArrived:
        return 'Arrived';
      case AppConstants.statusInProgress:
        return 'In Progress';
      case AppConstants.statusCompleted:
        return 'Completed';
      case AppConstants.statusCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }
}
