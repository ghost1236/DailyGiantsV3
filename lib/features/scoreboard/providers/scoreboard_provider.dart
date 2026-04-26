import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/scoreboard_models.dart';

final scoreboardProvider =
    AsyncNotifierProvider<ScoreboardNotifier, List<GameScore>>(
  ScoreboardNotifier.new,
);

class ScoreboardNotifier extends AsyncNotifier<List<GameScore>> {
  @override
  Future<List<GameScore>> build() async {
    return _fetchScoreboard();
  }

  Future<List<GameScore>> _fetchScoreboard() async {
    final client = ref.read(apiClientProvider);
    final response = await client.get(ApiConstants.scoreboard);
    final data = response.data;

    // API가 단일 게임 객체 또는 리스트를 반환할 수 있음
    if (data is Map<String, dynamic> && data.containsKey('awayTeam')) {
      // 단일 게임
      return [GameScore.fromJson(data)];
    } else if (data is Map<String, dynamic> && data.containsKey('list')) {
      final list = data['list'] as List;
      return list.map((e) => GameScore.fromJson(e)).toList();
    } else if (data is List) {
      return data.map((e) => GameScore.fromJson(e)).toList();
    }

    return [];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchScoreboard);
  }
}
