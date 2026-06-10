/// API-related constants and endpoint configuration.
class ApiConstants {
  ApiConstants._();

  // Google Maps
  static const String googleMapsBaseUrl =
      'https://maps.googleapis.com/maps/api';
  static const String directionsEndpoint = '$googleMapsBaseUrl/directions/json';
  static const String geocodeEndpoint = '$googleMapsBaseUrl/geocode/json';
  static const String placesEndpoint =
      '$googleMapsBaseUrl/place/autocomplete/json';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Response codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusServerError = 500;
}
