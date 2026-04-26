import 'package:flutter/material.dart';
import '../../data/stadium_models.dart';
import 'stadium_info_list.dart';

class ParkingTab extends StatelessWidget {
  final List<StadiumInfo> items;
  const ParkingTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return StadiumInfoList(
      items: items,
      emptyIcon: Icons.local_parking_outlined,
      emptyMessage: '주차 정보가 없습니다',
    );
  }
}
