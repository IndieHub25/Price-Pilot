import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/ride_model.dart';
import 'ride_card.dart';

/// Displays the full list of ride price comparisons, sorted by price.
class PriceComparisonList extends StatelessWidget {
  final List<RideModel> rides;
  final void Function(RideModel ride)? onRideSelected;

  const PriceComparisonList({
    super.key,
    required this.rides,
    this.onRideSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                'No rides available for this route.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
        return RideCard(
          ride: ride,
          isBestPrice: index == 0,
          onTap: () => onRideSelected?.call(ride),
        );
      },
    );
  }
}
