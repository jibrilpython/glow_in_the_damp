import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/enum/my_enums.dart';
import 'package:glow_in_the_damp/models/project_model.dart';
import 'package:glow_in_the_damp/providers/image_provider.dart';
import 'package:glow_in_the_damp/providers/input_provider.dart';
import 'package:glow_in_the_damp/providers/project_provider.dart';
import 'package:glow_in_the_damp/providers/search_provider.dart';
import 'package:glow_in_the_damp/utils/const.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GauzeFilter? _selectedFilter;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;
    final byFilter = _selectedFilter == null
        ? allEntries
        : allEntries
              .where(
                (e) =>
                    filterForAlloy(e.wireAlloy, e.sleeveLayout, e.glassGrade) ==
                    _selectedFilter,
              )
              .toList();
    final entries = ref.watch(searchProvider).filteredList(byFilter);
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Match floating bottom nav: height + margin + breathing room.
    // Use a floor so ScreenUtil shrink on small phones can't tuck the FAB under the bar.
    final fabClearance =
        bottomInset + math.max(70.h + 24.h, 94.0) + 8;
    return Scaffold(
      backgroundColor: kBackground,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabClearance),
        child: FloatingActionButton(
          backgroundColor: kAccent,
          foregroundColor: kBackground,
          elevation: 0,
          onPressed: () {
            ref.read(inputProvider).clearAll();
            ref.read(imageProvider).clearImage();
            Navigator.pushNamed(context, '/add_screen');
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, topPadding + 18.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'THERMODYNAMIC CATALOG',
                        style: AppFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                      _countPill(allEntries.length),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'GLOW\nIN THE DAMP',
                    style: AppFonts.archivo(
                      color: kPrimaryText,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w800,
                      height: .88,
                      letterSpacing: .4,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(width: 28.w, height: 2.h, color: kAccent),
                  SizedBox(height: 14.h),
                  _searchBar(),
                  SizedBox(height: 14.h),
                  _filters(),
                ],
              ),
            ),
          ),
          if (entries.isEmpty)
            SliverToBoxAdapter(child: _emptyState())
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, fabClearance + 72),
              sliver: SliverList.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final mainIndex = ref
                      .read(projectProvider)
                      .entries
                      .indexWhere((e) => e.id == entry.id);
                  return _lampCard(entry, mainIndex);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _countPill(int count) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: kAccentSurface,
      borderRadius: BorderRadius.circular(kRadiusPill),
      border: Border.all(color: kAccent.withAlpha(70)),
    ),
    child: Text(
      '$count SPECIMEN${count == 1 ? '' : 'S'}',
      style: AppFonts.ibmPlexMono(
        color: kAccent,
        fontSize: 9.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _searchBar() => TextField(
    controller: _searchController,
    onChanged: ref.read(searchProvider).setSearchQuery,
    style: AppFonts.ibmPlexMono(color: kPrimaryText, fontSize: 13.sp),
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.search, color: kSecondaryText),
      hintText: 'Search seal, alloy, shaft, notes...',
    ),
  );

  Widget _filters() => SizedBox(
    height: 36.h,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _filterChip('All', null),
        ...GauzeFilter.values.map((f) => _filterChip(f.label, f)),
      ],
    ),
  );

  Widget _filterChip(String label, GauzeFilter? filter) {
    final selected = _selectedFilter == filter;
    final color = filter == null ? kAccent : filterColor(filter);
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36.h,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: selected ? color : kOutline),
        ),
        child: Text(
          label,
          style: AppFonts.ibmPlexMono(
            color: selected ? kBackground : kSecondaryText,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _lampCard(FlameSafetyLampModel entry, int index) {
    final color = entry.safetyMarginK < 0
        ? kError
        : entry.safetyMarginK < 80
        ? kViolet
        : kAccent;
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final hasImage =
        imagePath != null &&
        entry.photoPath.isNotEmpty &&
        File(imagePath).existsSync();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
          boxShadow: const [kShadowSubtle],
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 154.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3.w, color: color),
              ClipRect(
                child: SizedBox(
                  width: 104.w,
                  child: hasImage
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : CustomPaint(painter: _GauzeCardPainter(entry)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.gauzeGridSeal,
                              style: AppFonts.ibmPlexMono(
                                color: kAccent,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${entry.archiveCompleteness}%',
                            style: AppFonts.ibmPlexMono(
                              color: color,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${entry.meshCountPerInch.round()} MESH / d: ${entry.wireDiameterMm.toStringAsFixed(2)}MM / ${entry.alloyCode}',
                        style: AppFonts.archivo(
                          color: kPrimaryText,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        entry.originDisplay,
                        style: AppFonts.ibmPlexSans(
                          color: kSecondaryText,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      _statusPill(entry.dissipationStatus, color),
                      SizedBox(height: 6.h),
                      Text(
                        'CH4 max: ${entry.methaneCeilingPercent.toStringAsFixed(1)}% | q: ${(entry.heatFlux / 1000).toStringAsFixed(1)} kW/m2',
                        style: AppFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(String text, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: color.withAlpha(22),
      borderRadius: BorderRadius.circular(kRadiusPill),
      border: Border.all(color: color.withAlpha(80)),
    ),
    child: Text(
      text,
      style: AppFonts.ibmPlexMono(
        color: color,
        fontSize: 8.sp,
        fontWeight: FontWeight.w800,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _emptyState() => Padding(
    padding: EdgeInsets.only(top: 96.h),
    child: Center(
      child: Column(
        children: [
          SizedBox(
            width: 92.w,
            height: 92.w,
            child: CustomPaint(painter: _EmptyGauzePainter()),
          ),
          SizedBox(height: 24.h),
          Text(
            'NO SPECIMENS IN THIS CATALOG.',
            style: AppFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _GauzeCardPainter extends CustomPainter {
  _GauzeCardPainter(this.entry);
  final FlameSafetyLampModel entry;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = kBackground);
    final spacing = (34 - entry.meshCountPerInch / 1.4).clamp(7, 18).toDouble();
    final wire = Paint()
      ..color = kPrimaryText.withAlpha(120)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * .45, size.height),
        wire,
      );
      canvas.drawLine(
        Offset(size.width - x, 0),
        Offset(size.width - x - size.height * .45, size.height),
        wire,
      );
    }
    final hot = Paint()
      ..shader = RadialGradient(
        colors: [
          kAccent.withAlpha(210),
          kViolet.withAlpha(90),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, hot);
    final critX = size.width * (entry.criticalIsothermMm / 5).clamp(.15, .85);
    canvas.drawLine(
      Offset(critX, 0),
      Offset(critX, size.height),
      Paint()
        ..color = kViolet
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _GauzeCardPainter oldDelegate) =>
      oldDelegate.entry != entry;
}

class _EmptyGauzePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      size.width * .44,
      Paint()
        ..color = kPanelBg
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      c,
      size.width * .44,
      Paint()
        ..color = kOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final wire = Paint()
      ..color = kAccent.withAlpha(160)
      ..strokeWidth = 1;
    for (var i = -4; i <= 4; i++) {
      final o = i * size.width / 9;
      canvas.drawLine(
        Offset(c.dx + o, size.height * .16),
        Offset(c.dx + o, size.height * .84),
        wire,
      );
      canvas.drawLine(
        Offset(size.width * .16, c.dy + o),
        Offset(size.width * .84, c.dy + o),
        wire,
      );
    }
    canvas.drawCircle(c, 9, Paint()..color = kViolet);
    canvas.drawCircle(c, 4, Paint()..color = kAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
