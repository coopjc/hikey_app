String formatMiles(double miles) => miles.toStringAsFixed(miles < 10 ? 2 : 1);

String formatDuration(Duration duration) {
  if (duration.inMinutes < 1) return '${duration.inSeconds}s';
  if (duration.inHours < 1) return '${duration.inMinutes}m';
  return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
}
