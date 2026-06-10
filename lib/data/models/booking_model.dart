import 'location_model.dart';

/// Represents a completed or in-progress ride booking.
class BookingModel {
  final String id;
  final String userId;
  final LocationModel pickup;
  final LocationModel dropoff;
  final String service;
  final String vehicleType;
  final double price;
  final double? distanceKm;
  final int? durationMinutes;
  final String status;
  final DateTime bookedAt;
  final DateTime? completedAt;
  final String? driverId;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.pickup,
    required this.dropoff,
    required this.service,
    required this.vehicleType,
    required this.price,
    this.distanceKm,
    this.durationMinutes,
    required this.status,
    required this.bookedAt,
    this.completedAt,
    this.driverId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pickup: LocationModel(
        latitude: (json['pickup_lat'] as num).toDouble(),
        longitude: (json['pickup_lng'] as num).toDouble(),
        address: json['pickup_address'] as String?,
      ),
      dropoff: LocationModel(
        latitude: (json['dropoff_lat'] as num).toDouble(),
        longitude: (json['dropoff_lng'] as num).toDouble(),
        address: json['dropoff_address'] as String?,
      ),
      service: json['service'] as String,
      vehicleType: json['vehicle_type'] as String,
      price: (json['price'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
      status: json['status'] as String,
      bookedAt: DateTime.parse(json['booked_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      driverId: json['driver_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pickup_lat': pickup.latitude,
      'pickup_lng': pickup.longitude,
      'pickup_address': pickup.address,
      'dropoff_lat': dropoff.latitude,
      'dropoff_lng': dropoff.longitude,
      'dropoff_address': dropoff.address,
      'service': service,
      'vehicle_type': vehicleType,
      'price': price,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'status': status,
      'booked_at': bookedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'driver_id': driverId,
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    LocationModel? pickup,
    LocationModel? dropoff,
    String? service,
    String? vehicleType,
    double? price,
    double? distanceKm,
    int? durationMinutes,
    String? status,
    DateTime? bookedAt,
    DateTime? completedAt,
    String? driverId,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      service: service ?? this.service,
      vehicleType: vehicleType ?? this.vehicleType,
      price: price ?? this.price,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      bookedAt: bookedAt ?? this.bookedAt,
      completedAt: completedAt ?? this.completedAt,
      driverId: driverId ?? this.driverId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BookingModel($id: $service $vehicleType, status: $status)';
}
