import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_flutter/main.dart';
import 'package:agri_flutter/core/controller.dart';
import 'package:agri_flutter/core/models.dart';
import 'package:agri_flutter/core/store.dart';

void main() {
  testWidgets(
    'navigation renders at small phone width and opens farm records',
    (tester) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = AppController(MemoryStore());
      await tester.runAsync(() async {
        await c.load();
        final loader = FontLoader('AgriSans')
          ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf'));
        await loader.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        debugPrint(details.toString());
        previous?.call(details);
      };
      addTearDown(() => FlutterError.onError = previous);
      await tester.pumpWidget(AgriApp(controller: c));
      await tester.pumpAndSettle();
      expect(find.text('Your farm, in focus.'), findsOneWidget);
      await tester.tap(find.text('Farm').last);
      await tester.pumpAndSettle();
      expect(find.text('Growing starts here.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('glass home is rendered with explicitly cached weather', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = AppController(MemoryStore());
    await tester.runAsync(() async {
      await c.load();
      final loader = FontLoader('AgriSans')
        ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf'));
      await loader.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    c.location = const FarmLocation('Medak', 'Telangana');
    c.weather = {
      'current': {
        'temperature_2m': 28,
        'relative_humidity_2m': 65,
        'wind_speed_10m': 12,
        'precipitation': 0,
        'time': '2026-10-08T09:00',
      },
    };
    c.weatherFetchedAt = '2020-01-01T00:00:00Z';
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('preview'),
        child: AgriApp(controller: c),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Saved weather · may be out of date'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const ValueKey('preview')),
      matchesGoldenFile('goldens/home.png'),
    );
    c.soil = const SoilRecord(type: 'alluvial', date: '2026-10-08', ph: 6.5);
    await tester.tap(find.text('Farm').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const ValueKey('preview')),
      matchesGoldenFile('goldens/farm.png'),
    );
    await tester.tap(find.text('Scan').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const ValueKey('preview')),
      matchesGoldenFile('goldens/scan.png'),
    );
  });
  testWidgets('scaled text remains usable on a 320-pixel phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = AppController(MemoryStore());
    await tester.runAsync(() async {
      await c.load();
      final loader = FontLoader('AgriSans')
        ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf'));
      await loader.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint(details.toString());
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 1000),
          textScaler: TextScaler.linear(2),
        ),
        child: AgriApp(controller: c),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
