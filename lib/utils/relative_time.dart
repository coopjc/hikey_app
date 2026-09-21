String relativeLabel(DateTime dateTime) {
  final Duration diff = DateTime.now().difference(dateTime);
  if (diff.inDays >= 14) return '${(diff.inDays / 7).floor()} weeks ago';
  if (diff.inDays >= 7) return 'Last week';
  if (diff.inDays >= 2) return '${diff.inDays} days ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inHours >= 1) return '${diff.inHours}h ago';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
  return 'Just now';
}
