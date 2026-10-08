import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:agri_flutter/core/controller.dart';
import 'package:agri_flutter/core/location_lookup.dart';
import 'package:agri_flutter/core/models.dart';
import 'package:agri_flutter/core/store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('PIN lookup validates input and preserves no-match as empty', () async {
    final lookup = LocationLookup(
      client: MockClient(
        (_) async => http.Response('[{"PostOffice":null}]', 200),
      ),
    );
    await expectLater(lookup.byPin('12'), throwsFormatException);
    expect(await lookup.byPin('500001'), isEmpty);
  });
  test(
    'PIN lookup deduplicates district candidates without invented coordinates',
    () async {
      final lookup = LocationLookup(
        client: MockClient(
          (_) async => http.Response(
            '[{"PostOffice":[{"District":"Hyderabad","State":"Telangana"},{"District":"Hyderabad","State":"Telangana"}]}]',
            200,
          ),
        ),
      );
      final candidates = await lookup.byPin('500001');
      expect(candidates.length, 1);
      expect(candidates.first.latitude, isNull);
    },
  );
  test(
    'failed weather refresh keeps cached observations and reports failure',
    () async {
      final c = AppController(
        MemoryStore(),
        client: MockClient((_) async => http.Response('unavailable', 503)),
      );
      await c.load();
      c.location = const FarmLocation(
        'Medak',
        'Telangana',
        latitude: 17,
        longitude: 78,
      );
      c.weather = {
        'current': {'temperature_2m': 28},
      };
      await c.refreshWeather();
      expect(c.weather?['current']['temperature_2m'], 28);
      expect(c.weatherError, isNotNull);
      expect(c.busy, isFalse);
    },
  );
  test('a late weather response cannot overwrite a different farm', () async {
    final response = Completer<http.Response>();
    final c = AppController(
      MemoryStore(),
      client: MockClient((_) => response.future),
    );
    await c.load();
    c.location = const FarmLocation(
      'Medak',
      'Telangana',
      latitude: 17,
      longitude: 78,
    );
    final pending = c.refreshWeather();
    await c.setLocation(const FarmLocation('Guntur', 'Andhra Pradesh'));
    response.complete(
      http.Response('{"current":{"temperature_2m":28},"daily":{}}', 200),
    );
    await pending;
    expect(c.location?.district, 'Guntur');
    expect(c.weather, isNull);
  });
}
