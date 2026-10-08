import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'store.dart';

class AppController extends ChangeNotifier {
  AppController(this.store, {http.Client? client})
    : client = client ?? http.Client();
  final Store store;
  final http.Client client;
  FarmLocation? location;
  SoilRecord? soil;
  List<SoilRecord> soilHistory = [];
  final Map<String, List<SoilRecord>> _farmSoils = {};
  List<PriceNote> notes = [];
  List<Crop> crops = [];
  String language = 'en', theme = 'system', priceUnit = 'quintal';
  bool fahrenheit = false, busy = false;
  String? weatherError, storageError;
  Map<String, dynamic>? weather;
  String? weatherFetchedAt;
  int _generation = 0;
  Future<void> _pending = Future.value();

  Future<void> load() async {
    try {
      final j = await store.read();
      language = j['language'] as String? ?? 'en';
      theme = j['theme'] as String? ?? 'system';
      priceUnit = j['priceUnit'] as String? ?? 'quintal';
      fahrenheit = j['fahrenheit'] == true;
      if (j['location'] != null) {
        location = FarmLocation.fromJson(
          Map<String, dynamic>.from(j['location'] as Map),
        );
      }
      soilHistory = (j['soilHistory'] as List? ?? [])
          .map((e) => SoilRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      soil = soilHistory.isEmpty ? null : soilHistory.first;
      for (final entry in (j['farmSoils'] as Map? ?? {}).entries) {
        _farmSoils['${entry.key}'] = (entry.value as List)
            .map(
              (e) => SoilRecord.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
      notes = (j['notes'] as List? ?? [])
          .map((e) => PriceNote.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      weather = j['weather'] == null
          ? null
          : Map<String, dynamic>.from(j['weather'] as Map);
      weatherFetchedAt = j['weatherFetchedAt'] as String?;
    } catch (_) {
      storageError = 'Could not read local records. Existing storage has not been replaced.';
    }
    crops =
        (jsonDecode(await rootBundle.loadString('assets/catalog/crops.json'))
                as List)
            .map((e) => Crop.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
    notifyListeners();
  }

  String _farmKey(FarmLocation farm) =>
      '${farm.label}|${farm.latitude}|${farm.longitude}';
  Map<String, dynamic> snapshot() => {
    'language': language,
    'theme': theme,
    'priceUnit': priceUnit,
    'fahrenheit': fahrenheit,
    'location': location?.toJson(),
    'soilHistory': soilHistory.map((e) => e.toJson()).toList(),
    'farmSoils': _farmSoils.map(
      (key, values) => MapEntry(key, values.map((e) => e.toJson()).toList()),
    ),
    'notes': notes.map((e) => e.toJson()).toList(),
    'weather': weather,
    'weatherFetchedAt': weatherFetchedAt,
  };
  Future<void> save() {
    final value = snapshot();
    _pending = _pending
        .then((_) => store.write(value))
        .then((_) {
          storageError = null;
        })
        .catchError((Object _) {
          storageError = 'Changes could not be saved on this device.';
        });
    notifyListeners();
    return _pending.then((_) => notifyListeners());
  }

  Future<void> setLocation(FarmLocation value) async {
    if (location != null) {
      _farmSoils[_farmKey(location!)] = List.of(soilHistory);
    }
    _generation++;
    location = value;
    weather = null;
    weatherFetchedAt = null;
    weatherError = null;
    busy = false;
    // Soil is scoped to the selected farm. Changing it must not reuse old field data.
    soilHistory = List.of(_farmSoils[_farmKey(value)] ?? []);
    soil = soilHistory.isEmpty ? null : soilHistory.first;
    await save();
    await refreshWeather();
  }

  Future<void> addSoil(SoilRecord value) async {
    soil = value;
    soilHistory.insert(0, value);
    if (location != null) {
      _farmSoils[_farmKey(location!)] = List.of(soilHistory);
    }
    await save();
  }

  Future<void> addNote(PriceNote value) async {
    notes.insert(0, value);
    await save();
  }

  double? temperature(num? n) => n == null
      ? null
      : fahrenheit
      ? n.toDouble() * 9 / 5 + 32
      : n.toDouble();
  String get tempUnit => fahrenheit ? '°F' : '°C';
  bool get stale =>
      weatherFetchedAt == null ||
      DateTime.now().difference(DateTime.parse(weatherFetchedAt!)).inHours >= 3;

  Future<void> refreshWeather() async {
    final farm = location;
    if (farm?.latitude == null || farm?.longitude == null) {
      weatherError = 'Choose GPS or a PIN location to load weather.';
      notifyListeners();
      return;
    }
    final generation = ++_generation;
    busy = true;
    weatherError = null;
    notifyListeners();
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '${farm!.latitude}',
        'longitude': '${farm.longitude}',
        'current': 'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,weather_code',
        'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max',
        'timezone': 'auto',
        'forecast_days': '7',
      });
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) throw const FormatException();
      final value = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      if (value['current'] is! Map || value['daily'] is! Map) {
        throw const FormatException();
      }
      if (generation != _generation) return;
      weather = value;
      weatherFetchedAt = DateTime.now().toUtc().toIso8601String();
      await save();
    } catch (_) {
      if (generation == _generation) {
        weatherError =
            'Weather could not refresh. Check your connection and try again.';
      }
    } finally {
      if (generation == _generation) {
        busy = false;
        notifyListeners();
      }
    }
  }
}
