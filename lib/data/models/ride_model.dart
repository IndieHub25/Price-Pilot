/// Represents a single ride option from a ride-hailing service.
class RideModel {
  final String id;
  final String service;
  final String vehicleType;
  final double price;
  final int estimatedTimeMinutes;
  final double surgeMultiplier;
  final String? iconUrl;
  final bool isAvailable;
  final int? seatingCapacity;

  const RideModel({
    required this.id,
    required this.service,
    required this.vehicleType,
    required this.price,
    required this.estimatedTimeMinutes,
    this.surgeMultiplier = 1.0,
    this.iconUrl,
    this.isAvailable = true,
    this.seatingCapacity,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String,
      service: json['service'] as String,
      vehicleType: json['vehicle_type'] as String,
      price: (json['price'] as num).toDouble(),
      estimatedTimeMinutes: json['estimated_time_minutes'] as int,
      surgeMultiplier: (json['surge_multiplier'] as num?)?.toDouble() ?? 1.0,
      iconUrl: json['icon_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      seatingCapacity: json['seating_capacity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'vehicle_type': vehicleType,
      'price': price,
      'estimated_time_minutes': estimatedTimeMinutes,
      'surge_multiplier': surgeMultiplier,
      'icon_url': iconUrl,
      'is_available': isAvailable,
      'seating_capacity': seatingCapacity,
    };
  }

  /// Whether surge pricing is currently active.
  bool get hasSurge => surgeMultiplier > 1.0;

  /// The original price before surge was applied.
  double get priceBeforeSurge => hasSurge ? price / surgeMultiplier : price;

  RideModel copyWith({
    String? id,
    String? service,
    String? vehicleType,
    double? price,
    int? estimatedTimeMinutes,
    double? surgeMultiplier,
    String? iconUrl,
    bool? isAvailable,
    int? seatingCapacity,
  }) {
    return RideModel(
      id: id ?? this.id,
      service: service ?? this.service,
      vehicleType: vehicleType ?? this.vehicleType,
      price: price ?? this.price,
      estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
      iconUrl: iconUrl ?? this.iconUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'RideModel($service $vehicleType: Rs.$price, ETA: ${estimatedTimeMinutes}min)';
}
