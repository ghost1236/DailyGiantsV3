import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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

    return songsAsync.when(
      data: (songs) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          final hasYoutube = song.youtubeUrl != null;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasYoutube
                      ? const Color(0xFFFF0000).withOpacity(0.1)
                      : AppColors.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: song.thumbnail != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          headers: const {
                            'User-Agent': 'Mozilla/5.0 (Linux; Android 10)'
                          },
                          song.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            hasYoutube
                                ? Icons.play_circle_fill
                                : Icons.music_note,
                            color: hasYoutube
                                ? const Color(0xFFFF0000)
                                : AppColors.textTertiary,
                            size: 24,
                          ),
                        ),
                      )
                    : Icon(
                        hasYoutube
                            ? Icons.play_circle_fill
                            : Icons.music_note,
                        color: hasYoutube
                            ? const Color(0xFFFF0000)
                            : AppColors.textTertiary,
                        size: 24,
                      ),
              ),
              title: Text(
                song.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
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
              trailing: hasYoutube
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow,
                              color: Color(0xFFFF0000), size: 16),
                          SizedBox(width: 2),
                          Text(
                            'YouTube',
                            style: TextStyle(
                              color: Color(0xFFFF0000),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Icon(
                      Icons.lyrics_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
              onTap: () {
                if (hasYoutube) {
                  _openYoutube(song.youtubeUrl!);
                } else {
                  _showLyricsSheet(context, song);
                }
              },
            ),
          );
        },
      ),
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('응원가를 불러올 수 없습니다\n$e')),
    );
  }

  Future<void> _openYoutube(String url) async {
    // 유튜브 앱으로 열기 시도
    final videoUri = Uri.parse(url);
    final appUrl = url
        .replaceFirst('https://www.youtube.com/', 'vnd.youtube://')
        .replaceFirst('https://youtube.com/', 'vnd.youtube://');
    final appUri = Uri.parse(appUrl);

    try {
      final launched =
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(videoUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(videoUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLyricsSheet(BuildContext context, CheeringSong song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (song.number != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${song.number}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      song.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              Text(
                song.lyrics.isNotEmpty ? song.lyrics : '가사 정보가 없습니다',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
