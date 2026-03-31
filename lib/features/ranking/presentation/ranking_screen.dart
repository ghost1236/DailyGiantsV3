import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/team_logo.dart';
import '../providers/ranking_provider.dart';
import '../data/ranking_models.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(rankingTabProvider);

    return Scaffold(
      appBar: AppHeader(title: '순위'),
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
                  icon: Icons.leaderboard_outlined,
                  label: '팀 순위',
                  isSelected: selectedTab == 0,
                  onTap: () =>
                      ref.read(rankingTabProvider.notifier).state = 0,
                ),
                _TabButton(
                  icon: Icons.person_outline,
                  label: '개인 순위',
                  isSelected: selectedTab == 1,
                  onTap: () =>
                      ref.read(rankingTabProvider.notifier).state = 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedTab == 0
                ? const _TeamRankTab()
                : const _PlayerRankTab(),
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

// ══════════════════════════════════════
//  팀 순위 탭 (순위표 + 상대전적)
// ══════════════════════════════════════
class _TeamRankTab extends ConsumerWidget {
  const _TeamRankTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankAsync = ref.watch(teamRankProvider);
    final diffAsync = ref.watch(teamDiffProvider);

    return rankAsync.when(
      data: (ranks) => CustomScrollView(
        slivers: [
          // 팀 순위표
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 28, child: Text('#', style: _headerStyle)),
                  SizedBox(width: 8),
                  Expanded(child: Text('팀', style: _headerStyle)),
                  SizedBox(width: 30, child: Text('경기', style: _headerStyle)),
                  SizedBox(width: 30, child: Text('승', style: _headerStyle)),
                  SizedBox(width: 30, child: Text('패', style: _headerStyle)),
                  SizedBox(width: 30, child: Text('무', style: _headerStyle)),
                  SizedBox(
                      width: 46, child: Text('승률', style: _headerStyle)),
                  SizedBox(
                      width: 30, child: Text('게차', style: _headerStyle)),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _TeamRankRow(rank: ranks[index]),
              childCount: ranks.length,
            ),
          ),

          // 롯데 상대전적
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '롯데 상대전적',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '(승-패-무)',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: diffAsync.when(
              data: (diffs) => _TeamDiffGrid(diffs: diffs),
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: '순위를 불러올 수 없습니다',
        onRetry: () => ref.invalidate(teamRankProvider),
      ),
    );
  }
}

// ══════════════════════════════════════
//  개인 순위 탭 (타자 + 투수 토글)
// ══════════════════════════════════════
class _PlayerRankTab extends ConsumerWidget {
  const _PlayerRankTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(playerRankTabProvider);

