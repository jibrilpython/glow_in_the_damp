import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glow_in_the_damp/common/photo_bottom_sheet.dart';
import 'package:glow_in_the_damp/enum/my_enums.dart';
import 'package:glow_in_the_damp/models/project_model.dart';
import 'package:glow_in_the_damp/providers/image_provider.dart';
import 'package:glow_in_the_damp/providers/input_provider.dart';
import 'package:glow_in_the_damp/providers/project_provider.dart';
import 'package:glow_in_the_damp/utils/app_fonts.dart';
import 'package:glow_in_the_damp/utils/const.dart';

class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});
  final bool isEdit;
  final int currentIndex;

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late final PageController _pageCtrl;
  int _page = 0;
  late final TextEditingController _sealCtrl;
  late final TextEditingController _originCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _tagsCtrl;

  static const _titles = ['Identity', 'Construction', 'Thermals'];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    final p = ref.read(inputProvider);
    _sealCtrl = TextEditingController(text: p.gauzeGridSeal);
    _originCtrl = TextEditingController(text: p.shaftOriginCustom);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _sealCtrl.dispose();
    _originCtrl.dispose();
    _notesCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  FlameSafetyLampModel _preview(InputNotifier p) => FlameSafetyLampModel(
    id: 'preview',
    gauzeGridSeal: p.gauzeGridSeal.isEmpty ? 'GID-MESH-DRAFT' : p.gauzeGridSeal,
    meshCountPerInch: p.meshCountPerInch,
    wireDiameterMm: p.wireDiameterMm,
    wireAlloy: p.wireAlloy,
    sleeveLayout: p.sleeveLayout,
    airInletPattern: p.airInletPattern,
    glassGrade: p.glassGrade,
    fuelLockClass: p.fuelLockClass,
    fuelBlend: p.fuelBlend,
    heightMm: p.heightMm,
    dryMassGrams: p.dryMassGrams,
    shaftOrigin: p.shaftOrigin,
    shaftOriginCustom: p.shaftOriginCustom,
    flameTemperatureC: p.flameTemperatureC,
    gauzeTemperatureC: p.gauzeTemperatureC,
    methanePercentLel: p.methanePercentLel,
    airTemperatureC: p.airTemperatureC,
    notes: p.notes,
    photoPath: p.photoPath,
    tags: p.tags,
    dateAdded: p.dateAdded,
  );

  Color _statusOf(double margin) {
    if (margin < 0) return kError;
    if (margin < 80) return kViolet;
    return kAccent;
  }

  Future<void> _save() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 450));
    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
    ref.read(inputProvider).clearAll();
    ref.read(imageProvider).clearImage();
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(inputProvider);
    final preview = _preview(p);
    final status = _statusOf(preview.safetyMarginK);
    final last = _page == _titles.length - 1;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'EDIT SPECIMEN' : 'NEW SPECIMEN'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _StepBar(
              page: _page,
              titles: _titles,
              onStepTap: (i) {
                if (i == _page) return;
                _pageCtrl.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                );
              },
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: status,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      preview.dissipationStatus,
                      style: AppFonts.ibmPlexMono(
                        color: status,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${preview.meshCountPerInch.round()} mesh · ${p.wireAlloy.code}',
                    style: AppFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _scroll([
                    _photo(),
                    SizedBox(height: 16.h),
                    _label('GAUZE GRID SEAL'),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: _sealCtrl,
                      onChanged: (v) => p.gauzeGridSeal = v,
                      style: AppFonts.ibmPlexMono(
                        color: kPrimaryText,
                        fontSize: 14.sp,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Leave blank to auto-generate',
                      ),
                    ),
                    SizedBox(height: 18.h),
                    _label('WIRE ALLOY'),
                    SizedBox(height: 8.h),
                    _chips(
                      GauzeAlloy.values,
                      p.wireAlloy,
                      (v) => ref.read(inputProvider).wireAlloy = v,
                      (v) => v.code,
                      alloyColor,
                    ),
                    SizedBox(height: 18.h),
                    _label('SHAFT ORIGIN'),
                    SizedBox(height: 8.h),
                    _chips(
                      ShaftOrigin.values,
                      p.shaftOrigin,
                      (v) => ref.read(inputProvider).shaftOrigin = v,
                      (v) => v.label,
                      (_) => kViolet,
                    ),
                    if (p.shaftOrigin == ShaftOrigin.other) ...[
                      SizedBox(height: 10.h),
                      TextField(
                        controller: _originCtrl,
                        onChanged: (v) {
                          p.shaftOrigin = ShaftOrigin.other;
                          p.shaftOriginCustom = v;
                        },
                        maxLines: 2,
                        style: AppFonts.ibmPlexSans(
                          color: kPrimaryText,
                          fontSize: 14.sp,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Custom origin',
                        ),
                      ),
                    ],
                  ]),
                  _scroll([
                    _slider(
                      'MESH COUNT',
                      '${p.meshCountPerInch.round()} /in',
                      p.meshCountPerInch,
                      12,
                      40,
                      (v) => ref.read(inputProvider).meshCountPerInch = v,
                    ),
                    SizedBox(height: 12.h),
                    _slider(
                      'WIRE DIAMETER',
                      '${p.wireDiameterMm.toStringAsFixed(2)} mm',
                      p.wireDiameterMm,
                      .2,
                      1.2,
                      (v) => ref.read(inputProvider).wireDiameterMm = v,
                    ),
                    SizedBox(height: 12.h),
                    _slider(
                      'HEIGHT',
                      '${p.heightMm.round()} mm',
                      p.heightMm,
                      150,
                      420,
                      (v) => ref.read(inputProvider).heightMm = v,
                    ),
                    SizedBox(height: 12.h),
                    _slider(
                      'DRY MASS',
                      '${p.dryMassGrams.round()} g',
                      p.dryMassGrams,
                      350,
                      1800,
                      (v) => ref.read(inputProvider).dryMassGrams = v,
                    ),
                    SizedBox(height: 16.h),
                    _pickerRow(
                      'Sleeve',
                      p.sleeveLayout.label,
                      () => _pick(
                        'Sleeve layout',
                        SleeveLayout.values,
                        p.sleeveLayout,
                        (v) => v.label,
                        (v) => ref.read(inputProvider).sleeveLayout = v,
                      ),
                    ),
                    _pickerRow(
                      'Air inlet',
                      p.airInletPattern.label,
                      () => _pick(
                        'Air inlet',
                        AirInletPattern.values,
                        p.airInletPattern,
                        (v) => v.label,
                        (v) => ref.read(inputProvider).airInletPattern = v,
                      ),
                    ),
                    _pickerRow(
                      'Glass',
                      p.glassGrade.label,
                      () => _pick(
                        'Glass grade',
                        GlassGrade.values,
                        p.glassGrade,
                        (v) => v.label,
                        (v) => ref.read(inputProvider).glassGrade = v,
                      ),
                    ),
                    _pickerRow(
                      'Fuel lock',
                      p.fuelLockClass.label,
                      () => _pick(
                        'Fuel lock',
                        FuelLockClass.values,
                        p.fuelLockClass,
                        (v) => v.label,
                        (v) => ref.read(inputProvider).fuelLockClass = v,
                      ),
                    ),
                    _pickerRow(
                      'Fuel',
                      p.fuelBlend.label,
                      () => _pick(
                        'Fuel blend',
                        FuelBlend.values,
                        p.fuelBlend,
                        (v) => v.label,
                        (v) => ref.read(inputProvider).fuelBlend = v,
                      ),
                    ),
                  ]),
                  _scroll([
                    _slider(
                      'GAUZE TEMPERATURE',
                      '${p.gauzeTemperatureC.round()} C',
                      p.gauzeTemperatureC,
                      80,
                      760,
                      (v) => ref.read(inputProvider).gauzeTemperatureC = v,
                    ),
                    SizedBox(height: 12.h),
                    _slider(
                      'FLAME TEMPERATURE',
                      '${p.flameTemperatureC.round()} C',
                      p.flameTemperatureC,
                      650,
                      1250,
                      (v) => ref.read(inputProvider).flameTemperatureC = v,
                    ),
                    SizedBox(height: 12.h),
                    _slider(
                      'AMBIENT METHANE',
                      '${p.methanePercentLel.toStringAsFixed(1)}% LEL',
                      p.methanePercentLel,
                      .2,
                      5.8,
                      (v) => ref.read(inputProvider).methanePercentLel = v,
                    ),
                    SizedBox(height: 12.h),
                    _slider(
                      'AIR TEMPERATURE',
                      '${p.airTemperatureC.round()} C',
                      p.airTemperatureC,
                      -5,
                      42,
                      (v) => ref.read(inputProvider).airTemperatureC = v,
                    ),
                    SizedBox(height: 16.h),
                    _label('NOTES'),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: _notesCtrl,
                      onChanged: (v) => p.notes = v,
                      maxLines: 4,
                      style: AppFonts.ibmPlexSans(
                        color: kPrimaryText,
                        fontSize: 14.sp,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Condition, corrosion, validation…',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _label('TAGS'),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: _tagsCtrl,
                      onChanged: (v) => p.tags = v
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      style: AppFonts.ibmPlexMono(
                        color: kPrimaryText,
                        fontSize: 13.sp,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'davy, 28-mesh, smre',
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: kOutline)),
              ),
              child: Row(
                children: [
                  if (_page > 0)
                    IconButton(
                      onPressed: () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: last
                          ? _save
                          : () => _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                            ),
                      child: Text(
                        last
                            ? (widget.isEdit ? 'Update specimen' : 'Commit specimen')
                            : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scroll(List<Widget> children) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _photo() {
    final path = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    final has = path != null && File(path).existsSync();
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        height: 148.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        clipBehavior: Clip.antiAlias,
        child: has
            ? Image.file(File(path), fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: kAccent, size: 28.sp),
                  SizedBox(height: 8.h),
                  Text(
                    'Add gauze macro photo',
                    style: AppFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: AppFonts.ibmPlexMono(
      color: kSecondaryText,
      fontSize: 9.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
    ),
  );

  Widget _slider(
    String label,
    String value,
    double current,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => Container(
    padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
    decoration: BoxDecoration(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      border: Border.all(color: kOutline),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _label(label)),
            Text(
              value,
              style: AppFonts.ibmPlexMono(
                color: kAccent,
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: current.clamp(min, max),
          min: min,
          max: max,
          activeColor: kAccent,
          inactiveColor: kOutline,
          onChanged: onChanged,
        ),
      ],
    ),
  );

  Widget _chips<T>(
    List<T> values,
    T current,
    ValueChanged<T> onSelected,
    String Function(T) labelOf,
    Color Function(T) colorOf,
  ) => Wrap(
    spacing: 8.w,
    runSpacing: 8.h,
    children: values.map((v) {
      final selected = v == current;
      final c = colorOf(v);
      return GestureDetector(
        onTap: () => onSelected(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? c.withAlpha(36) : kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusPill),
            border: Border.all(color: selected ? c : kOutline),
          ),
          child: Text(
            labelOf(v),
            style: AppFonts.ibmPlexSans(
              color: selected ? kPrimaryText : kSecondaryText,
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList(),
  );

  Widget _pickerRow(String label, String value, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
            border: Border.all(color: kOutline),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 78.w,
                child: Text(
                  label.toUpperCase(),
                  style: AppFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppFonts.ibmPlexSans(
                    color: kPrimaryText,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: kSecondaryText, size: 18.sp),
            ],
          ),
        ),
      );

  Future<void> _pick<T>(
    String title,
    List<T> values,
    T current,
    String Function(T) labelOf,
    ValueChanged<T> onSelected,
  ) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: kPanelBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kRadiusMedium),
        ),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
              child: Text(
                title.toUpperCase(),
                style: AppFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ...values.map(
              (v) => ListTile(
                onTap: () => Navigator.pop(context, v),
                title: Text(
                  labelOf(v),
                  style: AppFonts.ibmPlexSans(
                    color: v == current ? kAccent : kPrimaryText,
                    fontSize: 14.sp,
                  ),
                ),
                trailing: v == current
                    ? const Icon(Icons.check, color: kAccent, size: 18)
                    : null,
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
    if (result != null) onSelected(result);
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({
    required this.page,
    required this.titles,
    required this.onStepTap,
  });

  final int page;
  final List<String> titles;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 28.h,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final count = titles.length;
                  final nodeSize = 28.w;
                  final trackLeft = nodeSize / 2;
                  final trackWidth = constraints.maxWidth - nodeSize;
                  final progress = page / (count - 1);

                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned(
                        left: trackLeft,
                        right: trackLeft,
                        child: Container(
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: kOutline,
                            borderRadius: BorderRadius.circular(kRadiusPill),
                          ),
                        ),
                      ),
                      Positioned(
                        left: trackLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          width: trackWidth * progress,
                          height: 2.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kAccent, kViolet],
                            ),
                            borderRadius: BorderRadius.circular(kRadiusPill),
                            boxShadow: [
                              BoxShadow(
                                color: kAccent.withAlpha(70),
                                blurRadius: 8,
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(count, (i) {
                          final done = i < page;
                          final active = i == page;
                          return GestureDetector(
                            onTap: () => onStepTap(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: nodeSize,
                              height: nodeSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done || active
                                    ? (active ? kAccent : kAccent.withAlpha(40))
                                    : const Color(0xFF0A080C),
                                border: Border.all(
                                  color: done || active ? kAccent : kOutline,
                                  width: active ? 1.5 : 1,
                                ),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color: kAccent.withAlpha(90),
                                          blurRadius: 12,
                                          spreadRadius: -2,
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: done
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 14.sp,
                                      color: kAccent,
                                    )
                                  : Text(
                                      '${i + 1}',
                                      style: AppFonts.ibmPlexMono(
                                        color: active
                                            ? kBackground
                                            : kSecondaryText,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: List.generate(titles.length, (i) {
                final active = i == page;
                final done = i < page;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onStepTap(i),
                    child: Text(
                      titles[i].toUpperCase(),
                      textAlign: i == 0
                          ? TextAlign.left
                          : i == titles.length - 1
                          ? TextAlign.right
                          : TextAlign.center,
                      style: AppFonts.ibmPlexMono(
                        color: active || done ? kAccent : kSecondaryText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .6,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusMedium),
          border: Border.all(color: kOutline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LinearProgressIndicator(
              color: kAccent,
              backgroundColor: kOutline,
            ),
            SizedBox(height: 16.h),
            Text(
              'CALCULATING SAFETY MARGIN',
              style: AppFonts.ibmPlexMono(
                color: kAccent,
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
