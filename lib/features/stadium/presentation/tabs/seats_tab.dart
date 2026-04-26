import 'package:flutter/material.dart';
import '../../data/stadium_models.dart';
import 'stadium_info_list.dart';

class SeatsTab extends StatelessWidget {
  final List<StadiumInfo> items;
  const SeatsTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return StadiumInfoList(
      items: items,
      emptyIcon: Icons.event_seat_outlined,
      emptyMessage: '좌석 정보가 없습니다',
    );
  }
}
