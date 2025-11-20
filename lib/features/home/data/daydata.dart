class DayData {
  final String dayNameInitial; // M, T, W, dst.
  final String dayNumber; // 3, 4, 5, dst.
  final bool isHighlighted; // Apakah hari ini memiliki progress?
  final bool isToday; // Untuk menandai hari ini dengan gaya khusus (opsional)

  DayData({
    required this.dayNameInitial,
    required this.dayNumber,
    this.isHighlighted = false,
    this.isToday = false,
  });
}