String formatTimestamp(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  return '${dateTime.hour}:${dateTime.minute} - ${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

String formatDurationTraining(DateTime startAt, DateTime endAt) {
  final duration = endAt.difference(startAt);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}min';
  } else {
    return '${minutes}min';
  }
}
