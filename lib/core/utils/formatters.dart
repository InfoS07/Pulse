import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initializeDateFormattingForLocale() async {
  await initializeDateFormatting('fr_FR', null);
}

String formatTimestamp(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  final dateFormat = DateFormat('d MMMM yyyy', 'fr_FR');
  final timeFormat = DateFormat('HH:mm', 'fr_FR');

  String formattedDate;

  if (difference.inDays == 0 && now.day == dateTime.day) {
    formattedDate = "Aujourd'hui à ${timeFormat.format(dateTime)}";
  } else if (difference.inDays == 1 ||
      (difference.inDays == 0 && now.day != dateTime.day)) {
    formattedDate = "Hier à ${timeFormat.format(dateTime)}";
  } else {
    formattedDate =
        '${dateFormat.format(dateTime)} à ${timeFormat.format(dateTime)}';
  }

  return formattedDate;
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
