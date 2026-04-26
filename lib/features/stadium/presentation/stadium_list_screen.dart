import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/team_logo.dart';
import '../providers/stadium_provider.dart';
import '../data/stadium_models.dart';

class StadiumListScreen extends ConsumerWidget {
  const StadiumListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stadiumsAsync = ref.watch(stadiumListProvider);

    return Scaffold(
      appBar: AppHeader(title: '직관정보'),
      body: stadiumsAsync.when(
        data: (stadiums) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: stadiums.length,
          itemBuilder: (context, index) {
            final stadium = stadiums[index];
            return _StadiumCard(stadium: stadium);
          },
        ),
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: '구장 정보를 불러올 수 없습니다',
          onRetry: () => ref.invalidate(stadiumListProvider),
        ),
      ),
    );
  }
}

class _StadiumCard extends StatelessWidget {
  final Stadium stadium;

  const _StadiumCard({required this.stadium});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/stadium/${stadium.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: stadium.isHome
              ? Border.all(color: AppColors.accent.withOpacity(0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (stadium.isHome)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HOME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            TeamLogo(team: stadium.team, size: 64),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                stadium.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stadium.team,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
