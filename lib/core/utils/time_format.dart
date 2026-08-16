String formatTime12Hr(String apiTime) {
  final parts = apiTime.split(':');
  final hour24 = int.parse(parts[0]);
  final minute = parts[1];

  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = switch (hour24 % 12) {
    0 => 12,
    final h => h,
  };

  return '$hour12:$minute $period';
}
