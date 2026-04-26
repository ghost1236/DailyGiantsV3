class MatchSchedule {
  final int idx;
  final int year;
  final int month;
  final int date;
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
      date: json['date'] is int ? json['date'] : int.tryParse(json['date'].toString()) ?? 0,
      teamImg: json['teamImg'] ?? '',
      teamName: json['teamName'] ?? '',
      stadium: json['stadium'] ?? '',
      time: json['time'] ?? '',
      score: json['score'] ?? '',
      result: json['result'] ?? '',
    );
  }

  int get dayNumber => date;

  String get dayOfWeek {
    final dt = dateTime;
    if (dt == null) return '';
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[dt.weekday - 1];
  }

  DateTime? get dateTime {
    try {
      return DateTime(year, month, date);
    } catch (_) {
      return null;
    }
  }

  String get dateDisplay => '$month/$date($dayOfWeek)';

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
