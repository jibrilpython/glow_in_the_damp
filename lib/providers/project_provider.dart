import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:glow_in_the_damp/enum/my_enums.dart';
import 'package:glow_in_the_damp/models/project_model.dart';
import 'package:glow_in_the_damp/providers/image_provider.dart';
import 'package:glow_in_the_damp/providers/input_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<FlameSafetyLampModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'gid_flame_safety_lamps_v1';
  final _uuid = const Uuid();
  final _random = Random();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        entries = decoded
            .map(
              (item) => FlameSafetyLampModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading flame safety lamp entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  String _generateSeal(GauzeAlloy alloy, double mesh) {
    final number = 100 + _random.nextInt(899);
    final lineage = [
      'DAVY',
      'CLANNY',
      'STEPHENSON',
      'SMRE',
    ][_random.nextInt(4)];
    return 'GID-MESH-$number-${mesh.round()}M-${alloy.code}-$lineage';
  }

  FlameSafetyLampModel _fromInput(
    WidgetRef ref, {
    FlameSafetyLampModel? existing,
  }) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    return FlameSafetyLampModel(
      id: existing?.id ?? _uuid.v4(),
      gauzeGridSeal: p.gauzeGridSeal.trim().isNotEmpty
          ? p.gauzeGridSeal.trim()
          : existing?.gauzeGridSeal ??
                _generateSeal(p.wireAlloy, p.meshCountPerInch),
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
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : (existing?.photoPath ?? p.photoPath),
      tags: List<String>.from(p.tags),
      dateAdded: existing?.dateAdded ?? p.dateAdded,
    );
  }

  void addEntry(WidgetRef ref) {
    entries.add(_fromInput(ref));
    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    if (index < 0 || index >= entries.length) return;
    entries[index] = _fromInput(ref, existing: entries[index]);
    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    if (index < 0 || index >= entries.length) return;
    entries.removeAt(index);
    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    if (index < 0 || index >= entries.length) return;
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];
    p.gauzeGridSeal = entry.gauzeGridSeal;
    p.meshCountPerInch = entry.meshCountPerInch;
    p.wireDiameterMm = entry.wireDiameterMm;
    p.wireAlloy = entry.wireAlloy;
    p.sleeveLayout = entry.sleeveLayout;
    p.airInletPattern = entry.airInletPattern;
    p.glassGrade = entry.glassGrade;
    p.fuelLockClass = entry.fuelLockClass;
    p.fuelBlend = entry.fuelBlend;
    p.heightMm = entry.heightMm;
    p.dryMassGrams = entry.dryMassGrams;
    p.shaftOrigin = entry.shaftOrigin;
    p.shaftOriginCustom = entry.shaftOriginCustom;
    p.flameTemperatureC = entry.flameTemperatureC;
    p.gauzeTemperatureC = entry.gauzeTemperatureC;
    p.methanePercentLel = entry.methanePercentLel;
    p.airTemperatureC = entry.airTemperatureC;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;
    imgProv.resultImage = entry.photoPath;
    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
