import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/screens/home_screen.dart';
import 'package:glow_in_the_damp/screens/mine_map_screen.dart';
import 'package:glow_in_the_damp/screens/showcase_screen.dart';
import 'package:glow_in_the_damp/screens/stats_screen.dart';
import 'package:glow_in_the_damp/utils/const.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});
  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  final _screens = const [
    HomeScreen(),
    ShowcaseScreen(),
    MineMapScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildNav()),
        ],
      ),
    );
  }

  Widget _buildNav() => Container(
    height: 70.h,
    margin: EdgeInsets.fromLTRB(
      12.w,
      0,
      12.w,
      MediaQuery.of(context).padding.bottom + 12.h,
    ),
    padding: EdgeInsets.symmetric(horizontal: 6.w),
    decoration: BoxDecoration(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(kRadiusPill),
      border: Border.all(color: kOutline),
      boxShadow: const [kShadowFloat],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _navItem(0, Icons.view_agenda_outlined, Icons.view_agenda, 'Catalog'),
        _navItem(
          1,
          Icons.local_fire_department_outlined,
          Icons.local_fire_department,
          'Model',
        ),
        _navItem(2, Icons.map_outlined, Icons.map, 'Map'),
        _navItem(3, Icons.analytics_outlined, Icons.analytics, 'Log'),
      ],
    ),
  );

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: selected ? 12.w : 10.w),
        decoration: BoxDecoration(
          color: selected ? kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? kBackground : kSecondaryText,
              size: 20.sp,
            ),
            if (selected) ...[
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppFonts.ibmPlexSans(
                  color: kBackground,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
