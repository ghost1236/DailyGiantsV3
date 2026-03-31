import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/scraper_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/scoreboard_models.dart';

final scoreboardProvider =
    AsyncNotifierProvider<ScoreboardNotifier, List<GameScore>>(
  ScoreboardNotifier.new,
);

class ScoreboardNotifier extends AsyncNotifier<List<GameScore>> {
  @override
  Future<List<GameScore>> build() async {
    return _fetchScoreboard();
  }

  Future<List<GameScore>> _fetchScoreboard() async {
    final scraper = ScraperClient();
    final doc = await scraper.fetchHtml(ApiConstants.scoreboardUrl);

    final games = <GameScore>[];
    final gameBlocks = doc.querySelectorAll('div.smsScore');

    for (var block in gameBlocks) {
      // Team names from strong.teamT
      final teamEls = block.querySelectorAll('.teamT');
      if (teamEls.length < 2) continue;
      final awayTeam = teamEls[0].text.trim();
      final homeTeam = teamEls[1].text.trim();

      // Scores from em.score > span
      final scoreEls = block.querySelectorAll('em.score span');
      final awayScore = scoreEls.isNotEmpty
          ? int.tryParse(scoreEls[0].text.trim()) ?? 0
          : 0;
      final homeScore = scoreEls.length >= 2
          ? int.tryParse(scoreEls[1].text.trim()) ?? 0
          : 0;

      // Game status from strong.flag > span
      final flagEl = block.querySelector('strong.flag span');
      final status = flagEl?.text.trim() ?? '경기전';

      // Stadium and time from p.place
      final placeEl = block.querySelector('p.place');
      final timeEl = placeEl?.querySelector('span');
      final time = timeEl?.text.trim() ?? '';
      // Stadium is the text before <span>
      String stadium = '';
      if (placeEl != null) {
        stadium = placeEl.text.replaceAll(time, '').trim();
      }

      // Inning scores from table.tScore
      final innings = <InningScore>[];
      final scoreTable = block.querySelector('table.tScore');
      if (scoreTable != null) {
        final rows = scoreTable.querySelectorAll('tbody tr');
        if (rows.length >= 2) {
          final awayCells = rows[0].querySelectorAll('td');
          final homeCells = rows[1].querySelectorAll('td');
          // Cells: innings 1-12, then R, H, E, B (last 4)
          final inningCount = awayCells.length >= 4
              ? awayCells.length - 4
              : awayCells.length;
          for (var i = 0; i < inningCount; i++) {
            final awayVal = int.tryParse(awayCells[i].text.trim());
            final homeVal = i < homeCells.length
                ? int.tryParse(homeCells[i].text.trim())
                : null;
            // Skip innings with no data (just "-")
            if (awayVal != null || homeVal != null) {
              innings.add(InningScore(
                inning: i + 1,
                awayScore: awayVal,
                homeScore: homeVal,
              ));
            }
          }
        }
      }

      // R, H, E, B from last 4 td cells
      int awayHits = 0, homeHits = 0;
      int awayErrors = 0, homeErrors = 0;
      int awayBases = 0, homeBases = 0;
      if (scoreTable != null) {
        final rows = scoreTable.querySelectorAll('tbody tr');
        if (rows.length >= 2) {
          final awayCells = rows[0].querySelectorAll('td');
          final homeCells = rows[1].querySelectorAll('td');
          if (awayCells.length >= 4) {
            final len = awayCells.length;
            // R is already in awayScore/homeScore
            awayHits = int.tryParse(awayCells[len - 3].text.trim()) ?? 0;
            awayErrors = int.tryParse(awayCells[len - 2].text.trim()) ?? 0;
            awayBases = int.tryParse(awayCells[len - 1].text.trim()) ?? 0;
          }
          if (homeCells.length >= 4) {
            final len = homeCells.length;
            homeHits = int.tryParse(homeCells[len - 3].text.trim()) ?? 0;
            homeErrors = int.tryParse(homeCells[len - 2].text.trim()) ?? 0;
            homeBases = int.tryParse(homeCells[len - 1].text.trim()) ?? 0;
          }
        }
      }

      games.add(GameScore(
        gameDate: DateTime.now().toString().substring(0, 10),
        time: time,
        awayTeam: awayTeam,
        homeTeam: homeTeam,
        awayScore: awayScore,
        homeScore: homeScore,
        status: status,
        stadium: stadium,
        innings: innings,
        awayHits: awayHits,
        homeHits: homeHits,
        awayErrors: awayErrors,
        homeErrors: homeErrors,
        awayBases: awayBases,
        homeBases: homeBases,
      ));
    }

    // Filter Lotte games only
    final lotteGames =
        games.where((g) => g.isLotteGame).toList();
    return lotteGames;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchScoreboard);
  }
}
