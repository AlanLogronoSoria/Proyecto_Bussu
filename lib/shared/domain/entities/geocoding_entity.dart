class GeocodingEntity {
  final double lat;
  final double lng;
  final String displayName;
  final String? street;
  final String? city;
  final String? district;
  final String? country;

  const GeocodingEntity({
    required this.lat,
    required this.lng,
    required this.displayName,
    this.street,
    this.city,
    this.district,
    this.country,
  });

  String get shortAddress {
    final parts = <String>[];
    if (street != null) parts.add(street!);
    if (city != null) parts.add(city!);
    if (country != null) parts.add(country!);
    return parts.isNotEmpty ? parts.join(', ') : displayName;
  }
}

class GeocodingResultEntity {
  final List<GeocodingEntity> places;
  final String query;

  const GeocodingResultEntity({required this.places, required this.query});
}
