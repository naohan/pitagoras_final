double parseDecimal(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}

bool parseBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}

bool? parseBoolOrNull(dynamic value) {
  if (value == null) return null;
  return parseBool(value);
}

int parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}

int? parseIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime parseDateTime(dynamic value) => DateTime.parse(value as String);

DateTime? parseDateTimeOrNull(dynamic value) {
  if (value == null) return null;
  return DateTime.parse(value as String);
}
