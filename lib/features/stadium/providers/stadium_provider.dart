import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/stadium_models.dart';

final stadiumTabProvider = StateProvider<int>((ref) => 0);

final stadiumListProvider = FutureProvider<List<Stadium>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get(ApiConstants.stadiumList);
  final List data = response.data is List
      ? response.data
      : response.data['data'] ?? response.data['list'] ?? [];
  final stadiums = data.map((json) => Stadium.fromJson(json)).toList();
  stadiums.sort((a, b) {
    if (a.isHome) return -1;
    if (b.isHome) return 1;
    return 0;
  });
  return stadiums;
});

final stadiumDetailProvider =
    FutureProvider.family<StadiumDetail, int>((ref, id) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get(ApiConstants.stadiumDetail(id));
  return StadiumDetail.fromJson(
      response.data['stadium'] ?? response.data['data'] ?? response.data);
});
