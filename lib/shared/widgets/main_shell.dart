import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'banner_ad_widget.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/scoreboard')) return 0;
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/ranking')) return 2;
    if (location.startsWith('/players')) return 3;
    if (location.startsWith('/songs')) return 4;
    if (location.startsWith('/cheerleaders')) return 5;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/scoreboard');
      case 1:
        context.go('/schedule');
      case 2:
        context.go('/ranking');
      case 3:
        context.go('/players');
      case 4:
        context.go('/songs');
      case 5:
        context.go('/cheerleaders');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const BannerAdWidget(),
              Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  assetIcon: 'assets/icons/ic_baseball.png',
                  label: '스코어',
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  assetIcon: 'assets/icons/ic_cal.png',
                  label: '일정',
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                ),
                _NavItem(
                  assetIcon: 'assets/icons/ic_rank.png',
                  label: '순위',
                  isActive: currentIndex == 2,
                  onTap: () => _onTap(context, 2),
                ),
                _NavItem(
                  assetIcon: 'assets/icons/ic_player.png',
                  label: '선수단',
                  isActive: currentIndex == 3,
                  onTap: () => _onTap(context, 3),
                ),
                _NavItem(
                  assetIcon: 'assets/icons/ic_cheersong.png',
                  label: '응원가',
                  isActive: currentIndex == 4,
                  onTap: () => _onTap(context, 4),
                ),
                _NavItem(
                  icon: Icons.stars_outlined,
                  activeIcon: Icons.stars,
                  label: '응원단',
                  isActive: currentIndex == 5,
                  onTap: () => _onTap(context, 5),
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
