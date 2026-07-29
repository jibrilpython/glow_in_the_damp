import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:glow_in_the_damp/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _gauzeGridSeal = '';
  double _meshCountPerInch = 28;
  double _wireDiameterMm = .45;
  GauzeAlloy _wireAlloy = GauzeAlloy.heavyIron;
  SleeveLayout _sleeveLayout = SleeveLayout.singleTube;
  AirInletPattern _airInletPattern = AirInletPattern.bottomFeed;
  GlassGrade _glassGrade = GlassGrade.highSilica;
  FuelLockClass _fuelLockClass = FuelLockClass.leadSeal;
  FuelBlend _fuelBlend = FuelBlend.colzaOil;
  double _heightMm = 250;
  double _dryMassGrams = 920;
  ShaftOrigin _shaftOrigin = ShaftOrigin.blackSeam;
  String _shaftOriginCustom = '';
  double _flameTemperatureC = 980;
  double _gauzeTemperatureC = 310;
  double _methanePercentLel = 2.1;
  double _airTemperatureC = 18;
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get gauzeGridSeal => _gauzeGridSeal;
  double get meshCountPerInch => _meshCountPerInch;
  double get wireDiameterMm => _wireDiameterMm;
  GauzeAlloy get wireAlloy => _wireAlloy;
  SleeveLayout get sleeveLayout => _sleeveLayout;
  AirInletPattern get airInletPattern => _airInletPattern;
  GlassGrade get glassGrade => _glassGrade;
  FuelLockClass get fuelLockClass => _fuelLockClass;
  FuelBlend get fuelBlend => _fuelBlend;
  double get heightMm => _heightMm;
  double get dryMassGrams => _dryMassGrams;
  ShaftOrigin get shaftOrigin => _shaftOrigin;
  String get shaftOriginCustom => _shaftOriginCustom;
  double get flameTemperatureC => _flameTemperatureC;
  double get gauzeTemperatureC => _gauzeTemperatureC;
  double get methanePercentLel => _methanePercentLel;
  double get airTemperatureC => _airTemperatureC;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set gauzeGridSeal(String v) {
    _gauzeGridSeal = v;
    notifyListeners();
  }

  set meshCountPerInch(double v) {
    _meshCountPerInch = v;
    notifyListeners();
  }

  set wireDiameterMm(double v) {
    _wireDiameterMm = v;
    notifyListeners();
  }

  set wireAlloy(GauzeAlloy v) {
    _wireAlloy = v;
    notifyListeners();
  }

  set sleeveLayout(SleeveLayout v) {
    _sleeveLayout = v;
    notifyListeners();
  }

  set airInletPattern(AirInletPattern v) {
    _airInletPattern = v;
    notifyListeners();
  }

  set glassGrade(GlassGrade v) {
    _glassGrade = v;
    notifyListeners();
  }

  set fuelLockClass(FuelLockClass v) {
    _fuelLockClass = v;
    notifyListeners();
  }

  set fuelBlend(FuelBlend v) {
    _fuelBlend = v;
    notifyListeners();
  }

  set heightMm(double v) {
    _heightMm = v;
    notifyListeners();
  }

  set dryMassGrams(double v) {
    _dryMassGrams = v;
    notifyListeners();
  }

  set shaftOrigin(ShaftOrigin v) {
    _shaftOrigin = v;
    notifyListeners();
  }

  set shaftOriginCustom(String v) {
    _shaftOriginCustom = v;
    notifyListeners();
  }

  set flameTemperatureC(double v) {
    _flameTemperatureC = v;
    notifyListeners();
  }

  set gauzeTemperatureC(double v) {
    _gauzeTemperatureC = v;
    notifyListeners();
  }

  set methanePercentLel(double v) {
    _methanePercentLel = v;
    notifyListeners();
  }

  set airTemperatureC(double v) {
    _airTemperatureC = v;
    notifyListeners();
  }

  set notes(String v) {
    _notes = v;
    notifyListeners();
  }

  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }

  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }

  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void clearAll() {
    _gauzeGridSeal = '';
    _meshCountPerInch = 28;
    _wireDiameterMm = .45;
    _wireAlloy = GauzeAlloy.heavyIron;
    _sleeveLayout = SleeveLayout.singleTube;
    _airInletPattern = AirInletPattern.bottomFeed;
    _glassGrade = GlassGrade.highSilica;
    _fuelLockClass = FuelLockClass.leadSeal;
    _fuelBlend = FuelBlend.colzaOil;
    _heightMm = 250;
    _dryMassGrams = 920;
    _shaftOrigin = ShaftOrigin.blackSeam;
    _shaftOriginCustom = '';
    _flameTemperatureC = 980;
    _gauzeTemperatureC = 310;
    _methanePercentLel = 2.1;
    _airTemperatureC = 18;
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
