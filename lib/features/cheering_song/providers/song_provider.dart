import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/song_models.dart';

final songTabProvider = StateProvider<int>((ref) => 0);
final currentPlayingSongProvider = StateProvider<int?>((ref) => null);

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

final teamSongProvider = FutureProvider<List<CheeringSong>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get(ApiConstants.teamSongList);
  final List data = response.data is List ? response.data : response.data['list'] ?? response.data['data'] ?? [];
  return data.map((json) => CheeringSong.fromJson(json)).toList();
});

final playerSongProvider = FutureProvider<List<CheeringSong>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get(ApiConstants.playerSongList);
  final List data = response.data is List ? response.data : response.data['list'] ?? response.data['data'] ?? [];
  return data.map((json) => CheeringSong.fromJson(json)).toList();
});
