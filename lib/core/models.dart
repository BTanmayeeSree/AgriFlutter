class FarmLocation {
  const FarmLocation(
    this.district,
    this.state, {
    this.latitude,
    this.longitude,
  });
  final String district, state;
  final double? latitude, longitude;
  String get label => '$district, $state';
  Map<String, dynamic> toJson() => {
    'district': district,
    'state': state,
    'lat': latitude,
    'lon': longitude,
  };
  factory FarmLocation.fromJson(Map<String, dynamic> j) => FarmLocation(
    j['district'] as String,
    j['state'] as String,
    latitude: (j['lat'] as num?)?.toDouble(),
    longitude: (j['lon'] as num?)?.toDouble(),
  );
}

class SoilRecord {
  const SoilRecord({
    required this.type,
    required this.date,
    this.ph,
    this.n,
    this.p,
    this.k,
    this.unit = 'mg/kg',
  });
  final String type, date, unit;
  final double? ph, n, p, k;
  Map<String, dynamic> toJson() => {
    'type': type,
    'date': date,
    'unit': unit,
    'ph': ph,
    'n': n,
    'p': p,
    'k': k,
  };
  factory SoilRecord.fromJson(Map<String, dynamic> j) => SoilRecord(
    type: j['type'] as String,
    date: j['date'] as String,
    unit: j['unit'] as String,
    ph: (j['ph'] as num?)?.toDouble(),
    n: (j['n'] as num?)?.toDouble(),
    p: (j['p'] as num?)?.toDouble(),
    k: (j['k'] as num?)?.toDouble(),
  );
}

class PriceNote {
  const PriceNote(this.crop, this.mandi, this.price, this.date);
  final String crop, mandi, date;
  final double price; // Canonical INR per quintal.
  Map<String, dynamic> toJson() => {
    'crop': crop,
    'mandi': mandi,
    'price': price,
    'date': date,
  };
  factory PriceNote.fromJson(Map<String, dynamic> j) => PriceNote(
    j['crop'] as String,
    j['mandi'] as String,
    (j['price'] as num).toDouble(),
    j['date'] as String,
  );
}

double displayPrice(double perQuintal, String unit) => switch (unit) {
  'kg' => perQuintal / 100,
  'tonne' => perQuintal * 10,
  _ => perQuintal,
};
double canonicalPrice(double value, String unit) => switch (unit) {
  'kg' => value * 100,
  'tonne' => value / 10,
  _ => value,
};

class Crop {
  const Crop(
    this.id,
    this.name,
    this.category,
    this.season,
    this.soils,
    this.phMin,
    this.phMax,
    this.guide,
  );
  final String id, name, category, season;
  final List<String> soils;
  final double phMin, phMax;
  final Map<String, dynamic> guide;
  factory Crop.fromJson(Map<String, dynamic> j) => Crop(
    j['id'] as String,
    j['name'] as String,
    j['category'] as String? ?? 'Crop',
    (j['seasonality'] as List? ?? []).join(', '),
    (j['soil_ok'] as List? ?? []).map((e) => '$e').toList(),
    (j['pH'][0] as num).toDouble(),
    (j['pH'][1] as num).toDouble(),
    Map<String, dynamic>.from(j['guide'] as Map? ?? {}),
  );
}

class RankedCrop {
  const RankedCrop(this.crop, this.score, this.reasons);
  final Crop crop;
  final int score;
  final List<String> reasons;
}

List<RankedCrop> rankCrops(List<Crop> crops, SoilRecord soil, String season) {
  final results = crops.map((crop) {
    var score = 0;
    final reasons = <String>[];
    if (crop.soils.any((s) => s.toLowerCase() == soil.type.toLowerCase())) {
      score += 50;
      reasons.add('Soil type matches');
    }
    if (soil.ph != null && soil.ph! >= crop.phMin && soil.ph! <= crop.phMax) {
      score += 30;
      reasons.add('pH is in the catalog range');
    }
    if (crop.season.toLowerCase().contains(season.toLowerCase())) {
      score += 20;
      reasons.add('Season matches');
    }
    return RankedCrop(crop, score, reasons);
  }).toList();
  results.sort((a, b) {
    final comparison = b.score.compareTo(a.score);
    return comparison == 0 ? a.crop.id.compareTo(b.crop.id) : comparison;
  });
  return results;
}
