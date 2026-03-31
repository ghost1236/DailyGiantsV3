import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/cheerleader_models.dart';

final cheerleaderListProvider = FutureProvider<List<Cheerleader>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get(ApiConstants.cheerleaderList);
  final data = response.data as Map<String, dynamic>;
  final list = data['list'] as List;
  return list
      .map((e) => Cheerleader.fromJson(e as Map<String, dynamic>))
      .toList();
});
