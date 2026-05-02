import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/cheering_song/providers/song_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/scoreboard')) return 0;
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/ranking')) return 2;
    if (location.startsWith('/stadiums')) return 3;
    if (location.startsWith('/songs')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, WidgetRef ref, int index) {
    if (index != 4) {
      final player = ref.read(audioPlayerProvider);
      player.stop();
      ref.read(currentPlayingSongProvider.notifier).state = null;
    }
    switch (index) {
      case 0:
        context.go('/scoreboard');
      case 1:
        context.go('/schedule');
      case 2:
        context.go('/ranking');
      case 3:
        context.go('/stadiums');
      case 4:
        context.go('/songs');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.sports_baseball_outlined,
                  activeIcon: Icons.sports_baseball,
                  label: '스코어',
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(context, ref, 0),
                ),
                _NavItem(
                  assetIcon: 'assets/icons/ic_cal.png',
                  label: '일정',
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(context, ref, 1),
                ),
                _NavItem(
                  assetIcon: 'assets/icons/ic_rank.png',
                  label: '순위',
                  isActive: currentIndex == 2,
                  onTap: () => _onTap(context, ref, 2),
                ),
                _NavItem(
                  icon: Icons.stadium_outlined,
                  activeIcon: Icons.stadium,
                  label: '직관정보',
                  isActive: currentIndex == 3,
                  onTap: () => _onTap(context, ref, 3),
                ),
                _NavItem(
                  assetIcon: 'assets/icons/ic_cheersong.png',
                  label: '응원가',
                  isActive: currentIndex == 4,
                  onTap: () => _onTap(context, ref, 4),
                ),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String? assetIcon;
  final IconData? icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    this.assetIcon,
    this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assetIcon != null)
              Image.asset(
                assetIcon!,
                width: 24,
                height: 24,
                color: color,
              )
            else
              Icon(
                isActive ? activeIcon : icon,
                size: 26,
                color: color,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
