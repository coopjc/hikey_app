class HikePoint {
  const HikePoint({
    this.stretchIndex = 0,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.savedAt,
  });

  final int stretchIndex;
  final double latitude;
  final double longitude;
  final double elevation;
  final DateTime savedAt;

  factory HikePoint.fromJson(Map<String, dynamic> json) {
    final String savedAt = json['saved_at'] as String;

    return HikePoint(
      stretchIndex: json['stretch_index'] as int? ?? 0,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      elevation: (json['elevation'] as num).toDouble(),
      savedAt: DateTime.parse(savedAt),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'stretch_index': stretchIndex,
    'latitude': latitude,
    'longitude': longitude,
    'elevation': elevation,
    'saved_at': savedAt.toIso8601String(),
  };
}
