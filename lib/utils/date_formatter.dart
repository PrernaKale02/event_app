import 'package:intl/intl.dart';

class DateFormatter {
  static String format(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      // Expecting dateStr to be parsable if it's in standard format.
      // However, our current app saves "15 Nov 2026" or similar from the date picker.
      // If the date picker saves a clean string, we might just return it or reformat it.
      // The current date picker saves: '${pickedDate.day} ${_monthName(pickedDate.month)} ${pickedDate.year}'
      // e.g. "4 Jan 2026". This is already quite readable.
      
      // But if we want to standardize or add Weekday, we need to parse it.
      // Let's try to parse "d MMM yyyy".
      // If parsing fails, return original string.
      
      // Creating a parser involves guessing the format. 
      // It's better if we start storing DateTime objects or ISO strings in Firestore for robustness.
      // BUT for now, to avoid migration, let's just try to parse the known format.
      
      // Our custom format was: "d MMM yyyy" (e.g. "4 Jan 2026")
      DateFormat inputFormat = DateFormat("d MMM yyyy");
      DateTime dateTime = inputFormat.parse(dateStr);
      
      // Desired format: "Wed, 4 Jan 2026"
      return DateFormat("EEE, d MMM yyyy").format(dateTime);
    } catch (e) {
      // If parsing fails (maybe old data or different format), return as is.
      return dateStr;
    }
  }

  // Helper to format DateTime objects directly (useful for new inputs)
  static String formatDate(DateTime date) {
    return DateFormat("d MMM yyyy").format(date);
  }
}
