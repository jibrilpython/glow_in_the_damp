import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glow_in_the_damp/providers/image_provider.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/utils/const.dart';
import 'package:image_picker/image_picker.dart';

void photoBottomSheet(
  BuildContext context,
  ImageNotifier imageProv,
  int index,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: const Color(0xCC050308),
    builder: (_) => _PhotoBottomSheetContent(imageProv: imageProv),
  );
}

class _PhotoBottomSheetContent extends StatelessWidget {
  const _PhotoBottomSheetContent({required this.imageProv});
  final ImageNotifier imageProv;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    HapticFeedback.selectionClick();
    Navigator.pop(context);
    await imageProv.pickImage(source: source);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, bottom + 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0B090D),
        borderRadius: BorderRadius.circular(kRadiusMedium),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowFloat],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 132.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _MacroMeshPainter()),
                Positioned(
                  left: 18.w,
                  right: 18.w,
                  top: 14.h,
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: kAccent.withAlpha(160),
                          borderRadius: BorderRadius.circular(kRadiusPill),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: kPanelBg.withAlpha(200),
                            shape: BoxShape.circle,
                            border: Border.all(color: kOutline),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16.sp,
                            color: kSecondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 18.w,
                  right: 18.w,
                  bottom: 16.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GAUZE MACRO RECORD',
                        style: AppFonts.ibmPlexMono(
                          color: kAccent,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Capture the wire\nunder inspection light',
                        style: AppFonts.archivo(
                          color: kPrimaryText,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          height: .95,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
            child: Column(
              children: [
                Text(
                  'Fill the frame with mesh. Prefer a light source behind or below the gauze so wire diameter and crossings read clearly.',
                  style: AppFonts.ibmPlexSans(
                    color: kSecondaryText,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _CaptureTile(
                        icon: Icons.photo_camera_outlined,
                        title: 'LENS',
                        subtitle: 'Take photograph',
                        accent: kAccent,
                        onTap: () => _pick(context, ImageSource.camera),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _CaptureTile(
                        icon: Icons.collections_outlined,
                        title: 'ARCHIVE',
                        subtitle: 'Pick from library',
                        accent: kViolet,
                        onTap: () => _pick(context, ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                    border: Border.all(color: kOutline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.grid_on_rounded,
                        color: kAccent.withAlpha(180),
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'SPEC: macro · near-black ground · mesh fills frame',
                          style: AppFonts.ibmPlexMono(
                            color: kSecondaryText,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureTile extends StatelessWidget {
  const _CaptureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        child: Ink(
          height: 128.h,
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(color: accent.withAlpha(90)),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withAlpha(28),
                    border: Border.all(color: accent.withAlpha(120)),
                  ),
                  child: Icon(icon, color: accent, size: 20.sp),
                ),
                const Spacer(),
                Text(
                  title,
                  style: AppFonts.ibmPlexMono(
                    color: accent,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: AppFonts.ibmPlexSans(
                    color: kPrimaryText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF050308),
    );

    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -.2),
        radius: 1.05,
        colors: [
          kAccent.withAlpha(55),
          kViolet.withAlpha(28),
          Colors.transparent,
        ],
        stops: const [0, .42, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glow);

    final wire = Paint()
      ..color = kPrimaryText.withAlpha(55)
      ..strokeWidth = .9;
    const spacing = 11.0;
    for (double x = 0; x <= size.width; x += spacing) {
      final sway = math.sin(x / 28) * 1.4;
      canvas.drawLine(Offset(x + sway, 0), Offset(x - sway, size.height), wire);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      final sway = math.cos(y / 26) * 1.2;
      canvas.drawLine(Offset(0, y + sway), Offset(size.width, y - sway), wire);
    }

    canvas.drawCircle(
      Offset(size.width * .72, size.height * .38),
      28,
      Paint()
        ..color = kAccent.withAlpha(35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 48, size.width, 48),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF0B090D).withAlpha(230),
          ],
        ).createShader(Rect.fromLTWH(0, size.height - 48, size.width, 48)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
