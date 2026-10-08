import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/controller.dart';
import '../core/models.dart';
import 'glass.dart';
import 'strings.dart';
import 'editors.dart';

class MobileShell extends StatefulWidget {
  const MobileShell(this.controller, {super.key});
  final AppController controller;
  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final c = widget.controller, t = Strings(widget.controller.language);
    return Atmosphere(
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 16, 4),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: forest,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.eco_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'AgriFlutter',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.6,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: t('Language'),
                      onPressed: () => languageSheet(context, c),
                      icon: const Icon(Icons.translate_rounded),
                    ),
                  ],
                ),
              ),
              if (c.storageError != null)
                MaterialBanner(
                  content: Text(c.storageError!),
                  actions: [
                    TextButton(onPressed: c.save, child: const Text('Retry')),
                  ],
                ),
              Expanded(
                child: IndexedStack(
                  index: index,
                  children: [
                    HomePage(c, onTab: (i) => setState(() => index = i)),
                    FarmPage(c),
                    ScanPage(c),
                    MarketPage(c),
                    AccountPage(c),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Glass(
            blur: true,
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              height: 72,
              elevation: 0,
              selectedIndex: index,
              indicatorColor: mint.withValues(alpha: .65),
              onDestinationSelected: (i) => setState(() => index = i),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: t('Home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.grass_outlined),
                  label: t('Farm'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.center_focus_strong_outlined),
                  label: t('Scan'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.insights_outlined),
                  label: t('Market'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  label: t('Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    children: children,
  );
}

class HomePage extends StatelessWidget {
  const HomePage(this.c, {super.key, required this.onTab});
  final AppController c;
  final ValueChanged<int> onTab;
  @override
  Widget build(BuildContext context) {
    final t = Strings(c.language);
    return PageBody(
      children: [
        SectionTitle(
          t('Your farm, in focus.'),
          subtitle: t('A little clarity for every growing day.'),
        ),
        Glass(
          blur: true,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.location?.label ?? t('Choose your farm'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: t('Choose your farm'),
                onPressed: () => locationSheet(context, c),
                icon: const Icon(Icons.edit_location_alt_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        WeatherCard(c),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _shortcut(
              context,
              t('Soil record'),
              Icons.layers_outlined,
              () => onTab(1),
            ),
            _shortcut(
              context,
              t('Recommend crops'),
              Icons.spa_outlined,
              () => onTab(1),
            ),
            _shortcut(
              context,
              t('Scan a plant'),
              Icons.filter_center_focus,
              () => onTab(2),
            ),
            _shortcut(
              context,
              t('Market'),
              Icons.insights_outlined,
              () => onTab(3),
            ),
          ],
        ),
        SectionTitle(
          t('Soil record'),
          action: TextButton(
            onPressed: () => soilSheet(context, c),
            child: Text(c.soil == null ? t('Add a soil record') : 'Edit'),
          ),
        ),
        if (c.soil == null)
          EmptyCard(
            icon: Icons.layers_outlined,
            title: t('No soil record yet'),
            message: t(
              'Record your laboratory or kit readings. Unknown values stay blank.',
            ),
          )
        else
          SoilCard(c),
        const SizedBox(height: 20),
        Glass(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A good place to start',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t(
                        'Record your laboratory or kit readings. Unknown values stay blank.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shortcut(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback action,
  ) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 50) / 2,
    child: Glass(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: action,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 26),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    ),
  );
}

class WeatherCard extends StatelessWidget {
  const WeatherCard(this.c, {super.key});
  final AppController c;
  @override
  Widget build(BuildContext context) {
    final t = Strings(c.language);
    final current = c.weather?['current'] as Map?;
    if (current == null) {
      return EmptyCard(
        icon: Icons.cloud_outlined,
        title: t('Weather'),
        message: c.weatherError ?? 'Choose your farm location to see current conditions and the week ahead.',
        action: c.busy
            ? const LinearProgressIndicator()
            : FilledButton.icon(
                onPressed: c.location?.latitude == null
                    ? () => locationSheet(context, c)
                    : c.refreshWeather,
                icon: const Icon(Icons.location_on_outlined),
                label: Text(
                  c.location?.latitude == null
                      ? t('Choose your farm')
                      : t('Refresh'),
                ),
              ),
      );
    }
    final temp = c.temperature(current['temperature_2m'] as num?);
    return Glass(
      tint: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xe626493a)
          : const Color(0xe6d7ecdc),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t('Weather'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: t('Refresh'),
                onPressed: c.busy ? null : c.refreshWeather,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  temp == null ? '—' : '${temp.round()}${c.tempUnit}',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -3,
                  ),
                ),
              ),
              const Icon(Icons.wb_sunny_outlined, size: 65),
            ],
          ),
          Text(
            'Open-Meteo · ${current['time'] ?? 'Observation unavailable'}',
            style: const TextStyle(fontSize: 12),
          ),
          if (c.stale)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Tag(
                'Saved weather · may be out of date',
                icon: Icons.history,
              ),
            ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              metric(
                Icons.water_drop_outlined,
                '${current['relative_humidity_2m'] ?? '—'}%',
                'Humidity',
              ),
              metric(
                Icons.air,
                '${current['wind_speed_10m'] ?? '—'} km/h',
                'Wind',
              ),
              metric(
                Icons.grain,
                '${current['precipitation'] ?? '—'} mm',
                'Rain',
              ),
            ],
          ),
          if (c.busy)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
          if (c.weatherError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(c.weatherError!),
            ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => WeatherPage(c)),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(t('Seven-day outlook')),
          ),
        ],
      ),
    );
  }

  Widget metric(IconData icon, String value, String name) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(name, style: const TextStyle(fontSize: 11)),
        ],
      ),
    ],
  );
}

