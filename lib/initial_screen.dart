import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/enum/my_enums.dart';
import 'package:glow_in_the_damp/providers/user_provider.dart';
import 'package:glow_in_the_damp/utils/const.dart';

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProv = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GauzeFieldPainter())),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 36.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            color: kAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'FIREDAMP FIELD LOG',
                          style: AppFonts.ibmPlexMono(
                            color: kAccent,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 250.h),
                    Text(
                      'GLOW\nIN THE\nDAMP.',
                      style: AppFonts.archivo(
                        color: kPrimaryText,
                        fontSize: 56.sp,
                        fontWeight: FontWeight.w800,
                        height: .86,
                        letterSpacing: -.9,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'A field catalog and flame-cap dissipation modeler for 19th-century safety lamp gauzes, glass cylinders, brass caps, and methane ignition thresholds.',
                      style: AppFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 15.sp,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: GauzeFilter.values
                          .map(
                            (filter) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: filterColor(filter).withAlpha(24),
                                borderRadius: BorderRadius.circular(
                                  kRadiusPill,
                                ),
                                border: Border.all(
                                  color: filterColor(filter).withAlpha(90),
                                ),
                              ),
                              child: Text(
                                filter.label.toUpperCase(),
                                style: AppFonts.ibmPlexMono(
                                  color: filterColor(filter),
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 28.h),
                    GestureDetector(
                      onTap: () {
                        userProv.setFirstTimeUser(false);
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 58.h,
                        decoration: BoxDecoration(
                          color: kAccent,
                          borderRadius: BorderRadius.circular(kRadiusPill),
                          boxShadow: const [kShadowSignal],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Open Dissipation Archive',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.ibmPlexSans(
                                  color: kBackground,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: kBackground,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GauzeFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wire = Paint()
      ..color = kOutline.withAlpha(180)
      ..strokeWidth = .8;
    for (double x = -size.width; x < size.width * 2; x += 18) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * .35, size.height),
        wire,
      );
      canvas.drawLine(
        Offset(size.width - x, 0),
        Offset(size.width - x - size.height * .35, size.height),
        wire,
      );
    }
    final flame = Paint()..color = kAccent.withAlpha(22);
    for (var i = 0; i < 8; i++) {
      final r = 80.0 + i * 32;
      canvas.drawCircle(
        Offset(size.width * .7, size.height * .22 + math.sin(i) * 8),
        r,
        flame,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
