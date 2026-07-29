import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/enum/my_enums.dart';
import 'package:glow_in_the_damp/models/project_model.dart';
import 'package:glow_in_the_damp/providers/project_provider.dart';
import 'package:glow_in_the_damp/utils/const.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(projectProvider).entries;
    final topPadding = MediaQuery.paddingOf(context).top;
    if (entries.isEmpty) {
      return Scaffold(backgroundColor: kBackground, body: _empty());
    }

    final alloyCounts = <GauzeAlloy, int>{};
    var safe = 0;
    var critical = 0;
    var marginTotal = 0.0;
    var heatFluxTotal = 0.0;
    var flameTempTotal = 0.0;
    var gauzeTempTotal = 0.0;
    var completenessTotal = 0;
    for (final e in entries) {
      alloyCounts[e.wireAlloy] = (alloyCounts[e.wireAlloy] ?? 0) + 1;
      if (e.safetyMarginK > 80) safe++;
      if (e.safetyMarginK < 0) critical++;
      marginTotal += e.safetyMarginK;
      heatFluxTotal += e.heatFlux;
      flameTempTotal += e.flameTemperatureC;
      gauzeTempTotal += e.outerGauzeTemperatureC;
      completenessTotal += e.archiveCompleteness;
    }
    final n = entries.length;
    final avgMargin = (marginTotal / n).round();
    final avgHeatFlux = heatFluxTotal / n;
    final avgFlame = (flameTempTotal / n).round();
    final avgGauze = (gauzeTempTotal / n).round();
    final avgCompleteness = (completenessTotal / n).round();

    final recent = List<FlameSafetyLampModel>.from(entries)
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, topPadding + 16.h, 20.w, 140.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  SizedBox(height: 24.h),
                  _metricRow(n, safe, critical),
                  SizedBox(height: 20.h),
                  _sectionLabel('SAFETY MARGIN'),
                  SizedBox(height: 10.h),
                  _marginCard(avgMargin),
                  SizedBox(height: 20.h),
                  _sectionLabel('ALLOY DISTRIBUTION'),
                  SizedBox(height: 10.h),
                  _alloyCard(alloyCounts, n),
                  SizedBox(height: 20.h),
                  _sectionLabel('THERMAL OVERVIEW'),
                  SizedBox(height: 10.h),
                  _thermalCard(avgFlame, avgGauze, avgMargin, avgHeatFlux, avgCompleteness),
                  SizedBox(height: 20.h),
                  _sectionLabel('RECENT SPECIMENS'),
                  SizedBox(height: 10.h),
                  ...recent
                      .take(5)
                      .map((e) => _recentTile(context, e, entries.indexWhere((x) => x.id == e.id))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(width: 20.w, height: 2.h, color: kAccent),
          SizedBox(width: 8.w),
          Text(
            'ANALYTICS',
            style: AppFonts.ibmPlexMono(
              color: kAccent,
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
            ),
          ),
        ],
      ),
      SizedBox(height: 10.h),
      Text(
        'DISSIPATION\nREGISTER',
        style: AppFonts.archivo(
          color: kPrimaryText,
          fontSize: 42.sp,
          height: .9,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _sectionLabel(String label) => Text(
    label,
    style: AppFonts.ibmPlexMono(
      color: kSecondaryText,
      fontSize: 10.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.3,
    ),
  );

  Widget _metricRow(int total, int safe, int critical) => Row(
    children: [
      _statCard('TOTAL', total.toString(), kAccent, Icons.grid_view_rounded, null),
      SizedBox(width: 8.w),
      _statCard('SAFE', safe.toString(), kAccent,
          Icons.shield_rounded, safe / math.max(total, 1)),
      SizedBox(width: 8.w),
      _statCard('CRITICAL', critical.toString(), kError,
          Icons.warning_amber_rounded, null),
    ],
  );

  Widget _statCard(String label, String value, Color color, IconData icon, double? ratio) {
    final ratioColor = ratio != null
        ? ratio > 0.5
            ? kAccent
            : ratio > 0.25
                ? kViolet
                : kError
        : null;
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: kOutline),
        ),
        child: Column(
          children: [
            Icon(icon, color: color.withAlpha(160), size: 18.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: AppFonts.ibmPlexMono(
                color: color,
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 8.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: .6,
              ),
            ),
            if (ratio != null) ...[
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 3.h,
                  color: ratioColor,
                  backgroundColor: kOutline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _marginCard(int margin) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(kRadiusStandard),
      border: Border.all(color: kOutline),
      boxShadow: const [kShadowSignal],
    ),
    child: Column(
      children: [
        SizedBox(
          height: 180.h,
          width: double.infinity,
          child: CustomPaint(painter: _MarginGaugePainter(margin)),
        ),
        SizedBox(height: 4.h),
        Text(
          'AVERAGE SAFETY MARGIN',
          style: AppFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 8.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );

  Widget _alloyCard(Map<GauzeAlloy, int> data, int total) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(kRadiusStandard),
      border: Border.all(color: kOutline),
    ),
    child: Column(
      children: GauzeAlloy.values.map((alloy) {
        final count = data[alloy] ?? 0;
        final frac = total == 0 ? 0.0 : count / total;
        final ac = alloyColor(alloy);
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ac.withAlpha(26),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      alloy.code,
                      style: AppFonts.ibmPlexMono(
                        color: ac,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      alloy.label,
                      style: AppFonts.ibmPlexSans(
                        color: kPrimaryText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '$count',
                    style: AppFonts.ibmPlexMono(
                      color: kPrimaryText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  SizedBox(
                    width: 36.w,
                    child: Text(
                      '${(frac * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: AppFonts.ibmPlexMono(
                        color: kSecondaryText,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: LinearProgressIndicator(
                  value: frac,
                  minHeight: 4.h,
                  color: ac,
                  backgroundColor: kOutline,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );

  Widget _thermalCard(
    int avgFlame,
    int avgGauze,
    int avgMargin,
    double avgHeatFlux,
    int avgCompleteness,
  ) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(kRadiusStandard),
      border: Border.all(color: kOutline),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _thermalTile('FLAME', '$avgFlame°C', kAccent, 'Avg flame temperature'),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _thermalTile('GAUZE', '$avgGauze°C', kViolet, 'Avg outer gauze temp'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _thermalTile('MARGIN', '${avgMargin}K',
                  avgMargin < 0 ? kError : avgMargin < 80 ? kViolet : kAccent, 'Avg safety margin'),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _thermalTile('FLUX', '${(avgHeatFlux / 1000).toStringAsFixed(1)} kW/m²',
                  kSecondaryText, 'Avg heat flux density'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _thermalTile('COMPLETENESS', '$avgCompleteness%',
                  avgCompleteness > 70 ? kAccent : kViolet, 'Avg archive completeness'),
            ),
            SizedBox(width: 10.w),
            Expanded(child: Container()),
          ],
        ),
      ],
    ),
  );

  Widget _thermalTile(String label, String value, Color color, String subtitle) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: kBackground,
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      border: Border.all(color: kOutline),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 8.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: AppFonts.archivo(
            color: color,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: AppFonts.ibmPlexSans(
            color: kSecondaryText.withAlpha(150),
            fontSize: 8.sp,
          ),
        ),
      ],
    ),
  );

  Widget _recentTile(BuildContext context, FlameSafetyLampModel entry, int index) {
    final color = entry.safetyMarginK < 0
        ? kError
        : entry.safetyMarginK < 80
            ? kViolet
            : kAccent;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 10.w, 12.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: kOutline),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: alloyColor(entry.wireAlloy).withAlpha(26),
                borderRadius: BorderRadius.circular(kRadiusSubtle),
              ),
              child: Text(
                entry.alloyCode,
                style: AppFonts.ibmPlexMono(
                  color: alloyColor(entry.wireAlloy),
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.gauzeGridSeal,
                    style: AppFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: color.withAlpha(22),
                          borderRadius: BorderRadius.circular(kRadiusPill),
                        ),
                        child: Text(
                          entry.dissipationStatus,
                          style: AppFonts.ibmPlexMono(
                            color: color,
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${entry.meshCountPerInch.round()}M',
                        style: AppFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: kOutline,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: const Icon(Icons.chevron_right, color: kSecondaryText, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.analytics_outlined, color: kOutline, size: 48.sp),
        SizedBox(height: 16.h),
        Text(
          'NO DATA YET.',
          style: AppFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _MarginGaugePainter extends CustomPainter {
  _MarginGaugePainter(this.margin);
  final int margin;
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;
    final center = Offset(cx, cy);
    final radius = math.min(size.width, size.height) * 0.30;

    final color = margin < 0
        ? kError
        : margin < 80
            ? kViolet
            : kAccent;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      base..color = kOutline,
    );

    final sweep = math.pi * (margin.clamp(0, 420) / 420);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweep,
      false,
      base..color = color.withAlpha(180),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweep,
      false,
      base
        ..color = Colors.transparent
        ..shader = SweepGradient(
          startAngle: math.pi,
          endAngle: math.pi + sweep,
          colors: [
            color.withAlpha(60),
            color,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius + 12))
        ..strokeWidth = 6,
    );

    final glow = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, radius * .26, glow..color = color.withAlpha(18));

    final tp = TextPainter(
      text: TextSpan(
        text: '${margin}K',
        style: AppFonts.archivo(
          color: color,
          fontSize: 40,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));

    final label = TextPainter(
      text: TextSpan(
        text: 'margin',
        style: AppFonts.ibmPlexMono(
          color: kSecondaryText,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(
      canvas,
      Offset(cx - label.width / 2, cy + tp.height / 2 + 4),
    );
  }

  @override
  bool shouldRepaint(covariant _MarginGaugePainter oldDelegate) =>
      oldDelegate.margin != margin;
}
