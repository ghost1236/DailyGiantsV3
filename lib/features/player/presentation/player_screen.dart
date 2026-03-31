import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/player_scraper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/player_provider.dart';
import '../data/player_models.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(filteredPlayerProvider);
    final currentFilter = ref.watch(positionFilterProvider);
    ref.watch(playerSearchProvider);

    return Scaffold(
      appBar: const AppHeader(title: '선수단'),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) =>
                  ref.read(playerSearchProvider.notifier).state = value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: '선수 이름 또는 번호 검색',
                hintStyle: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textTertiary, size: 20),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 1),
                ),
              ),
            ),
          ),

          // Position Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: AppConstants.positionFilters.length,
              itemBuilder: (context, index) {
                final filter = AppConstants.positionFilters[index];
                final isSelected = filter == currentFilter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    onSelected: (_) => ref
                        .read(positionFilterProvider.notifier)
                        .state = filter,
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.accent,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Player Grid
          Expanded(
            child: playersAsync.when(
              data: (players) => GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return _PlayerCard(player: players[index]);
                },
              ),
              loading: () => const LoadingIndicator(),
              error: (e, _) =>
                  Center(child: Text('선수 정보를 불러올 수 없습니다\n$e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Player player;
  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPlayerDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // Player Image Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.5),
                      AppColors.cardBackground,
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: player.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: Image.network(
                          player.imageUrl,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, __, ___) =>
                              _buildPlayerPlaceholder(),
                        ),
                      )
                    : _buildPlayerPlaceholder(),
              ),
            ),
            // Player Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (player.number >= 0) ...[
                        Text(
                          '#${player.number}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          player.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    player.position,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player.number >= 0)
            Text(
              '${player.number}',
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          const Icon(
            Icons.person,
            color: AppColors.textTertiary,
            size: 32,
          ),
        ],
      ),
    );
  }

  void _showPlayerDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => FutureBuilder<PlayerDetailInfo>(
          future: PlayerScraper.fetchDetail(player.link),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 40, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      '선수 정보를 불러올 수 없습니다',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              );
            }

            final detail = snapshot.data!;
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  // Handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Player Image
                  Container(
                    height: 280,
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackgroundLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: detail.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              detail.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlayerPlaceholder(),
                            ),
                          )
                        : _buildPlayerPlaceholder(),
                  ),
                  // Name & Number
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (detail.number.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${detail.number}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        Text(
                          detail.name.isNotEmpty ? detail.name : player.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (detail.position.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        detail.position,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  // Info rows
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackgroundLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        if (detail.birthDate.isNotEmpty)
                          _DetailRow('생년월일', detail.birthDate),
                        if (detail.throwBat.isNotEmpty)
                          _DetailRow('투타', detail.throwBat),
                        if (detail.height.isNotEmpty || detail.weight.isNotEmpty)
                          _DetailRow('신장/체중',
                              '${detail.height} / ${detail.weight}'),
                        if (detail.career.isNotEmpty)
                          _DetailRow('경력', detail.career),
                        if (detail.joinYear.isNotEmpty)
                          _DetailRow('입단', detail.joinYear),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
