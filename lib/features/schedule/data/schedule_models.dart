class MatchSchedule {
  final int idx;
  final int year;
  final int month;
  final String date; // "03/12(목)"
  final String teamImg;
  final String teamName;
  final String stadium;
  final String time;
  final String score;
  final String result;

  MatchSchedule({
    required this.idx,
    required this.year,
    required this.month,
    required this.date,
    this.teamImg = '',
    required this.teamName,
    required this.stadium,
    required this.time,
    this.score = '',
    this.result = '',
  });

  factory MatchSchedule.fromJson(Map<String, dynamic> json) {
    return MatchSchedule(
      idx: json['idx'] ?? 0,
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      date: json['date'] ?? '',
      teamImg: json['teamImg'] ?? '',
      teamName: json['teamName'] ?? '',
      stadium: json['stadium'] ?? '',
      time: json['time'] ?? '',
      score: json['score'] ?? '',
      result: json['result'] ?? '',
    );
  }

  /// "03/12(목)" → day number 12
  int get dayNumber {
    final match = RegExp(r'\d+/(\d+)').firstMatch(date);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  /// "03/12(목)" → "목"
  String get dayOfWeek {
    final match = RegExp(r'\((.)\)').firstMatch(date);
    return match?.group(1) ?? '';
  }

  /// Returns a DateTime for calendar matching
  DateTime? get dateTime {
    try {
      final match = RegExp(r'(\d+)/(\d+)').firstMatch(date);
      if (match == null) return null;
      final m = int.parse(match.group(1)!);
      final d = int.parse(match.group(2)!);
      return DateTime(year, m, d);
    } catch (_) {
      return null;
    }
  }

  bool get hasScore => score.isNotEmpty && score.contains(':');

  String? get awayScore {
    if (!hasScore) return null;
    return score.split(':').first.trim();
  }

  String? get homeScore {
    if (!hasScore) return null;
    return score.split(':').last.trim();
  }

  bool get isWin => result == '승';
  bool get isLose => result == '패';
  bool get isDraw => result == '무';
  bool get isCanceled => result == '취소';
}
