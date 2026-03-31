import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/song_models.dart';
import '../data/local_songs.dart';

final songTabProvider = StateProvider<int>((ref) => 0);
final currentPlayingSongProvider = StateProvider<int?>((ref) => null);

final teamSongProvider = FutureProvider<List<CheeringSong>>((ref) async {
  return getTeamCheeringSongs();
});

final playerSongProvider = FutureProvider<List<CheeringSong>>((ref) async {
  return getPlayerCheeringSongs();
});
