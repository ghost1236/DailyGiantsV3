import 'package:flutter/material.dart';
import '../../data/stadium_models.dart';
import 'stadium_info_list.dart';

class TransportTab extends StatelessWidget {
  final List<StadiumInfo> items;
  const TransportTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return StadiumInfoList(
      items: items,
      emptyIcon: Icons.directions_bus_outlined,
      emptyMessage: '교통 정보가 없습니다',
    );
  }
}
