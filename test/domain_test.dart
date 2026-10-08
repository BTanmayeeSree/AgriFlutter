import 'package:flutter_test/flutter_test.dart';
import 'package:agri_flutter/core/controller.dart';
import 'package:agri_flutter/core/models.dart';
import 'package:agri_flutter/core/store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('canonical market prices round-trip through every display unit', () {
    for (final unit in ['kg', 'quintal', 'tonne']) {
      expect(
        canonicalPrice(displayPrice(2375, unit), unit),
        closeTo(2375, .001),
      );
    }
  });
  test(
    'catalog imports all crops and stable ranking handles absent pH',
    () async {
      final c = AppController(MemoryStore());
      await c.load();
      expect(c.crops.length, 24);
      final soil = SoilRecord(type: 'alluvial', date: '2026-10-08');
      final first = rankCrops(c.crops, soil, 'kharif');
      expect(
        first.map((e) => e.crop.id),
        rankCrops(
          c.crops.reversed.toList(),
          soil,
          'kharif',
        ).map((e) => e.crop.id),
      );
      expect(first.every((e) => e.score >= 0 && e.score <= 70), isTrue);
    },
  );
  test('soil and settings survive a repository restart', () async {
    final store = MemoryStore();
    final c = AppController(store);
    await c.load();
    await c.setLocation(const FarmLocation('Medak', 'Telangana'));
    await c.addSoil(
      const SoilRecord(type: 'clay', date: '2026-10-08', ph: 6.4),
    );
    c.language = 'te';
    await c.save();
    final next = AppController(store);
    await next.load();
    expect(next.soil?.ph, 6.4);
    expect(next.soil?.n, isNull);
    expect(next.language, 'te');
  });
  test(
    'farm changes isolate soil and returning restores old records',
    () async {
      final c = AppController(MemoryStore());
      await c.load();
      const first = FarmLocation('Medak', 'Telangana');
      await c.setLocation(first);
      await c.addSoil(
        const SoilRecord(type: 'clay', date: '2026-10-08', ph: 6.4),
      );
      await c.setLocation(const FarmLocation('Guntur', 'Andhra Pradesh'));
      expect(c.soil, isNull);
      await c.setLocation(first);
      expect(c.soil?.ph, 6.4);
    },
  );
}
