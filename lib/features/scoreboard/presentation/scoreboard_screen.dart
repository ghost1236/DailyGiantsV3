import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/team_logo.dart';
import '../providers/lineup_provider.dart';
import '../data/lineup_models.dart';

class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineupAsync = ref.watch(lineupProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            toolbarHeight: 64,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              '데일리 자이언츠',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () =>
                    ref.read(lineupProvider.notifier).refresh(),
              ),
            ],
          ),

          lineupAsync.when(
            data: (lineup) {
              if (lineup == null) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sports_baseball_outlined,
                          size: 64,
                          color: AppColors.textTertiary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '오늘은 롯데 경기가 없습니다',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '다음 경기를 기대해 주세요!',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scoreboard Card
                      _TodayGameCard(lineup: lineup),

                      const SizedBox(height: 24),

                      // Lineup Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'LINEUP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lineup.isLineupRegistered
                                ? '선발 라인업'
                                : '예상 라인업',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),

                      // Lineup notice
                      if (!lineup.isLineupRegistered)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14,
                                  color: AppColors.accent.withOpacity(0.7)),
                              const SizedBox(width: 6),
                              Text(
                                '라인업 발표 전으로 최근 라인업 기준입니다',
                                style: TextStyle(
                                  color: AppColors.accent.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Lineup Tables
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _LineupTable(
                              teamName: lineup.awayTeam,
                              players: lineup.awayLineup,
                              isAway: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _LineupTable(
                              teamName: lineup.homeTeam,
                              players: lineup.homeLineup,
                              isAway: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: LoadingIndicator(message: '오늘의 경기 로딩 중...'),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '데이터를 불러오지 못했습니다',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(lineupProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('새로고침'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scoreboard Card ──

class _TodayGameCard extends StatelessWidget {
  final LineupData lineup;
  const _TodayGameCard({required this.lineup});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bar: status + stadium/time
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusBadge(lineup: lineup),
                Text(
                  '${lineup.stadium} | ${lineup.gameTime}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Score area
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _TeamColumn(
                    team: lineup.awayTeam,
                    rank: lineup.awayRank,
                    isLotte: lineup.awayTeam.contains('롯데'),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: lineup.isScheduled
                      ? Column(
                          children: [
                            Text(
                              lineup.gameTime,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'VS',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ScoreText(
                              score: lineup.awayScore,
                              highlight: lineup.isFinished &&
                                  lineup.awayScore > lineup.homeScore,
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                ':',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            _ScoreText(
                              score: lineup.homeScore,
                              highlight: lineup.isFinished &&
                                  lineup.homeScore > lineup.awayScore,
                            ),
                          ],
                        ),
                ),
                Expanded(
                  child: _TeamColumn(
                    team: lineup.homeTeam,
                    rank: lineup.homeRank,
                    isLotte: lineup.homeTeam.contains('롯데'),
                  ),
                ),
              ],
            ),
          ),

          // Inning scoreboard
          if (lineup.innings.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.divider),
            _InningScoreTable(lineup: lineup),
          ],

          // Bottom: pitchers + TV
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PitcherInfo(name: lineup.awayPitcher),
                ),
                if (lineup.tvInfo.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      lineup.tvInfo,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Expanded(
                  child: _PitcherInfo(name: lineup.homePitcher),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final LineupData lineup;
  const _StatusBadge({required this.lineup});

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    final Color textColor;
    if (lineup.isLive) {
      badgeColor = AppColors.accent;
      textColor = Colors.white;
    } else if (lineup.isFinished) {
      badgeColor = AppColors.textTertiary.withOpacity(0.1);
      textColor = AppColors.textTertiary;
    } else {
      badgeColor = AppColors.primary.withOpacity(0.1);
      textColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lineup.isLive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            lineup.statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  final String team;
  final int rank;
  final bool isLotte;
  const _TeamColumn(
      {required this.team, required this.rank, required this.isLotte});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamLogo(team: team, size: 52),
        const SizedBox(height: 6),
        Text(
          team,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$rank위',
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ScoreText extends StatelessWidget {
  final int score;
  final bool highlight;
  const _ScoreText({required this.score, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$score',
      style: TextStyle(
        color: highlight ? AppColors.accent : AppColors.textPrimary,
        fontSize: 36,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PitcherInfo extends StatelessWidget {
  final String name;
  const _PitcherInfo({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.sports_baseball,
            size: 12, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          name,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Inning Score Table ──

class _InningScoreTable extends StatelessWidget {
  final LineupData lineup;
  const _InningScoreTable({required this.lineup});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Team name column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cell('', isHeader: true, width: 44),
                _cell(lineup.awayTeam, width: 44, isLotte: lineup.awayTeam.contains('롯데')),
                _cell(lineup.homeTeam, width: 44, isLotte: lineup.homeTeam.contains('롯데')),
              ],
            ),
            // Inning columns
            ...lineup.innings.map((inn) => Column(
                  children: [
                    _cell('${inn.inning}', isHeader: true),
                    _cell(inn.awayScore, isScore: true),
                    _cell(inn.homeScore, isScore: true),
                  ],
                )),
            // R column
            Column(
              children: [
                _cell('R', isHeader: true, highlight: true),
                _cell('${lineup.awayScore}', isScore: true, bold: true),
                _cell('${lineup.homeScore}', isScore: true, bold: true),
              ],
            ),
            // H column
            Column(
              children: [
                _cell('H', isHeader: true, highlight: true),
                _cell('${lineup.awayHits}', isScore: true),
                _cell('${lineup.homeHits}', isScore: true),
              ],
            ),
            // E column
            Column(
              children: [
                _cell('E', isHeader: true, highlight: true),
                _cell('${lineup.awayErrors}', isScore: true),
                _cell('${lineup.homeErrors}', isScore: true),
              ],
            ),
            // B column
            Column(
              children: [
                _cell('B', isHeader: true, highlight: true),
                _cell('${lineup.awayBases}', isScore: true),
                _cell('${lineup.homeBases}', isScore: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    bool isHeader = false,
    bool isScore = false,
    bool bold = false,
    bool highlight = false,
    bool isLotte = false,
    double width = 26,
  }) {
    Color textColor;
    if (isHeader) {
      textColor = highlight ? AppColors.accent : AppColors.textTertiary;
    } else if (isLotte) {
      textColor = AppColors.primary;
    } else if (bold) {
      textColor = AppColors.textPrimary;
    } else if (isScore && text != '-' && (int.tryParse(text) ?? 0) > 0) {
      textColor = AppColors.textPrimary;
    } else {
      textColor = AppColors.textTertiary;
    }

    return SizedBox(
      width: width,
      height: 22,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: isHeader ? 10 : 11,
            fontWeight: (isHeader || bold || isLotte)
                ? FontWeight.w700
                : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ── Lineup Table ──

class _LineupTable extends StatelessWidget {
  final String teamName;
  final List<LineupPlayer> players;
  final bool isAway;

  const _LineupTable({
    required this.teamName,
    required this.players,
    required this.isAway,
  });

  @override
  Widget build(BuildContext context) {
    final isLotte = teamName.contains('롯데');
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLotte
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          // Team header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isLotte
                  ? AppColors.primary
                  : AppColors.getTeamColor(teamName).withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TeamLogo(team: teamName, size: 20),
                const SizedBox(width: 6),
                Text(
                  '${isAway ? "(원정)" : "(홈)"} $teamName',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isLotte ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                SizedBox(
                    width: 22,
                    child: Text('#',
                        style: _headerStyle, textAlign: TextAlign.center)),
                Expanded(child: Text('선수', style: _headerStyle)),
                SizedBox(
                    width: 36,
                    child: Text('포지션',
                        style: _headerStyle, textAlign: TextAlign.center)),
                SizedBox(
                    width: 34,
                    child: Text('WAR',
                        style: _headerStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Player rows
          if (players.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '데이터 없음',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            )
          else
            ...players.map((p) => _PlayerRow(player: p, isLotte: isLotte)),

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  TextStyle get _headerStyle => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
      );
}

class _PlayerRow extends StatelessWidget {
  final LineupPlayer player;
  final bool isLotte;

  const _PlayerRow({required this.player, required this.isLotte});

  @override
  Widget build(BuildContext context) {
    final warValue = double.tryParse(player.war) ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '${player.order}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isLotte ? AppColors.accent : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              player.position,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              player.war,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: warValue > 0
                    ? AppColors.win
                    : warValue < 0
                        ? AppColors.lose
                        : AppColors.textTertiary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