    return Column(
      children: [
        // 타자/투수 세그먼트
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _SegmentButton(
                label: '타자 순위',
                isSelected: selectedTab == 0,
                onTap: () =>
                    ref.read(playerRankTabProvider.notifier).state = 0,
              ),
              _SegmentButton(
                label: '투수 순위',
                isSelected: selectedTab == 1,
                onTap: () =>
                    ref.read(playerRankTabProvider.notifier).state = 1,
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedTab == 0
              ? const _HitterRankList()
              : const _PitcherRankList(),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
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
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 공통 스타일 ──
const _headerStyle = TextStyle(
  color: AppColors.textTertiary,
  fontSize: 11,
  fontWeight: FontWeight.w600,
);

const _cellStyle = TextStyle(color: AppColors.textSecondary, fontSize: 13);

// ── 팀 순위 행 ──
class _TeamRankRow extends StatelessWidget {
  final TeamRank rank;
  const _TeamRankRow({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isLotte = rank.isLotte;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isLotte
            ? AppColors.accent.withOpacity(0.08)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border:
            isLotte ? Border.all(color: AppColors.accent.withOpacity(0.25)) : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: _RankBadge(rank: rank.rank)),
          const SizedBox(width: 8),
          TeamLogo(team: rank.team, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              rank.team,
              style: TextStyle(
                color: isLotte ? AppColors.accent : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: isLotte ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
              width: 30,
              child:
                  Text('${rank.games}', textAlign: TextAlign.center, style: _cellStyle)),
          SizedBox(
              width: 30,
              child: Text('${rank.wins}',
                  textAlign: TextAlign.center,
                  style: _cellStyle.copyWith(color: AppColors.win))),
          SizedBox(
              width: 30,
              child: Text('${rank.losses}',
                  textAlign: TextAlign.center,
                  style: _cellStyle.copyWith(color: AppColors.lose))),
          SizedBox(
              width: 30,
              child:
                  Text('${rank.draws}', textAlign: TextAlign.center, style: _cellStyle)),
          SizedBox(
            width: 46,
            child: Text(
              rank.winRate.toStringAsFixed(3),
              textAlign: TextAlign.center,
              style: _cellStyle.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              rank.gamesBehind == 0 ? '-' : '${rank.gamesBehind}',
              textAlign: TextAlign.center,
              style: _cellStyle,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 순위 뱃지 ──
class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    Color? badgeColor;
    if (rank == 1) badgeColor = AppColors.gold;
    if (rank == 2) badgeColor = AppColors.silver;
    if (rank == 3) badgeColor = AppColors.bronze;

    if (badgeColor != null) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
                color: badgeColor, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
    return Text(
      '$rank',
      textAlign: TextAlign.center,
      style: const TextStyle(
          color: AppColors.textTertiary, fontSize: 13, fontWeight: FontWeight.w600),
    );
  }
}

// ── 상대전적 그리드 ──
class _TeamDiffGrid extends StatelessWidget {
  final List<TeamDiff> diffs;
  const _TeamDiffGrid({required this.diffs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: diffs.map((diff) {
          if (diff.isSelf) return const SizedBox.shrink();

          final parts = diff.diff.split('-');
          final wins = parts.isNotEmpty ? parts[0] : '0';
          final losses = parts.length > 1 ? parts[1] : '0';
          final draws = parts.length > 2 ? parts[2] : '0';
          final winsInt = int.tryParse(wins) ?? 0;
          final lossesInt = int.tryParse(losses) ?? 0;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.divider.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                TeamLogo(team: diff.name, size: 28),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    diff.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 승패 바
                Expanded(
                  child: _WinLossBar(wins: winsInt, losses: lossesInt),
                ),
                const SizedBox(width: 12),
                // 전적 텍스트
                SizedBox(
                  width: 72,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        wins,
                        style: const TextStyle(
                          color: AppColors.win,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(' - ',
                          style:
                              TextStyle(color: AppColors.textTertiary, fontSize: 14)),
                      Text(
                        losses,
                        style: const TextStyle(
                          color: AppColors.lose,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(' - ',
                          style:
                              TextStyle(color: AppColors.textTertiary, fontSize: 14)),
                      Text(
                        draws,
                        style: const TextStyle(
                          color: AppColors.draw,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WinLossBar extends StatelessWidget {
  final int wins;
  final int losses;
  const _WinLossBar({required this.wins, required this.losses});

  @override
  Widget build(BuildContext context) {
    final total = wins + losses;
    if (total == 0) {
      return Container(
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }
    final winRatio = wins / total;

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.lose.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: winRatio,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.win,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

// ── 타자 순위 ──
class _HitterRankList extends ConsumerWidget {
  const _HitterRankList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankAsync = ref.watch(hitterRankProvider);

    return rankAsync.when(
      data: (ranks) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ranks.length,
        itemBuilder: (context, index) {
          final rank = ranks[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _RankBadge(rank: rank.rank),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rank.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatColumn('타율', rank.avg.toStringAsFixed(3)),
                _StatColumn('안타', '${rank.hits}'),
                _StatColumn('홈런', '${rank.homeRuns}'),
                _StatColumn('도루', '${rank.stolenBases}'),
              ],
            ),
          );
        },
      ),
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: '타자 순위를 불러올 수 없습니다',
        onRetry: () => ref.invalidate(hitterRankProvider),
      ),
    );
  }
}

// ── 투수 순위 ──
class _PitcherRankList extends ConsumerWidget {
  const _PitcherRankList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankAsync = ref.watch(pitcherRankProvider);

    return rankAsync.when(
      data: (ranks) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ranks.length,
        itemBuilder: (context, index) {
          final rank = ranks[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _RankBadge(rank: rank.rank),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rank.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatColumn('방어율', rank.era.toStringAsFixed(2)),
                _StatColumn('승', '${rank.wins}'),
                _StatColumn('패', '${rank.losses}'),
                _StatColumn('이닝', rank.innings),
              ],
            ),
          );
        },
      ),
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: '투수 순위를 불러올 수 없습니다',
        onRetry: () => ref.invalidate(pitcherRankProvider),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
