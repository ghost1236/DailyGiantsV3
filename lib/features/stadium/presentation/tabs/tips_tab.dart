import 'package:flutter/material.dart';
import '../../data/stadium_models.dart';
import 'stadium_info_list.dart';

class TipsTab extends StatelessWidget {
  final List<StadiumInfo> items;
  const TipsTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return StadiumInfoList(
      items: items,
      emptyIcon: Icons.lightbulb_outlined,
      emptyMessage: '꿀팁 정보가 없습니다',
    );
  }
}
