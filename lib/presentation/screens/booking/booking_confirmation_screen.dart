import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/price_utils.dart';
import '../../../data/providers/booking_provider.dart';
import '../../../navigation/app_router.dart';

/// Confirmation screen displayed after a booking is created.
class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Consumer<BookingProvider>(
            builder: (context, bookingProvider, _) {
              final booking = bookingProvider.activeBooking;

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success checkmark
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 56,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Booking Confirmed',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your ride has been successfully booked',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (booking != null) ...[
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            children: [
                              _DetailRow(
                                label: 'Service',
                                value:
                                    '${booking.service} ${booking.vehicleType}',
                              ),
                              const SizedBox(height: 12),
                              _DetailRow(
                                label: 'Price',
                                value: PriceUtils.format(booking.price),
                                valueColor: AppColors.success,
                              ),
                              const SizedBox(height: 12),
                              _DetailRow(
                                label: 'Pickup',
                                value: booking.pickup.address ?? 'N/A',
                              ),
                              const SizedBox(height: 12),
                              _DetailRow(
                                label: 'Drop-off',
                                value: booking.dropoff.address ?? 'N/A',
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.rideTracking,
                            );
                          },
                          child: const Text('Track Your Ride'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            bookingProvider.clearActiveBooking();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRouter.home,
                              (route) => false,
                            );
                          },
                          child: const Text('Back to Home'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
