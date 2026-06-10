/// Represents a driver assigned to a ride.
class DriverModel {
  final String id;
  final String name;
  final double rating;
  final String vehicleNumber;
  final String vehicleModel;
  final String vehicleColor;
  final String? phoneNumber;
  final String? photoUrl;
  final int totalTrips;

  const DriverModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.vehicleColor,
    this.phoneNumber,
    this.photoUrl,
    this.totalTrips = 0,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      vehicleNumber: json['vehicle_number'] as String,
      vehicleModel: json['vehicle_model'] as String,
      vehicleColor: json['vehicle_color'] as String,
      phoneNumber: json['phone_number'] as String?,
      photoUrl: json['photo_url'] as String?,
      totalTrips: json['total_trips'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'vehicle_number': vehicleNumber,
      'vehicle_model': vehicleModel,
      'vehicle_color': vehicleColor,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
      'total_trips': totalTrips,
    };
  }

  DriverModel copyWith({
    String? id,
    String? name,
    double? rating,
    String? vehicleNumber,
    String? vehicleModel,
    String? vehicleColor,
    String? phoneNumber,
    String? photoUrl,
    int? totalTrips,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      totalTrips: totalTrips ?? this.totalTrips,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DriverModel($name, rating: $rating)';
}
