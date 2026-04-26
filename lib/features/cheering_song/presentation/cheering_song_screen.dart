import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/song_provider.dart';
import '../data/song_models.dart';

class CheeringSongScreen extends ConsumerWidget {
  const CheeringSongScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(songTabProvider);

    return Scaffold(
      appBar: AppHeader(title: '응원가'),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TabButton(
                  icon: Icons.groups_outlined,
                  label: '팀 응원가',
                  isSelected: selectedTab == 0,
                  onTap: () =>
                      ref.read(songTabProvider.notifier).state = 0,
                ),
                _TabButton(
                  icon: Icons.person_outline,
                  label: '선수 응원가',
                  isSelected: selectedTab == 1,
                  onTap: () =>
                      ref.read(songTabProvider.notifier).state = 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedTab == 0
                ? _SongList(provider: teamSongProvider)
                : _SongList(provider: playerSongProvider),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textTertiary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongList extends ConsumerWidget {
  final FutureProvider<List<CheeringSong>> provider;

  const _SongList({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(provider);
    final currentPlaying = ref.watch(currentPlayingSongProvider);

    return songsAsync.when(
      data: (songs) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          final isPlaying = currentPlaying == song.id;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isPlaying
                  ? AppColors.accent.withOpacity(0.08)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: isPlaying
                  ? Border.all(color: AppColors.accent.withOpacity(0.3))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? AppColors.accent.withOpacity(0.15)
                          : AppColors.cardBackgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: isPlaying ? AppColors.accent : AppColors.textTertiary,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(
                      color: isPlaying ? AppColors.accent : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      if (song.number != null) ...[
                        Text(
                          '#${song.number}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          song.lyrics,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: isPlaying
                      ? _PlayingIndicator()
                      : const Icon(
                          Icons.music_note_outlined,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                  onTap: () => _togglePlay(ref, song),
                ),
                if (isPlaying) _LyricsPanel(song: song),
              ],
            ),
          );
        },
      ),
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('응원가를 불러올 수 없습니다\n$e')),
    );
  }

  Future<void> _togglePlay(WidgetRef ref, CheeringSong song) async {
    final player = ref.read(audioPlayerProvider);
    final currentPlaying = ref.read(currentPlayingSongProvider);

    if (currentPlaying == song.id) {
      await player.stop();
      ref.read(currentPlayingSongProvider.notifier).state = null;
    } else {
      ref.read(currentPlayingSongProvider.notifier).state = song.id;
      try {
        await player.setUrl(song.audioUrl);
        player.play();
        player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            ref.read(currentPlayingSongProvider.notifier).state = null;
          }
        });
      } catch (e) {
        ref.read(currentPlayingSongProvider.notifier).state = null;
      }
    }
  }
}

class _LyricsPanel extends StatelessWidget {
  final CheeringSong song;

  const _LyricsPanel({required this.song});

  @override
  Widget build(BuildContext context) {
    final allLyrics = <String>[
      if (song.lyrics.isNotEmpty) song.lyrics,
      if (song.lyrics2 != null && song.lyrics2!.isNotEmpty) song.lyrics2!,
      if (song.lyrics3 != null && song.lyrics3!.isNotEmpty) song.lyrics3!,
    ];

    if (allLyrics.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lyrics_outlined, size: 14, color: AppColors.accent),
                SizedBox(width: 6),
                Text(
                  '가사',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              allLyrics.join('\n\n'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayingIndicator extends StatefulWidget {
  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final value = ((_controller.value + delay) % 1.0);
            return Container(
              width: 3,
              height: 8 + value * 10,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
