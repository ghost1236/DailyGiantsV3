import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/cheerleader_provider.dart';
import '../data/cheerleader_models.dart';

class CheerleaderScreen extends ConsumerWidget {
  const CheerleaderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cheerleadersAsync = ref.watch(cheerleaderListProvider);

    return Scaffold(
      appBar: const AppHeader(title: '응원단'),
      body: cheerleadersAsync.when(
        data: (cheerleaders) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: cheerleaders.length,
          itemBuilder: (context, index) {
            return _CheerleaderCard(cheerleader: cheerleaders[index]);
          },
        ),
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('응원단 정보를 불러올 수 없습니다\n$e')),
      ),
    );
  }
}

class _CheerleaderCard extends StatelessWidget {
  final Cheerleader cheerleader;
  const _CheerleaderCard({required this.cheerleader});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accent.withOpacity(0.15),
                      AppColors.cardBackground,
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: cheerleader.mainImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: Image.network(
                          headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 10)'},
                          cheerleader.mainImageUrl,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    cheerleader.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cheerleader.pos,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.person, size: 48, color: AppColors.textTertiary),
    );
  }
}
