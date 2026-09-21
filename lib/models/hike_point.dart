class HikePoint {
  const HikePoint({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.savedAt,
  });

  final double latitude;
  final double longitude;
  final double elevation;
  final DateTime savedAt;

  factory HikePoint.fromJson(Map<String, dynamic> json) {
    final String savedAt = json['saved_at'] as String;

    return HikePoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      elevation: (json['elevation'] as num).toDouble(),
      savedAt: DateTime.parse(savedAt),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'latitude': latitude,
    'longitude': longitude,
    'elevation': elevation,
    'saved_at': savedAt.toIso8601String(),
  };
}
