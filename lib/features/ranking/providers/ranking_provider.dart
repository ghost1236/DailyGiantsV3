import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/ranking_models.dart';

final rankingTabProvider = StateProvider<int>((ref) => 0);
final playerRankTabProvider = StateProvider<int>((ref) => 0); // 0=타자, 1=투수

final teamRankProvider = FutureProvider<List<TeamRank>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiConstants.teamRank);
  final data = response.data as Map<String, dynamic>;
  final list = data['list'] as List;
  return list
      .map((e) => TeamRank.fromJson(e as Map<String, dynamic>))
      .toList();
});

final teamDiffProvider = FutureProvider<List<TeamDiff>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiConstants.teamRank);
  final data = response.data as Map<String, dynamic>;
  final list = data['diff'] as List? ?? [];
  return list
      .map((e) => TeamDiff.fromJson(e as Map<String, dynamic>))
      .toList();
});

final hitterRankProvider = FutureProvider<List<HitterRank>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiConstants.hitterRank);
  final data = response.data as Map<String, dynamic>;
  final list = data['list'] as List;
  return list
      .map((e) => HitterRank.fromJson(e as Map<String, dynamic>))
      .toList();
});

final pitcherRankProvider = FutureProvider<List<PitcherRank>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiConstants.pitcherRank);
  final data = response.data as Map<String, dynamic>;
  final list = data['list'] as List;
  return list
      .map((e) => PitcherRank.fromJson(e as Map<String, dynamic>))
      .toList();
});
