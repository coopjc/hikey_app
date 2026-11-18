String formatName(DateTime startedAt) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final int hour = startedAt.hour;

  final String partOfDay = switch (hour) {
    >= 5 && < 12 => 'Morning',
    >= 12 && < 17 => 'Afternoon',
    >= 17 && < 21 => 'Evening',
    _ => 'Night',
  };

  return '$partOfDay hike · ${months[startedAt.month - 1]} ${startedAt.day}';
}

String formatMiles(double miles) => miles.toStringAsFixed(miles < 10 ? 2 : 1);

String formatDuration(Duration duration) {
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes.remainder(Duration.minutesPerHour);
  final int seconds = duration.inSeconds.remainder(Duration.secondsPerMinute);

  if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
  if (minutes > 0) return '${minutes}m ${seconds}s';
  return '${seconds}s';
}

String formatElapsed(Duration elapsed) {
  final String seconds = elapsed.inSeconds
      .remainder(Duration.secondsPerMinute)
      .toString()
      .padLeft(2, '0');

  if (elapsed.inHours < 1) return '${elapsed.inMinutes}:$seconds';

  final String minutes = elapsed.inMinutes
      .remainder(Duration.minutesPerHour)
      .toString()
      .padLeft(2, '0');

  return '${elapsed.inHours}:$minutes:$seconds';
}

String formatPace(double miles, Duration elapsed) {
  const double minPaceMiles = 0.05;
  const int maxPaceMinutes = 90;

  if (miles < minPaceMiles || elapsed <= Duration.zero) return '—';

  final Duration pace = Duration(
    milliseconds: (elapsed.inMilliseconds / miles).round(),
  );

  if (pace.inMinutes >= maxPaceMinutes) return '—';

  final String seconds = pace.inSeconds
      .remainder(Duration.secondsPerMinute)
      .toString()
      .padLeft(2, '0');

  return '${pace.inMinutes}:$seconds';
}
