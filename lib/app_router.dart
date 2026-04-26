import 'package:go_router/go_router.dart';
import 'features/scoreboard/presentation/scoreboard_screen.dart';
import 'features/schedule/presentation/schedule_screen.dart';
import 'features/ranking/presentation/ranking_screen.dart';
import 'features/cheering_song/presentation/cheering_song_screen.dart';
import 'features/stadium/presentation/stadium_list_screen.dart';
import 'features/stadium/presentation/stadium_detail_screen.dart';
import 'shared/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/scoreboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/scoreboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ScoreboardScreen(),
          ),
        ),
        GoRoute(
          path: '/schedule',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ScheduleScreen(),
          ),
        ),
        GoRoute(
          path: '/ranking',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: RankingScreen(),
          ),
        ),
        GoRoute(
          path: '/stadiums',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StadiumListScreen(),
          ),
        ),
        GoRoute(
          path: '/songs',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CheeringSongScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/stadium/:id',
      builder: (context, state) => StadiumDetailScreen(
        stadiumId: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);
