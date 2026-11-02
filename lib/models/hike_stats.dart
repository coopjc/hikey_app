class HikeStats {
  const HikeStats({required this.totalHikes, required this.totalDistanceMiles});

  final int totalHikes;
  final double totalDistanceMiles;

  factory HikeStats.fromJson(Map<String, dynamic> json) {
    return HikeStats(
      totalHikes: json['total_hikes'] as int,
      totalDistanceMiles: (json['total_distance'] as num).toDouble(),
    );
  }
}
