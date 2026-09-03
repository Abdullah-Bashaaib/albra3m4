import 'package:flutter/material.dart';

import 'user_stat_card.dart';

class UserStatsRow extends StatelessWidget {
  final int total;
  final int active;
  final int teachers;
  final int parents;

  const UserStatsRow({
    super.key,
    required this.total,
    required this.active,
    required this.teachers,
    required this.parents,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SizedBox(
            width: 140,
            child: UserStatCard(
              label: 'إجمالي المستخدمين',
              value: '$total',
              icon: Icons.groups_rounded,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: UserStatCard(
              label: 'حسابات نشطة',
              value: '$active',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF2ECC71),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: UserStatCard(
              label: 'المعلمات',
              value: '$teachers',
              icon: Icons.school_rounded,
              color: const Color(0xFFFF9F43),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: UserStatCard(
              label: 'أولياء الأمور',
              value: '$parents',
              icon: Icons.family_restroom_rounded,
              color: const Color(0xFF00B8D9),
            ),
          ),
        ],
      ),
    );
  }
}
