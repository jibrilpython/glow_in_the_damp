import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glow_in_the_damp/models/project_model.dart';
import 'package:glow_in_the_damp/providers/image_provider.dart';
import 'package:glow_in_the_damp/providers/input_provider.dart';
import 'package:glow_in_the_damp/providers/project_provider.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/utils/const.dart';

class MineMapScreen extends ConsumerStatefulWidget {
  const MineMapScreen({super.key});

  @override
  ConsumerState<MineMapScreen> createState() => _MineMapScreenState();
}

class _MineMapScreenState extends ConsumerState<MineMapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _thermalClock;
  final List<_HeatTrace> _heatTraces = [];
  final Map<int, Offset> _nodeOffsets = {};
  int? _draggingIndex;
  int? _focusedIndex;
  Offset? _dragPoint;
  double _ambientTemp = 312;
  double _thermalLoad = .28;

  @override
  void initState() {
    super.initState();
    _thermalClock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(_coolMatrix);
  }

  @override
  void dispose() {
    _thermalClock.dispose();
    super.dispose();
  }

  void _coolMatrix() {
    if (!mounted) return;
    if (ref.read(projectProvider).entries.isEmpty) {
      if (_thermalClock.isAnimating) {
        _thermalClock.stop();
        _heatTraces.clear();
        _nodeOffsets.clear();
        _draggingIndex = null;
        _focusedIndex = null;
        _dragPoint = null;
        _thermalLoad = .28;
      }
      return;
    }
    final now = DateTime.now();
    _heatTraces.removeWhere((trace) {
      return now.difference(trace.createdAt).inMilliseconds > 1700;
    });
    _thermalLoad = (_thermalLoad * .982).clamp(.18, 1.0);
    setState(() {});
  }

  void _ensureClockRunning() {
    if (_thermalClock.isAnimating) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(projectProvider).entries.isEmpty) return;
      if (!_thermalClock.isAnimating) _thermalClock.repeat();
    });
  }

  Offset _clampNodePosition(Offset point, Size size) {
    final horizontalPadding = 42.w;
    final topLimit = 186.h;
    final bottomLimit = size.height - 232.h;
    return Offset(
      point.dx.clamp(horizontalPadding, size.width - horizontalPadding),
      point.dy.clamp(topLimit, math.max(topLimit, bottomLimit)),
    );
  }

  Offset _nodePosition(int index, int count, Size size) {
    final override = _nodeOffsets[index];
    if (override != null) return _clampNodePosition(override, size);

    final safeTop = 156.h;
    final safeBottom = 210.h;
    final availableHeight = math.max(180.0, size.height - safeTop - safeBottom);
    final rowCount = math.max(1, (count / 2).ceil());
    final row = index ~/ 2;
    final leftSide = index.isEven;
    final x = size.width * (leftSide ? .18 : .82);
    final rowGap = availableHeight / rowCount;
    final y = safeTop + rowGap * (row + .5);
    final weave = math.sin(_thermalClock.value * math.pi * 2 + index) * 3;
    return Offset(x + weave, y);
  }

  Rect _chamberRect(Size size) {
    final side = math.min(132.h, size.width * .38);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * .48),
      width: side,
      height: side,
    );
  }

  int? _hitNode(Offset local, List<FlameSafetyLampModel> entries, Size size) {
    for (var i = entries.length - 1; i >= 0; i--) {
      final point = i == _draggingIndex && _dragPoint != null
          ? _dragPoint!
          : _nodePosition(i, entries.length, size);
      if ((point - local).distance <= 34) return i;
    }
    return null;
  }

  void _strikeHeat(Offset point, {double intensity = .38}) {
    _heatTraces.add(_HeatTrace(point, intensity));
    _thermalLoad = (_thermalLoad + intensity * .16).clamp(.18, 1.0);
  }

  void _handlePanStart(
    DragStartDetails details,
    List<FlameSafetyLampModel> entries,
    Size size,
  ) {
    final hit = _hitNode(details.localPosition, entries, size);
    if (hit != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _draggingIndex = hit;
        _dragPoint = _clampNodePosition(details.localPosition, size);
      });
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _strikeHeat(details.localPosition, intensity: .55));
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (_draggingIndex != null) {
      setState(
        () => _dragPoint = _clampNodePosition(details.localPosition, size),
      );
      return;
    }
    setState(() => _strikeHeat(details.localPosition));
  }

  void _handlePanEnd(Size size) {
    if (_draggingIndex != null) {
      final chamber = _chamberRect(size).inflate(26);
      final locked = _dragPoint != null && chamber.contains(_dragPoint!);
      HapticFeedback.heavyImpact();
      setState(() {
        if (_dragPoint != null && _draggingIndex != null) {
          _nodeOffsets[_draggingIndex!] = _dragPoint!;
        }
        _focusedIndex = locked ? _draggingIndex : _focusedIndex;
        _draggingIndex = null;
        _dragPoint = null;
      });
      return;
    }
    HapticFeedback.selectionClick();
  }

  void _tapNode(
    TapDownDetails details,
    List<FlameSafetyLampModel> entries,
    Size size,
  ) {
    final hit = _hitNode(details.localPosition, entries, size);
    setState(() {
      _strikeHeat(details.localPosition, intensity: hit == null ? .32 : .7);
      if (hit != null) _focusedIndex = hit;
    });
    if (hit == null) {
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final hasEntries = entries.isNotEmpty;

    if (!hasEntries) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0C),
        body: _EmptyMatrixState(
          onRegister: () {
            ref.read(inputProvider).clearAll();
            ref.read(imageProvider).clearImage();
            Navigator.pushNamed(context, '/add_screen');
          },
        ),
      );
    }

    _ensureClockRunning();

    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final focused =
        _focusedIndex != null &&
            _focusedIndex! >= 0 &&
            _focusedIndex! < entries.length
        ? entries[_focusedIndex!]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final chamber = _chamberRect(size);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _tapNode(details, entries, size),
            onPanStart: (details) => _handlePanStart(details, entries, size),
            onPanUpdate: (details) => _handlePanUpdate(details, size),
            onPanEnd: (_) => _handlePanEnd(size),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GauzeMatrixPainter(
                      entries: entries,
                      heatTraces: List<_HeatTrace>.from(_heatTraces),
                      thermalLoad: _thermalLoad,
                      chamber: chamber,
                      clock: _thermalClock.value,
                      selectedIndex: _focusedIndex,
                      draggingIndex: _draggingIndex,
                      dragPoint: _dragPoint,
                      nodePosition: (index) =>
                          _nodePosition(index, entries.length, size),
                    ),
                  ),
                ),
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  top: topPadding + 18.h,
                  child: _MatrixHeader(
                    count: entries.length,
                    thermalLoad: _thermalLoad,
                  ),
                ),
                Positioned(
                  left: chamber.left,
                  top: chamber.top,
                  width: chamber.width,
                  height: chamber.height,
                  child: IgnorePointer(
                    child: _TestChamberLabel(active: focused != null),
                  ),
                ),
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: bottomPadding + 86.h,
                  child: focused == null
                      ? _InstructionPanel()
                      : _FocusPanel(
                          entry: focused,
                          ambientTemp: _ambientTemp,
                          onClose: () {
                            HapticFeedback.selectionClick();
                            setState(() => _focusedIndex = null);
                          },
                          onOpenRecord: () {
                            Navigator.pushNamed(
                              context,
                              '/info_screen',
                              arguments: _focusedIndex,
                            );
                          },
                          onAmbientChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _ambientTemp = value;
                              _thermalLoad = (_thermalLoad + .04).clamp(
                                .18,
                                1.0,
                              );
                            });
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeatTrace {
  _HeatTrace(this.point, this.intensity) : createdAt = DateTime.now();

  final Offset point;
  final double intensity;
  final DateTime createdAt;

  double get life {
    final age = DateTime.now().difference(createdAt).inMilliseconds / 1700;
    return (1 - age).clamp(0.0, 1.0);
  }
}

