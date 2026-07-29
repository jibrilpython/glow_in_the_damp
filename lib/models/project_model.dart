import 'dart:math' as math;
import 'package:glow_in_the_damp/enum/my_enums.dart';

class FlameSafetyLampModel {
  FlameSafetyLampModel({
    required this.id,
    required this.gauzeGridSeal,
    required this.meshCountPerInch,
    required this.wireDiameterMm,
    required this.wireAlloy,
    required this.sleeveLayout,
    required this.airInletPattern,
    required this.glassGrade,
    required this.fuelLockClass,
    required this.fuelBlend,
    required this.heightMm,
    required this.dryMassGrams,
    required this.shaftOrigin,
    required this.shaftOriginCustom,
    required this.flameTemperatureC,
    required this.gauzeTemperatureC,
    required this.methanePercentLel,
    required this.airTemperatureC,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  String id;
  String gauzeGridSeal;
  double meshCountPerInch;
  double wireDiameterMm;
  GauzeAlloy wireAlloy;
  SleeveLayout sleeveLayout;
  AirInletPattern airInletPattern;
  GlassGrade glassGrade;
  FuelLockClass fuelLockClass;
  FuelBlend fuelBlend;
  double heightMm;
  double dryMassGrams;
  ShaftOrigin shaftOrigin;
  String shaftOriginCustom;
  double flameTemperatureC;
  double gauzeTemperatureC;
  double methanePercentLel;
  double airTemperatureC;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  double get aperturesPerSquareInch => meshCountPerInch * meshCountPerInch;
  String get alloyCode => wireAlloy.code;
  String get originDisplay =>
      shaftOrigin == ShaftOrigin.other && shaftOriginCustom.trim().isNotEmpty
      ? shaftOriginCustom.trim()
      : shaftOrigin.label;

  double get heatFlux =>
      wireAlloy.conductivity *
      (flameTemperatureC - airTemperatureC) /
      math.max(wireDiameterMm / 1000, 0.0002);

  double get outerGauzeTemperatureC {
    final meshCooling = meshCountPerInch * 3.8;
    final alloyCooling = wireAlloy.conductivity / 7.5;
    final sleeveBonus =
        sleeveLayout == SleeveLayout.dualNested ||
            sleeveLayout == SleeveLayout.bonnetedDavy
        ? 64
        : 24;
    final methaneLoad = methanePercentLel * 1.8;
    return (gauzeTemperatureC +
            methaneLoad -
            meshCooling -
            alloyCooling -
            sleeveBonus)
        .clamp(airTemperatureC, flameTemperatureC);
  }

  double get safetyMarginK => 537 - outerGauzeTemperatureC;
  double get methaneCeilingPercent =>
      (methanePercentLel + safetyMarginK / 88).clamp(0.2, 7.5);
  double get criticalIsothermMm =>
      (wireDiameterMm * (1 - (safetyMarginK.clamp(0, 537) / 537))).clamp(
        0.05,
        4.8,
      );

  String get dissipationStatus {
    if (safetyMarginK < 0) return 'DISS: CRITICAL';
    if (safetyMarginK < 80) return 'DISS: MARGIN ${safetyMarginK.round()}K';
    return 'DISS: SAFE MARGIN ${safetyMarginK.round()}K';
  }

  int get archiveCompleteness {
    final values = [
      gauzeGridSeal,
      notes,
      photoPath,
      shaftOriginCustom,
      tags.join(','),
    ];
    final filled = values.where((value) => value.trim().isNotEmpty).length;
    final numeric = [
      meshCountPerInch,
      wireDiameterMm,
      heightMm,
      dryMassGrams,
      flameTemperatureC,
      gauzeTemperatureC,
      methanePercentLel,
    ].where((value) => value > 0).length;
    return (((filled + numeric) / (values.length + 7)) * 100).round();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gauzeGridSeal': gauzeGridSeal,
    'meshCountPerInch': meshCountPerInch,
    'wireDiameterMm': wireDiameterMm,
    'wireAlloy': wireAlloy.name,
    'sleeveLayout': sleeveLayout.name,
    'airInletPattern': airInletPattern.name,
    'glassGrade': glassGrade.name,
    'fuelLockClass': fuelLockClass.name,
    'fuelBlend': fuelBlend.name,
    'heightMm': heightMm,
    'dryMassGrams': dryMassGrams,
    'shaftOrigin': shaftOrigin.name,
    'shaftOriginCustom': shaftOriginCustom,
    'flameTemperatureC': flameTemperatureC,
    'gauzeTemperatureC': gauzeTemperatureC,
    'methanePercentLel': methanePercentLel,
    'airTemperatureC': airTemperatureC,
    'notes': notes,
    'photoPath': photoPath,
    'tags': tags,
    'dateAdded': dateAdded.toIso8601String(),
  };

  factory FlameSafetyLampModel.fromJson(Map<String, dynamic> json) =>
      FlameSafetyLampModel(
        id: json['id'] ?? '',
        gauzeGridSeal: json['gauzeGridSeal'] ?? '',
        meshCountPerInch: (json['meshCountPerInch'] ?? 28).toDouble(),
        wireDiameterMm: (json['wireDiameterMm'] ?? .45).toDouble(),
        wireAlloy:
            GauzeAlloy.values.asNameMap()[json['wireAlloy']] ??
            GauzeAlloy.heavyIron,
        sleeveLayout:
            SleeveLayout.values.asNameMap()[json['sleeveLayout']] ??
            SleeveLayout.singleTube,
        airInletPattern:
            AirInletPattern.values.asNameMap()[json['airInletPattern']] ??
            AirInletPattern.bottomFeed,
        glassGrade:
            GlassGrade.values.asNameMap()[json['glassGrade']] ??
            GlassGrade.highSilica,
        fuelLockClass:
            FuelLockClass.values.asNameMap()[json['fuelLockClass']] ??
            FuelLockClass.leadSeal,
        fuelBlend:
            FuelBlend.values.asNameMap()[json['fuelBlend']] ??
            FuelBlend.colzaOil,
        heightMm: (json['heightMm'] ?? 250).toDouble(),
        dryMassGrams: (json['dryMassGrams'] ?? 920).toDouble(),
        shaftOrigin:
            ShaftOrigin.values.asNameMap()[json['shaftOrigin']] ??
            ShaftOrigin.blackSeam,
        shaftOriginCustom: json['shaftOriginCustom'] ?? '',
        flameTemperatureC: (json['flameTemperatureC'] ?? 980).toDouble(),
        gauzeTemperatureC: (json['gauzeTemperatureC'] ?? 310).toDouble(),
        methanePercentLel: (json['methanePercentLel'] ?? 2.1).toDouble(),
        airTemperatureC: (json['airTemperatureC'] ?? 18).toDouble(),
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
