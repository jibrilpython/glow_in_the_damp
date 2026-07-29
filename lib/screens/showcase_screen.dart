import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/enum/my_enums.dart';
import 'package:glow_in_the_damp/models/project_model.dart';
import 'package:glow_in_the_damp/providers/project_provider.dart';
import 'package:glow_in_the_damp/utils/const.dart';

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});
  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _clock = 0;
  double _gauzeTemperature = 310;
  GauzeAlloy _selectedAlloy = GauzeAlloy.heavyIron;
  Offset? _touchPoint;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((e) {
      setState(() => _clock = e.inMilliseconds / 1000);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final sample = entries.isNotEmpty ? entries.first : null;
    final margin = _criticalMargin(sample);
    final statusColor = margin < 0
        ? kError
        : margin < 80
        ? kViolet
        : kAccent;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFF050308),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DISSIPATION MODEL',
                    style: AppFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thermodynamic\nFlame-Cap Simulator',
                    style: AppFonts.archivo(
                      color: kPrimaryText,
                      fontSize: 34,
                      height: .9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Slide gauze temperature and compare alloys. The violet contour marks the critical isotherm where methane ignition risk begins.',
                    style: AppFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Listener(
                onPointerDown: (e) {
                  _touchPoint = e.localPosition;
                  HapticFeedback.selectionClick();
                },
                onPointerMove: (e) =>
                    setState(() => _touchPoint = e.localPosition),
                onPointerUp: (_) => setState(() => _touchPoint = null),
                child: CustomPaint(
                  painter: _ThermalGauzePainter(
                    clock: _clock,
                    temp: _gauzeTemperature,
                    alloy: _selectedAlloy,
                    touchPoint: _touchPoint,
                    margin: margin,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, pad.bottom + 92),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(kRadiusMedium),
                border: Border.all(color: statusColor.withAlpha(160)),
                boxShadow: const [kShadowFloat],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          margin < 0
                              ? 'IGNITION THRESHOLD EXCEEDED'
                              : margin < 80
                              ? 'COMBUSTION VIOLET MARGIN'
                              : 'SAFE DISSIPATION MARGIN',
                          style: AppFonts.ibmPlexMono(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        '${margin.round()}K',
                        style: AppFonts.archivo(
                          color: statusColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GauzeAlloy.values.map((alloy) {
                      final selected = alloy == _selectedAlloy;
                      final color = alloyColor(alloy);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAlloy = alloy),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? color : kBackground,
                            borderRadius: BorderRadius.circular(kRadiusPill),
                            border: Border.all(
                              color: selected ? color : kOutline,
                            ),
                          ),
                          child: Text(
                            alloy.code,
                            style: AppFonts.ibmPlexMono(
                              color: selected ? kBackground : color,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GAUZE TEMPERATURE',
                        style: AppFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${_gauzeTemperature.round()} C',
                        style: AppFonts.ibmPlexMono(
                          color: kAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _gauzeTemperature,
                    min: 80,
                    max: 780,
                    activeColor: statusColor,
                    inactiveColor: kOutline,
                    onChanged: (v) => setState(() => _gauzeTemperature = v),
                  ),
                  Row(
                    children: [
                      _output(
                        'q',
                        '${((_selectedAlloy.conductivity * (_gauzeTemperature - 18) / .00045) / 1000).toStringAsFixed(0)} kW/m2',
                      ),
                      _output(
                        'r_crit',
                        '${(5 - margin.clamp(0, 420) / 100).clamp(.2, 5).toStringAsFixed(1)} mm',
                      ),
                      _output(
                        'CH4 max',
                        '${(2.1 + margin / 90).clamp(.2, 7.5).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _criticalMargin(FlameSafetyLampModel? sample) {
    final mesh = sample?.meshCountPerInch ?? 28;
    final diameter = sample?.wireDiameterMm ?? .45;
    final cooling =
        mesh * 3.2 + _selectedAlloy.conductivity / 8 + (diameter * 22);
    final outer = _gauzeTemperature - cooling + 2.1 * 4;
    return 537 - outer;
  }

  Widget _output(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppFonts.ibmPlexMono(
            color: kPrimaryText,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _ThermalGauzePainter extends CustomPainter {
  _ThermalGauzePainter({
    required this.clock,
    required this.temp,
    required this.alloy,
    required this.touchPoint,
    required this.margin,
  });
  final double clock;
  final double temp;
  final GauzeAlloy alloy;
  final Offset? touchPoint;
  final double margin;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF050308),
    );
    final center = Offset(size.width / 2, size.height * .46);
    final radius = math.min(size.width, size.height) * .34;
    final heat = (temp - 80) / 700;
    final contourPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 9; i++) {
      final t = i / 8;
      contourPaint.color = Color.lerp(
        kAccent,
        kPrimaryText,
        t,
      )!.withAlpha(180 - i * 10);
      final r = radius * (.18 + t * .82) * (1 + math.sin(clock * 2 + i) * .015);
      canvas.drawCircle(center, r, contourPaint);
    }
    final criticalR =
        radius *
        (margin < 0 ? .88 : (1 - margin.clamp(0, 420) / 520)).clamp(.22, .88);
    canvas.drawCircle(
      center,
      criticalR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = margin < 0 ? kError : kViolet,
    );
    final grid = Paint()
      ..color = kPrimaryText.withAlpha(105)
      ..strokeWidth = 1;
    final meshLeft = center.dx - radius;
    final meshTop = center.dy - radius;
    final meshRight = center.dx + radius;
    final meshBottom = center.dy + radius;
    final meshSpan = radius * 2;
    final nominalSpacing = alloy == GauzeAlloy.monel ? 18.0 : 12.0;
    final divisions = math.max(1, (meshSpan / nominalSpacing).round());
    final spacing = meshSpan / divisions;
    // Even spacing so the last line lands on the right/bottom edge.
    for (var i = 0; i <= divisions; i++) {
      final x = meshLeft + spacing * i;
      canvas.drawLine(Offset(x, meshTop), Offset(x, meshBottom), grid);
    }
    for (var i = 0; i <= divisions; i++) {
      final y = meshTop + spacing * i;
      canvas.drawLine(Offset(meshLeft, y), Offset(meshRight, y), grid);
    }
    canvas.drawCircle(
      center,
      radius * .26,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius * .7,
          [
            kAccent.withAlpha((170 * heat).round()),
            kViolet.withAlpha(80),
            Colors.transparent,
          ],
          const [0.0, 0.45, 1.0],
        ),
    );
    if (touchPoint != null) {
      canvas.drawCircle(
        touchPoint!,
        42,
        Paint()..color = kAccent.withAlpha(25),
      );
      canvas.drawCircle(touchPoint!, 8, Paint()..color = kAccent);
    }
  }

  @override
  bool shouldRepaint(covariant _ThermalGauzePainter oldDelegate) => true;
}
