class ApiConstants {
  static const String baseUrl = 'http://smiling.kr:5580/DailyGiants_api';
  static const String scoreboardUrl =
      'https://www.koreabaseball.com/Schedule/ScoreBoard.aspx';
  static const String cheerSongBaseUrl = 'http://smiling.kr:5580/cheersong';

  // API Endpoints
  static String matchSchedule(String year, String month) =>
      '/apis/matchs/$year/$month';
  static const String teamRank = '/apis/teamRank';
  static const String hitterRank = '/apis/hitterRank';
  static const String pitcherRank = '/apis/PitcherRank';
  static const String playerList = '/apis/player';
  static String playerDetail(String id) => '/apis/player/$id';
  static const String teamSongList = '/apis/teamsongs';
  static const String playerSongList = '/apis/playersongs';
  static const String cheerleaderList = '/apis/cheerleaderlist';
  static const String scoreboard = '/apis/scoreboard';
  static const String stadiumList = '/apis/stadiums';
  static String stadiumDetail(int id) => '/apis/stadiums/$id';
}
