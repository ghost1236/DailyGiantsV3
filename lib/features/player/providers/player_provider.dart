import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/player_models.dart';

final positionFilterProvider = StateProvider<String>((ref) => '전체');
final playerSearchProvider = StateProvider<String>((ref) => '');

final playerListProvider = FutureProvider<List<Player>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiConstants.playerList);
  final data = response.data as Map<String, dynamic>;
  final list = data['list'] as List;
  return list
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .where((p) => p.isPlayer)
      .toList();
});

final filteredPlayerProvider = Provider<AsyncValue<List<Player>>>((ref) {
  final playersAsync = ref.watch(playerListProvider);
  final filter = ref.watch(positionFilterProvider);
  final search = ref.watch(playerSearchProvider).toLowerCase();

  return playersAsync.whenData((players) {
    var filtered = players;
    if (filter != '전체') {
      filtered = filtered.where((p) => p.position == filter).toList();
    }
    if (search.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(search) ||
              p.number.toString() == search)
          .toList();
    }
    return filtered;
  });
});

final playerDetailProvider =
    FutureProvider.family<PlayerDetail, String>((ref, pcode) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiConstants.playerDetail(pcode));
  final data = response.data as Map<String, dynamic>;
  return PlayerDetail(
    player: Player.fromJson(data),
    stats: data['stats'] as Map<String, dynamic>? ?? {},
    yearlyStats: (data['yearlyStats'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [],
  );
});
