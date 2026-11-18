enum HikeStatus {
  active,
  paused,
  completed;

  factory HikeStatus.fromJson(String value) => switch (value) {
    'ACTIVE' => HikeStatus.active,
    'PAUSED' => HikeStatus.paused,
    'COMPLETED' => HikeStatus.completed,
    _ => throw FormatException('Unknown hike status: $value'),
  };

  String toJson() => switch (this) {
    HikeStatus.active => 'ACTIVE',
    HikeStatus.paused => 'PAUSED',
    HikeStatus.completed => 'COMPLETED',
  };

  String get label => switch (this) {
    HikeStatus.active => 'Active',
    HikeStatus.paused => 'Paused',
    HikeStatus.completed => 'Completed',
  };
}

class Hike {
  const Hike({
    required this.id,
    required this.name,
    this.notes,
    required this.status,
    this.durationMin = 0.0,
    this.distanceMiles = 0.0,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String? notes;
  final HikeStatus status;
  final double distanceMiles;
  final double durationMin;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Duration get duration => Duration(
    milliseconds: (durationMin * Duration.millisecondsPerMinute).round(),
  );

  factory Hike.fromJson(Map<String, dynamic> json) {
    return Hike(
      id: json['id'] as int,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      status: HikeStatus.fromJson(json['status'] as String),
      distanceMiles: (json['distance_miles'] as num).toDouble(),
      durationMin: (json['duration_min'] as num).toDouble(),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'notes': notes,
    'status': status.toJson(),
    'distance_miles': distanceMiles,
    'duration_min': durationMin,
    'completed_at': completedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated': updatedAt.toIso8601String(),
  };
}
