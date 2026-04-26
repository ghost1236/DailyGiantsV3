import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/team_logo.dart';
import '../providers/stadium_provider.dart';
import '../data/stadium_models.dart';

class StadiumDetailScreen extends ConsumerWidget {
  final int stadiumId;

  const StadiumDetailScreen({super.key, required this.stadiumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(stadiumDetailProvider(stadiumId));
    final selectedTab = ref.watch(stadiumTabProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: detailAsync.when(
          data: (detail) => Row(
            children: [
              TeamLogo(team: detail.stadium.team, size: 32),
              const SizedBox(width: 10),
              Text(
                detail.stadium.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          loading: () => const Text('구장 정보',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          error: (_, __) => const Text('구장 정보',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
      body: detailAsync.when(
        data: (detail) => Column(
          children: [
            // 주소 카드
            _AddressCard(stadium: detail.stadium),
            // 탭 버튼
            _TabRow(
              selectedTab: selectedTab,
              onTabChanged: (index) =>
                  ref.read(stadiumTabProvider.notifier).state = index,
            ),
            // 탭 내용
            Expanded(
              child: _buildTabContent(selectedTab, detail),
            ),
          ],
        ),
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: '구장 상세 정보를 불러올 수 없습니다',
          onRetry: () => ref.invalidate(stadiumDetailProvider(stadiumId)),
        ),
      ),
    );
  }

  Widget _buildTabContent(int tab, StadiumDetail detail) {
    final items = switch (tab) {
      0 => detail.transport,
      1 => detail.parking,
      2 => detail.seats,
      3 => detail.food,
      4 => detail.tips,
      _ => <StadiumInfo>[],
    };
    final emptyMessage = switch (tab) {
      0 => '교통 정보가 없습니다',
      1 => '주차 정보가 없습니다',
      2 => '좌석 정보가 없습니다',
      3 => '맛집 정보가 없습니다',
      4 => '꿀팁 정보가 없습니다',
      _ => '정보가 없습니다',
    };

    if (items.isEmpty && !(tab == 2 && detail.stadium.seatMapImg != null)) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        ),
      );
    }

    // 꿀팁 탭: 번호 + content 카드 레이아웃
    if (tab == 4) {
      return _TipsList(items: items);
    }

    // 좌석 탭: 상단에 좌석배치도 이미지
    final hasSeatMap = tab == 2 && detail.stadium.seatMapImg != null;
    final totalCount = items.length + (hasSeatMap ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (hasSeatMap && index == 0) {
          return _SeatMapButton(imageUrl: detail.stadium.seatMapImg!);
        }
        final itemIndex = hasSeatMap ? index - 1 : index;
        return _InfoCard(item: items[itemIndex], tabIndex: tab);
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Stadium stadium;
  const _AddressCard({required this.stadium});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stadium.address,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
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
          if (stadium.lat != null && stadium.lng != null)
            GestureDetector(
              onTap: () => _openMap(stadium),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 14, color: AppColors.textPrimary),
                    SizedBox(width: 4),
                    Text(
                      '지도',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openMap(Stadium stadium) async {
    final lat = stadium.lat!;
    final lng = stadium.lng!;
    final name = Uri.encodeComponent(stadium.name);

    // 네이버맵 앱 → 카카오맵 앱 → 웹 순서로 시도
    final naverApp = Uri.parse('nmap://place?lat=$lat&lng=$lng&name=$name&appname=com.smiling.dailygiants');
    final kakaoApp = Uri.parse('kakaomap://look?p=$lat,$lng');
    final naverWeb = Uri.parse('https://map.naver.com/v5/search/$name');

    if (await canLaunchUrl(naverApp)) {
      await launchUrl(naverApp);
    } else if (await canLaunchUrl(kakaoApp)) {
      await launchUrl(kakaoApp);
    } else {
      await launchUrl(naverWeb, mode: LaunchMode.externalApplication);
    }
  }
}

class _TabRow extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _TabRow({required this.selectedTab, required this.onTabChanged});

  static const _tabs = [
    (Icons.directions_bus_outlined, '교통'),
    (Icons.local_parking_outlined, '주차'),
    (Icons.event_seat_outlined, '좌석'),
    (Icons.restaurant_outlined, '맛집'),
    (Icons.lightbulb_outlined, '꿀팁'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _tabs[i].$1,
                      size: 20,
                      color: isSelected ? Colors.white : AppColors.textTertiary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tabs[i].$2,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TipsList extends StatelessWidget {
  final List<StadiumInfo> items;
  const _TipsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.content,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeatMapButton extends StatelessWidget {
  final String imageUrl;
  const _SeatMapButton({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(imageUrl), mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(
              '좌석배치도 보기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.open_in_new, size: 14, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final StadiumInfo item;
  final int tabIndex;

  const _InfoCard({required this.item, required this.tabIndex});

  IconData get _icon => switch (tabIndex) {
        0 => Icons.directions_transit,
        1 => Icons.local_parking,
        2 => Icons.event_seat,
        3 => Icons.restaurant,
        4 => Icons.lightbulb,
        _ => Icons.info,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.content,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
