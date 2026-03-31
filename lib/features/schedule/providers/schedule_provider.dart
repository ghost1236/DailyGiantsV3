import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/schedule_models.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final scheduleProvider =
    FutureProvider.family<List<MatchSchedule>, DateTime>((ref, month) async {
  final apiClient = ref.read(apiClientProvider);
  final year = month.year.toString();
  final monthStr = month.month.toString().padLeft(2, '0');
  final response =
      await apiClient.get(ApiConstants.matchSchedule(year, monthStr));

  final data = response.data as Map<String, dynamic>;
  final list = data['match'] as List? ?? [];
  return list
      .map((e) => MatchSchedule.fromJson(e as Map<String, dynamic>))
      .toList();
});