class WeatherPage extends StatelessWidget {
  const WeatherPage(this.c, {super.key});
  final AppController c;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: c,
    builder: (context, _) {
      final daily = c.weather?['daily'] as Map?;
      final dates = daily?['time'] as List? ?? [];
      num? number(String key, int i) {
        final values = daily?[key] as List?;
        return values != null && i < values.length ? values[i] as num? : null;
      }

      return Atmosphere(
        child: Scaffold(
          appBar: AppBar(title: Text(Strings(c.language)('Seven-day outlook'))),
          body: PageBody(
            children: [
              Text(c.location?.label ?? ''),
              const SizedBox(height: 16),
              for (var i = 0; i < dates.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${dates[i]}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 18,
                          runSpacing: 8,
                          children: [
                            Text(
                              '${c.temperature(number('temperature_2m_min', i))?.round() ?? '—'} – ${c.temperature(number('temperature_2m_max', i))?.round() ?? '—'}${c.tempUnit}',
                            ),
                            Text(
                              '${number('precipitation_sum', i) ?? '—'} mm rain',
                            ),
                            Text(
                              '${number('wind_speed_10m_max', i) ?? '—'} km/h',
                            ),
                          ],
                        ),
                        if ((number('precipitation_sum', i) ?? 0) >= 20)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Tag(
                              'App advisory: rain expected; check field drainage.',
                            ),
                          ),
                        if ((number('temperature_2m_max', i) ?? 0) >= 38)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Tag(
                              'App advisory: high temperature expected.',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const Text(
                'Open-Meteo forecast · App advisories are derived from forecast values, not official warnings.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class SoilCard extends StatelessWidget {
  const SoilCard(this.c, {super.key});
  final AppController c;
  @override
  Widget build(BuildContext context) => Glass(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                c.soil!.type,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Tag('Farmer entry', icon: Icons.edit_outlined),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 22,
          runSpacing: 12,
          children: [
            Text('pH  ${c.soil!.ph ?? '—'}'),
            Text('N  ${c.soil!.n ?? '—'}'),
            Text('P  ${c.soil!.p ?? '—'}'),
            Text('K  ${c.soil!.k ?? '—'}'),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'N / P / K in ${c.soil!.unit} · ${c.soil!.date.substring(0, 10)}',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          Strings(c.language)('Saved on this device'),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}

class FarmPage extends StatefulWidget {
  const FarmPage(this.c, {super.key});
  final AppController c;
  @override
  State<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  String query = '', season = 'kharif';
  @override
  Widget build(BuildContext context) {
    final c = widget.c, t = Strings(widget.c.language);
    final ranked = c.soil == null
        ? <RankedCrop>[]
        : rankCrops(c.crops, c.soil!, season);
    return PageBody(
      children: [
        SectionTitle(
          t('Growing starts here.'),
          subtitle: c.location?.label ?? t('Choose your farm'),
        ),
        if (c.location == null)
          FilledButton.icon(
            onPressed: () => locationSheet(context, c),
            icon: const Icon(Icons.location_on_outlined),
            label: Text(t('Choose your farm')),
          ),
        if (c.soil != null) SoilCard(c),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: c.location == null
              ? () => locationSheet(context, c)
              : () => soilSheet(context, c),
          icon: const Icon(Icons.add),
          label: Text(t('Add a soil record')),
        ),
        SectionTitle(t('Recommend crops')),
        if (ranked.isEmpty)
          EmptyCard(
            icon: Icons.spa_outlined,
            title: t('No soil record yet'),
            message: 'Add your soil type and optional pH to compare the crop catalog. Nothing is inferred from your GPS location.',
          ),
        if (ranked.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            children: [
              for (final value in ['kharif', 'rabi', 'summer'])
                ChoiceChip(
                  label: Text(value),
                  selected: season == value,
                  onSelected: (_) => setState(() => season = value),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Tag('Preliminary rules · soil + pH + season'),
          const SizedBox(height: 12),
          const Text(
            'Catalog compatibility only. Local climate, irrigation and agronomic review are still required; this score does not predict yield or profit.',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          for (final r in ranked.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Glass(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.eco_outlined),
                  title: Text(
                    r.crop.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    r.reasons.isEmpty
                        ? 'No matching catalog factors'
                        : r.reasons.join(' · '),
                  ),
                  trailing: Text('${r.score}/100'),
                  onTap: () => openCrop(context, r.crop),
                ),
              ),
            ),
        ],
        SectionTitle(
          t('Crop library'),
          subtitle: '${c.crops.length} crops · offline reference',
        ),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: t('Search crops'),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 14),
        for (final crop in c.crops.where(
          (v) => v.name.toLowerCase().contains(query.toLowerCase()),
        ))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Glass(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: const Icon(Icons.grass),
                title: Text(
                  crop.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${crop.category} · ${crop.season}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => openCrop(context, crop),
              ),
            ),
          ),
        if (!c.crops.any(
          (v) => v.name.toLowerCase().contains(query.toLowerCase()),
        ))
          const Text('No crops match this search.'),
      ],
    );
  }
}

void openCrop(BuildContext context, Crop crop) => Navigator.push(
  context,
  MaterialPageRoute<void>(
    builder: (_) => Atmosphere(
      child: Scaffold(
        appBar: AppBar(title: Text(crop.name)),
        body: PageBody(
          children: [
            Glass(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Tag('Source catalog · review pending'),
                  const SizedBox(height: 14),
                  Text('${crop.category} · ${crop.season}'),
                  const SizedBox(height: 8),
                  Text('Soils: ${crop.soils.join(', ')}'),
                  Text('Catalog pH: ${crop.phMin} – ${crop.phMax}'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Reference content is currently available in English. Confirm regional applicability with your agricultural advisor.',
              style: TextStyle(fontSize: 12, height: 1.5),
            ),
            for (final section in crop.guide.entries)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Glass(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      section.key.replaceAllMapped(
                        RegExp(r'[A-Z]'),
                        (m) => ' ${m[0]}',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                        child: Text(
                          flatten(section.value),
                          style: const TextStyle(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  ),
);

String flatten(dynamic value) {
  if (value is Map) {
    return value.entries
        .map((e) => '${e.key}: ${flatten(e.value)}')
        .join('\n\n');
  }
  if (value is List) return value.map((e) => '• $e').join('\n');
  return '$value';
}

class ScanPage extends StatefulWidget {
  const ScanPage(this.c, {super.key});
  final AppController c;
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  XFile? photo;
  bool picking = false;
  String? error;
  Future<void> pick(ImageSource source) async {
    setState(() {
      picking = true;
      error = null;
    });
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (image != null && await image.length() > 10 * 1024 * 1024) {
        throw const FormatException('Please choose an image under 10 MB.');
      }
      if (mounted && image != null) setState(() => photo = image);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Photo access was unavailable. Check camera permission or choose a photo.',
        );
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Strings(widget.c.language);
    return PageBody(
      children: [
        SectionTitle(
          t('Look closer. Grow better.'),
          subtitle: t('Plant health'),
        ),
        Glass(
          child: Column(
            children: [
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: forest.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: photo == null
                    ? const Center(
                        child: Icon(
                          Icons.filter_center_focus,
                          size: 78,
                          color: forest,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(File(photo!.path), fit: BoxFit.cover),
                      ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Fill the frame with the affected leaf. Use natural light, hold steady, and keep the symptoms in focus.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: picking ? null : () => pick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(photo == null ? t('Take a photo') : t('Retake')),
                ),
              ),
              TextButton.icon(
                onPressed: picking ? null : () => pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(t('Choose a photo')),
              ),
              if (error != null) Text(error!),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const EmptyCard(
          icon: Icons.cloud_off_outlined,
          title: 'Plant analysis is not available yet',
          message: 'You can take or choose a photo and inspect it here. No photo is uploaded and no diagnosis is generated in this version.',
        ),
      ],
    );
  }
}

class MarketPage extends StatelessWidget {
  const MarketPage(this.c, {super.key});
  final AppController c;
  @override
  Widget build(BuildContext context) {
    final t = Strings(c.language);
    return PageBody(
      children: [
        SectionTitle(
          t('Market watch'),
          subtitle: 'A clearer view of your harvest value.',
        ),
        const EmptyCard(
          icon: Icons.insights_outlined,
          title: 'Mandi prices are unavailable',
          message: 'Live mandi quotations are not available yet. Record prices you receive below; your notes stay separate from reported market prices.',
        ),
        SectionTitle(t('My price notes')),
        FilledButton.icon(
          onPressed: () => priceSheet(context, c),
          icon: const Icon(Icons.add),
          label: Text(t('Add a price note')),
        ),
        const SizedBox(height: 16),
        if (c.notes.isEmpty)
          const Glass(
            child: Text(
              'No price notes yet. Add a quotation you received and the market it came from.',
            ),
          ),
        for (final note in c.notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Glass(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tag(t('Personal price note'), icon: Icons.edit_note),
                  const SizedBox(height: 14),
                  Text(
                    note.crop,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${displayPrice(note.price, c.priceUnit).toStringAsFixed(2)} / ${c.priceUnit}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${note.mandi} · ${note.date.substring(0, 10)}'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage(this.c, {super.key});
  final AppController c;
  @override
  Widget build(BuildContext context) {
    final t = Strings(c.language);
    return PageBody(
      children: [
        SectionTitle(t('Your growing space.')),
        Glass(
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: mint,
                child: const Icon(
                  Icons.person_outline,
                  color: forest,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('Guest on this device'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(c.location?.label ?? t('Choose your farm')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Your farm records and settings stay on this device. Account backup is not available yet.',
          style: TextStyle(height: 1.5, fontSize: 12),
        ),
        SectionTitle(t('Settings')),
        Glass(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.translate),
                title: Text(t('Language')),
                subtitle: Text(
                  {'en': 'English', 'hi': 'हिंदी', 'te': 'తెలుగు'}[c.language]!,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => languageSheet(context, c),
              ),
              const Divider(),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: c.theme,
                decoration: InputDecoration(labelText: t('Appearance')),
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (v) {
                  c.theme = v!;
                  c.save();
                },
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t('Temperature')),
                subtitle: Text(
                  c.fahrenheit ? 'Fahrenheit (°F)' : 'Celsius (°C)',
                ),
                value: c.fahrenheit,
                onChanged: (v) {
                  c.fahrenheit = v;
                  c.save();
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: c.priceUnit,
                decoration: InputDecoration(labelText: t('Price unit')),
                items: const [
                  DropdownMenuItem(
                    value: 'quintal',
                    child: Text('₹ / quintal'),
                  ),
                  DropdownMenuItem(value: 'kg', child: Text('₹ / kg')),
                  DropdownMenuItem(value: 'tonne', child: Text('₹ / tonne')),
                ],
                onChanged: (v) {
                  c.priceUnit = v!;
                  c.save();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your data, your choice.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'No photos are uploaded in this build. Weather requests send only selected coordinates to Open-Meteo. Clearing weather does not delete soil or personal notes.',
                style: TextStyle(height: 1.5),
              ),
              TextButton.icon(
                onPressed: () {
                  c.weather = null;
                  c.weatherFetchedAt = null;
                  c.save();
                },
                icon: const Icon(Icons.cleaning_services_outlined),
                label: const Text('Clear cached weather'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'AgriFlutter · mobile foundation 0.1',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

