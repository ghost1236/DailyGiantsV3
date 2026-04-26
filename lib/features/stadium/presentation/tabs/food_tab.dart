import 'package:flutter/material.dart';
import '../../data/stadium_models.dart';
import 'stadium_info_list.dart';

class FoodTab extends StatelessWidget {
  final List<StadiumInfo> items;
  const FoodTab({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return StadiumInfoList(
      items: items,
      emptyIcon: Icons.restaurant_outlined,
      emptyMessage: '맛집 정보가 없습니다',
    );
  }
}
