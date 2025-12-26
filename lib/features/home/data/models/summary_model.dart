class SummaryModel {
  final String userId;
  final String date; // Format: YYYY-MM-DD
  final int dailyFocus;
  final int dailyBreak;
  final int dailyTotal;
  final List<String> labelsStudied;

  SummaryModel({
    required this.userId, required this.date,
    this.dailyFocus = 0, this.dailyBreak = 0, this.dailyTotal = 0,
    this.labelsStudied = const [],
  });

  factory SummaryModel.fromMap(Map<String, dynamic> data) {
    return SummaryModel(
      userId: data['userId'] ?? '',
      date: data['date'] ?? '',
      dailyFocus: data['dailyFocus'] ?? 0,
      dailyBreak: data['dailyBreak'] ?? 0,
      dailyTotal: data['dailyTotal'] ?? 0,
      labelsStudied: List<String>.from(data['labelsStudied'] ?? []),
    );
  }
}