class _MatrixHeader extends StatelessWidget {
  const _MatrixHeader({required this.count, required this.thermalLoad});

  final int count;
  final double thermalLoad;

  @override
  Widget build(BuildContext context) {
    final loadPct = (thermalLoad * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'GAUZE MATRIX',
                style: AppFonts.ibmPlexMono(
                  color: const Color(0xFFD4AF37),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
            ),
            _HeaderPill(label: '$count NODES'),
            SizedBox(width: 8.w),
            _HeaderPill(label: 'LOAD $loadPct%'),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          'Thermal\nDissipation Matrix',
          style: AppFonts.archivo(
            color: kPrimaryText,
            fontSize: 34.sp,
            fontWeight: FontWeight.w800,
            height: .88,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Swipe to strike the gauze with firedamp heat. Drag a specimen into the chamber for its flash-point stress test.',
          style: AppFonts.ibmPlexSans(
            color: const Color(0xFF8C92AC),
            fontSize: 12.sp,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0x22140F18),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: const Color(0x44D4AF37)),
      ),
      child: Text(
        label,
        style: AppFonts.ibmPlexMono(
          color: const Color(0xFFD4AF37),
          fontSize: 8.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TestChamberLabel extends StatelessWidget {
  const _TestChamberLabel({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: active ? const Color(0x337A3A9A) : const Color(0x18000000),
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: active ? kViolet : const Color(0x668C92AC)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            active ? 'SPECIMEN LOCKED' : 'TEST CHAMBER',
            textAlign: TextAlign.center,
            style: AppFonts.ibmPlexMono(
              color: active ? kViolet : const Color(0xFF8C92AC),
              fontSize: 9.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            active ? 'Flash-point\nload below' : 'Drag node\ninside',
            textAlign: TextAlign.center,
            style: AppFonts.ibmPlexSans(
              color: kSecondaryText,
              fontSize: 10.sp,
              height: 1.18,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xEE0F0C10),
        borderRadius: BorderRadius.circular(kRadiusMedium),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowFloat],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Color(0xFFFF3300),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Swipe to inject heat. Tap a mesh node for a heat bead, or drag one into the center chamber.',
              style: AppFonts.ibmPlexSans(
                color: kPrimaryText,
                fontSize: 12.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMatrixState extends StatelessWidget {
  const _EmptyMatrixState({required this.onRegister});
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, top + 28.h, 24.w, bottom + 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GAUZE MATRIX',
            style: AppFonts.ibmPlexMono(
              color: const Color(0xFFD4AF37),
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Thermal\nDissipation Matrix',
            style: AppFonts.archivo(
              color: kPrimaryText,
              fontSize: 34.sp,
              fontWeight: FontWeight.w800,
              height: .88,
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 108.w,
                  height: 108.w,
                  child: CustomPaint(painter: _EmptyMatrixPainter()),
                ),
                SizedBox(height: 22.h),
                Text(
                  'NO SPECIMENS IN THIS MATRIX.',
                  textAlign: TextAlign.center,
                  style: AppFonts.ibmPlexMono(
                    color: const Color(0xFF8C92AC),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Register a gauze specimen to seed heat-sink nodes and unlock flash-point testing.',
                  textAlign: TextAlign.center,
                  style: AppFonts.ibmPlexSans(
                    color: kSecondaryText,
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 22.h),
                ElevatedButton.icon(
                  onPressed: onRegister,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Register specimen'),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _EmptyMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF111016)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF8C92AC).withAlpha(120),
    );
    final wire = Paint()
      ..color = const Color(0xFF8C92AC).withAlpha(90)
      ..strokeWidth = 1;
    const spacing = 10.0;
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius - 2)),
    );
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), wire);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), wire);
    }
    canvas.restore();
    canvas.drawCircle(
      center,
      radius * .28,
      Paint()
        ..color = const Color(0xFFD4AF37).withAlpha(40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FocusPanel extends StatelessWidget {
  const _FocusPanel({
    required this.entry,
    required this.ambientTemp,
    required this.onClose,
    required this.onOpenRecord,
    required this.onAmbientChanged,
  });

  final FlameSafetyLampModel entry;
  final double ambientTemp;
  final VoidCallback onClose;
  final VoidCallback onOpenRecord;
  final ValueChanged<double> onAmbientChanged;

  @override
  Widget build(BuildContext context) {
    final sound = entry.safetyMarginK >= 80;
    final stressColor = sound
        ? const Color(0xFFD4AF37)
        : entry.safetyMarginK >= 0
        ? kViolet
        : const Color(0xFFFF3300);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xF20F0C10),
        borderRadius: BorderRadius.circular(kRadiusMedium),
        border: Border.all(color: stressColor.withAlpha(170)),
        boxShadow: const [kShadowFloat],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.gauzeGridSeal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.ibmPlexMono(
                    color: stressColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                sound ? 'FLAME HELD' : 'THRESHOLD STRESS',
                style: AppFonts.ibmPlexMono(
                  color: stressColor,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: kBackground.withAlpha(180),
                    shape: BoxShape.circle,
                    border: Border.all(color: kOutline),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: kSecondaryText,
                    size: 15.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          Text(
            entry.originDisplay,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.archivo(
              color: kPrimaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _Metric(
                label: 'aperture',
                value: '${entry.meshCountPerInch.round()} mesh',
              ),
              _Metric(
                label: 'wire',
                value: '${entry.wireDiameterMm.toStringAsFixed(2)}mm',
              ),
              _Metric(
                label: 'k',
                value: '${entry.wireAlloy.conductivity.round()}',
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _Metric(
                label: 'T_outer',
                value: '${entry.outerGauzeTemperatureC.round()}C',
              ),
              _Metric(
                label: 'margin',
                value: '${entry.safetyMarginK.round()}K',
              ),
              _Metric(
                label: 'CH4 max',
                value: '${entry.methaneCeilingPercent.toStringAsFixed(1)}%',
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                'FLASH-POINT LIMIT',
                style: AppFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${ambientTemp.round()} C',
                style: AppFonts.ibmPlexMono(
                  color: stressColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Slider(
            value: ambientTemp.clamp(120, 537),
            min: 120,
            max: 537,
            activeColor: stressColor,
            inactiveColor: kOutline,
            onChanged: onAmbientChanged,
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenRecord,
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Open record'),
              style: OutlinedButton.styleFrom(
                foregroundColor: stressColor,
                side: BorderSide(color: stressColor.withAlpha(150)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            style: AppFonts.ibmPlexMono(
              color: kPrimaryText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GauzeMatrixPainter extends CustomPainter {
  _GauzeMatrixPainter({
    required this.entries,
    required this.heatTraces,
    required this.thermalLoad,
    required this.chamber,
    required this.clock,
    required this.selectedIndex,
    required this.draggingIndex,
    required this.dragPoint,
    required this.nodePosition,
  });

  final List<FlameSafetyLampModel> entries;
  final List<_HeatTrace> heatTraces;
  final double thermalLoad;
  final Rect chamber;
  final double clock;
  final int? selectedIndex;
  final int? draggingIndex;
  final Offset? dragPoint;
  final Offset Function(int index) nodePosition;

  static const _pitch = Color(0xFF0A0A0C);
  static const _red = Color(0xFFFF3300);
  static const _brass = Color(0xFFD4AF37);
  static const _grey = Color(0xFF8C92AC);

  @override
  void paint(Canvas canvas, Size size) {
    _paintThermalBackground(canvas, size);
    _paintWovenGauze(canvas, size);
    _paintHeatTraces(canvas);
    _paintChamber(canvas);
    _paintNodes(canvas, size);
  }

  void _paintThermalBackground(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _pitch);
    final center = Offset(
      size.width * (.5 + math.sin(clock * math.pi * 2) * .08),
      size.height * (.48 + math.cos(clock * math.pi * 2) * .05),
    );
    final shader =
        RadialGradient(
          colors: [
            _red.withAlpha((42 + thermalLoad * 70).round()),
            _brass.withAlpha((24 + thermalLoad * 45).round()),
            Colors.transparent,
          ],
          stops: const [0, .28, 1],
        ).createShader(
          Rect.fromCircle(center: center, radius: size.shortestSide * .9),
        );
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _paintWovenGauze(Canvas canvas, Size size) {
    final fine = Paint()
      ..color = _grey.withAlpha(42)
      ..strokeWidth = .65;
    final hot = Paint()
      ..color = _brass.withAlpha(35)
      ..strokeWidth = 1.1;
    const spacing = 12.0;
    for (double x = -spacing; x <= size.width + spacing; x += spacing) {
      final wave = math.sin((x / 52) + clock * math.pi * 2) * 2.4;
      canvas.drawLine(Offset(x, 0), Offset(x + wave, size.height), fine);
    }
    for (double y = -spacing; y <= size.height + spacing; y += spacing) {
      final wave = math.cos((y / 58) + clock * math.pi * 2) * 2.4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + wave), fine);
    }
    for (double x = 0; x <= size.width; x += spacing * 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), hot);
    }
  }

  void _paintHeatTraces(Canvas canvas) {
    for (final trace in heatTraces) {
      final life = trace.life;
      final radius = 28 + (1 - life) * 88 * trace.intensity;
      final shader = RadialGradient(
        colors: [
          _red.withAlpha((210 * life).round()),
          _brass.withAlpha((110 * life).round()),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: trace.point, radius: radius));
      canvas.drawCircle(trace.point, radius, Paint()..shader = shader);
      canvas.drawCircle(
        trace.point,
        math.max(4, radius * .08),
        Paint()..color = _red.withAlpha((190 * life).round()),
      );
    }
  }

  void _paintChamber(Canvas canvas) {
    final chamberPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = kViolet.withAlpha(150);
    final hotPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _red.withAlpha((50 + thermalLoad * 80).round());
    final rrect = RRect.fromRectAndRadius(
      chamber,
      const Radius.circular(kRadiusSubtle),
    );
    canvas.drawRRect(rrect, chamberPaint);
    canvas.drawRRect(rrect.inflate(8), hotPaint);
    final corner = 18.0;
    for (final p in [
      chamber.topLeft,
      chamber.topRight,
      chamber.bottomLeft,
      chamber.bottomRight,
    ]) {
      canvas.drawCircle(p, corner / 5, Paint()..color = kViolet);
    }
  }

  void _paintNodes(Canvas canvas, Size size) {
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final position = i == draggingIndex && dragPoint != null
          ? dragPoint!
          : nodePosition(i);
      final selected = i == selectedIndex || i == draggingIndex;
      final stress = (1 - (entry.safetyMarginK.clamp(-80, 420) + 80) / 500)
          .clamp(0.0, 1.0);
      final alloy = alloyColor(entry.wireAlloy);
      final heatColor = Color.lerp(_brass, _red, stress)!;
      final nodeRadius = selected ? 27.0 : 22.0;

      canvas.drawCircle(
        position,
        nodeRadius + 22 + thermalLoad * 14,
        Paint()
          ..color = heatColor.withAlpha((35 + stress * 60).round())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      canvas.drawCircle(
        position,
        nodeRadius,
        Paint()
          ..color = const Color(0xFF111016)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        position,
        nodeRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.6 : 1.5
          ..color = selected ? heatColor : alloy.withAlpha(185),
      );

      _paintNodeMesh(canvas, position, nodeRadius, entry, heatColor);

      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.wireAlloy.code,
          style: AppFonts.ibmPlexMono(
            color: kPrimaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _paintNodeMesh(
    Canvas canvas,
    Offset center,
    double radius,
    FlameSafetyLampModel entry,
    Color heatColor,
  ) {
    final clip = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(clip);
    final paint = Paint()
      ..color = heatColor.withAlpha(130)
      ..strokeWidth = .9;
    final spacing = (40 / (entry.meshCountPerInch / 12)).clamp(5.0, 12.0);
    for (double x = center.dx - radius; x <= center.dx + radius; x += spacing) {
      canvas.drawLine(
        Offset(x, center.dy - radius),
        Offset(x, center.dy + radius),
        paint,
      );
    }
    for (double y = center.dy - radius; y <= center.dy + radius; y += spacing) {
      canvas.drawLine(
        Offset(center.dx - radius, y),
        Offset(center.dx + radius, y),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GauzeMatrixPainter oldDelegate) => true;
}
