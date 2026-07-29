enum GauzeAlloy {
  heavyIron('Heavy iron wire', 'Fe', 80, 1120),
  drawnCopper('Drawn copper wire', 'Cu', 401, 760),
  earlyBrass('Early brass wire', 'Cu-Zn', 120, 840),
  monel('Monel metal replacement', 'Ni-Cu', 22, 1180),
  platinum('Platinum laboratory wire', 'Pt', 72, 2040);

  const GauzeAlloy(
    this.label,
    this.code,
    this.conductivity,
    this.failureCelsius,
  );
  final String label;
  final String code;
  final double conductivity;
  final double failureCelsius;
}

enum SleeveLayout {
  singleTube('Single gauze tube'),
  dualNested('Dual nested concentric sleeves'),
  clannyGlassGauze('Clanny glass with upper gauze'),
  bonnetedDavy('Bonneted Davy double chimney'),
  labComparator('Laboratory split comparison sleeve');

  const SleeveLayout(this.label);
  final String label;
}

enum AirInletPattern {
  bottomFeed('Bottom-feed horizontal perforations'),
  unbonnetedTop('Unbonneted top feed'),
  bonnetLabyrinth('Bonnet labyrinth intake'),
  micaBaffle('Mica baffle side intake'),
  annularRing('Annular base ring slots');

  const AirInletPattern(this.label);
  final String label;
}

enum GlassGrade {
  highSilica('High-silica thick-walled glass'),
  micaLaminate('Clear mica sheet laminate'),
  sodaLime('Soda-lime cylinder glass'),
  borosilicate('Restoration borosilicate cylinder'),
  noGlass('Open gauze without glass cylinder');

  const GlassGrade(this.label);
  final String label;
}

enum FuelLockClass {
  leadSeal('Lead-seal padlock'),
  magneticPlunger('Magnetic internal plunger'),
  screwCollar('Threaded screw collar lock'),
  rivetedCap('Riveted curator-sealed cap'),
  labOpen('Laboratory open reservoir');

  const FuelLockClass(this.label);
  final String label;
}

enum FuelBlend {
  colzaOil('Purified colza oil'),
  whaleOil('Whale oil'),
  sealFat('Rendered seal fat'),
  paraffin('Early paraffin trial blend'),
  labEthanol('Controlled laboratory ethanol flame');

  const FuelBlend(this.label);
  final String label;
}

enum ShaftOrigin {
  blackSeam('Black-Seam Shaft No. 4'),
  ironRidge('Iron-Ridge deep drift'),
  lostMountain('Lost Mountain railway tunnel'),
  buxtonLab('SMRE Buxton test gallery'),
  sheffieldLab('Home Office Laboratory Sheffield'),
  other('Other / custom origin');

  const ShaftOrigin(this.label);
  final String label;
}

enum GauzeFilter {
  iron('Iron wire'),
  copperZinc('Copper-zinc alloy'),
  monel('Monel metal'),
  platinum('Platinum wire'),
  doubleGauze('Double gauze'),
  glassCylinder('Glass cylinder');

  const GauzeFilter(this.label);
  final String label;
}

GauzeFilter filterForAlloy(
  GauzeAlloy alloy,
  SleeveLayout sleeve,
  GlassGrade glass,
) {
  if (sleeve == SleeveLayout.dualNested ||
      sleeve == SleeveLayout.bonnetedDavy) {
    return GauzeFilter.doubleGauze;
  }
  if (glass != GlassGrade.noGlass) return GauzeFilter.glassCylinder;
  switch (alloy) {
    case GauzeAlloy.heavyIron:
      return GauzeFilter.iron;
    case GauzeAlloy.drawnCopper:
    case GauzeAlloy.earlyBrass:
      return GauzeFilter.copperZinc;
    case GauzeAlloy.monel:
      return GauzeFilter.monel;
    case GauzeAlloy.platinum:
      return GauzeFilter.platinum;
  }
}
