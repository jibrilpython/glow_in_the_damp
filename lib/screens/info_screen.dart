import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/models/project_model.dart';
import 'package:glow_in_the_damp/providers/image_provider.dart';
import 'package:glow_in_the_damp/providers/project_provider.dart';
import 'package:glow_in_the_damp/utils/const.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    if (index < 0 || index >= projectProv.entries.length) {
      return const Scaffold(body: Center(child: Text('SPECIMEN NOT FOUND')));
    }
    final entry = projectProv.entries[index];
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final hasImage =
        imagePath != null &&
        entry.photoPath.isNotEmpty &&
        File(imagePath).existsSync();
    final stateColor = entry.safetyMarginK < 0
        ? kError
        : entry.safetyMarginK < 80
        ? kViolet
        : kAccent;
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              projectProv.fillInput(ref, index);
              Navigator.pushNamed(
                context,
                '/add_screen',
                arguments: {'isEdit': true, 'currentIndex': index},
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () => _delete(context, projectProv),
            icon: const Icon(Icons.delete_outline, color: kError),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 310.h,
              margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                border: Border.all(color: kOutline),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Image.file(File(imagePath), fit: BoxFit.cover)
                  : CustomPaint(painter: _HeroGauzePainter(entry)),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 130.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  entry.gauzeGridSeal,
                  style: AppFonts.ibmPlexMono(
                    color: kAccent,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${entry.meshCountPerInch.round()} MESH ${entry.wireAlloy.label}'
                      .toUpperCase(),
                  style: AppFonts.archivo(
                    color: kPrimaryText,
                    fontSize: 32.sp,
                    height: .95,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${entry.originDisplay} | ${entry.sleeveLayout.label}',
                  style: AppFonts.ibmPlexSans(
                    color: kSecondaryText,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                _dissipationCard(entry, stateColor),
                SizedBox(height: 20.h),
                _section('GAUZE AND HOUSING'),
                _spec(
                  'Wire Mesh Matrix',
                  '${entry.meshCountPerInch.round()} wires/in, ${entry.aperturesPerSquareInch.round()} apertures/in2',
                  Icons.grid_on,
                  kAccent,
                ),
                _spec(
                  'Wire Material Alloy',
                  '${entry.wireAlloy.label} (${entry.wireAlloy.code})',
                  Icons.construction,
                  alloyColor(entry.wireAlloy),
                ),
                _spec(
                  'Inner / Outer Sleeve',
                  entry.sleeveLayout.label,
                  Icons.filter_alt_outlined,
                  kViolet,
                ),
                _spec(
                  'Air Inlet Ring',
                  entry.airInletPattern.label,
                  Icons.air,
                  kAccent,
                ),
                _spec(
                  'Glass Cylinder',
                  entry.glassGrade.label,
                  Icons.panorama_fish_eye,
                  kSecondaryText,
                ),
                _spec(
                  'Fuel Lock / Blend',
                  '${entry.fuelLockClass.label} | ${entry.fuelBlend.label}',
                  Icons.lock_outline,
                  kViolet,
                ),
                _spec(
                  'Mechanical Dimensions',
                  '${entry.heightMm.round()} mm high | ${entry.dryMassGrams.round()} g dry mass',
                  Icons.straighten,
                  kAccent,
                ),
                SizedBox(height: 18.h),
                _section('PROVENANCE AND NOTES'),
                _note(entry.originDisplay),
                if (entry.notes.isNotEmpty) _note(entry.notes),
                if (entry.tags.isNotEmpty)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: entry.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag.toUpperCase()),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dissipationCard(FlameSafetyLampModel entry, Color color) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      border: Border.all(color: color.withAlpha(120)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.dissipationStatus,
                style: AppFonts.ibmPlexMono(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${entry.safetyMarginK.round()}K',
              style: AppFonts.archivo(
                color: color,
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusPill),
          child: LinearProgressIndicator(
            value: (entry.safetyMarginK.clamp(0, 420) / 420),
            minHeight: 9.h,
            color: color,
            backgroundColor: kOutline,
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            _miniMetric(
              'q',
              '${(entry.heatFlux / 1000).toStringAsFixed(1)} kW/m2',
            ),
            _miniMetric('T_outer', '${entry.outerGauzeTemperatureC.round()} C'),
            _miniMetric(
              'CH4 max',
              '${entry.methaneCeilingPercent.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    ),
  );

  Widget _miniMetric(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 8.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppFonts.ibmPlexMono(
            color: kPrimaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );

  Widget _section(String label) => Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Text(
      label,
      style: AppFonts.ibmPlexMono(
        color: kSecondaryText,
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    ),
  );
  Widget _spec(String label, String value, IconData icon, Color color) =>
      Container(
        margin: EdgeInsets.only(bottom: 9.h),
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    value,
                    style: AppFonts.ibmPlexSans(
                      color: kPrimaryText,
                      fontSize: 13.sp,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _note(String text) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(15.w),
    decoration: BoxDecoration(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      border: Border.all(color: kOutline),
    ),
    child: Text(
      text,
      style: AppFonts.ibmPlexSans(
        color: kPrimaryText,
        fontSize: 14.sp,
        height: 1.55,
      ),
    ),
  );

  void _delete(BuildContext context, ProjectNotifier projectProv) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove specimen?'),
      content: const Text(
        'This will remove the lamp from the thermodynamic archive.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            projectProv.deleteEntry(index);
            Navigator.pop(ctx);
            Navigator.pop(context);
          },
          child: const Text('Remove'),
        ),
      ],
    ),
  );
}

class _HeroGauzePainter extends CustomPainter {
  _HeroGauzePainter(this.entry);
  final FlameSafetyLampModel entry;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = kBackground);
    final center = Offset(size.width / 2, size.height / 2);
    final wire = Paint()
      ..color = kPrimaryText.withAlpha(130)
      ..strokeWidth = 1.1;
    final spacing = (38 - entry.meshCountPerInch / 1.2).clamp(7, 18).toDouble();
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * .5, size.height),
        wire,
      );
      canvas.drawLine(
        Offset(size.width - x, 0),
        Offset(size.width - x - size.height * .5, size.height),
        wire,
      );
    }
    canvas.drawCircle(
      center,
      size.shortestSide * .38,
      Paint()..color = kAccent.withAlpha(42),
    );
    canvas.drawCircle(
      center,
      size.shortestSide * .24,
      Paint()..color = kViolet.withAlpha(72),
    );
    canvas.drawCircle(
      center,
      size.shortestSide * .11,
      Paint()..color = kAccent.withAlpha(160),
    );
  }

  @override
  bool shouldRepaint(covariant _HeroGauzePainter oldDelegate) =>
      oldDelegate.entry != entry;
}
