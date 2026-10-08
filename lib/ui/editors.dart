import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../core/controller.dart';
import '../core/models.dart';
import '../core/location_lookup.dart';
import 'strings.dart';

Future<void> languageSheet(BuildContext context, AppController c) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in {
              'en': 'English',
              'hi': 'हिंदी',
              'te': 'తెలుగు',
            }.entries)
              ListTile(
                title: Text(entry.value),
                trailing: c.language == entry.key
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  c.language = entry.key;
                  c.save();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );

Future<void> locationSheet(BuildContext context, AppController c) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => LocationEditor(c),
    );

class LocationEditor extends StatefulWidget {
  const LocationEditor(this.c, {super.key});
  final AppController c;
  @override
  State<LocationEditor> createState() => _LocationEditorState();
}

class _LocationEditorState extends State<LocationEditor> {
  final form = GlobalKey<FormState>();
  late final district = TextEditingController(
    text: widget.c.location?.district,
  );
  late final state = TextEditingController(text: widget.c.location?.state);
  late double? lat = widget.c.location?.latitude,
      lon = widget.c.location?.longitude;
  final pin = TextEditingController();
  final lookup = LocationLookup();
  List<FarmLocation> candidates = [];
  String? error;
  bool busy = false;
  @override
  void dispose() {
    pin.dispose();
    lookup.close();
    district.dispose();
    state.dispose();
    super.dispose();
  }

  Future<void> searchPin() async {
    setState(() {
      busy = true;
      error = null;
      candidates = [];
    });
    try {
      final results = await lookup.byPin(pin.text.trim());
      if (mounted) {
        setState(() {
          candidates = results;
          if (results.isEmpty) {
            error = 'No location matches this PIN. Try manual entry.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is FormatException
              ? e.message
              : 'PIN lookup failed. Manual entry is still available.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> gps() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError(
          'Location is switched off. You can still enter your district and state.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError(
          'Location permission is unavailable. Please enter your district and state manually.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (mounted) {
        setState(() {
          lat = position.latitude;
          lon = position.longitude;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is StateError
              ? e.message
              : 'Location could not be found. Manual entry is still available.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Strings(widget.c.language);
    return editorLayout(
      context,
      Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('Choose your farm'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const Text(
              'Select the farm you want to follow. GPS is optional; it uses your phone’s current position.',
            ),
            const SizedBox(height: 18),
            TextField(
              controller: pin,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Indian postal PIN'),
            ),
            TextButton.icon(
              onPressed: busy ? null : searchPin,
              icon: const Icon(Icons.search),
              label: const Text('Find district from PIN'),
            ),
            for (final candidate in candidates)
              ListTile(
                title: Text(candidate.label),
                subtitle: const Text(
                  'PIN district only · no field coordinates',
                ),
                onTap: () {
                  setState(() {
                    district.text = candidate.district;
                    state.text = candidate.state;
                    lat = null;
                    lon = null;
                    candidates = [];
                  });
                },
              ),
            OutlinedButton.icon(
              onPressed: busy ? null : gps,
              icon: const Icon(Icons.my_location),
              label: Text(busy ? 'Finding location…' : 'Use my location'),
            ),
            if (lat != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Selected: ${lat!.toStringAsFixed(3)}, ${lon!.toStringAsFixed(3)}. Confirm this is your farm.',
                ),
              ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(error!),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: district,
              decoration: InputDecoration(labelText: t('District')),
              validator: requiredText,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: state,
              decoration: InputDecoration(labelText: t('State')),
              validator: requiredText,
            ),
            const SizedBox(height: 12),
            const Text(
              'Changing the farm clears its active soil context. Personal price notes stay on this device.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        if (!form.currentState!.validate()) return;
                        final c = widget.c;
                        final value = FarmLocation(
                          district.text.trim(),
                          state.text.trim(),
                          latitude: lat,
                          longitude: lon,
                        );
                        Navigator.pop(context);
                        await c.setLocation(value);
                      },
                child: Text(t('Save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> soilSheet(BuildContext context, AppController c) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SoilEditor(c),
    );

class SoilEditor extends StatefulWidget {
  const SoilEditor(this.c, {super.key});
  final AppController c;
  @override
  State<SoilEditor> createState() => _SoilEditorState();
}

class _SoilEditorState extends State<SoilEditor> {
  final form = GlobalKey<FormState>();
  late String type = widget.c.soil?.type ?? 'alluvial',
      unit = widget.c.soil?.unit ?? 'mg/kg';
  late final values = [
    widget.c.soil?.ph,
    widget.c.soil?.n,
    widget.c.soil?.p,
    widget.c.soil?.k,
  ].map((v) => TextEditingController(text: v?.toString() ?? '')).toList();
  @override
  void dispose() {
    for (final v in values) {
      v.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Strings(widget.c.language);
    return editorLayout(
      context,
      Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('Add a soil record'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              t(
                'Record your laboratory or kit readings. Unknown values stay blank.',
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'Soil type'),
              items: [
                for (final s in [
                  'alluvial',
                  'clay',
                  'loam',
                  'sandy loam',
                  'black',
                  'red',
                  'laterite',
                  'sandy',
                ])
                  DropdownMenuItem(value: s, child: Text(s)),
              ],
              onChanged: (v) => type = v!,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: unit,
              decoration: const InputDecoration(
                labelText: 'N / P / K laboratory unit',
              ),
              items: [
                for (final s in ['mg/kg', 'kg/ha', 'mg/L'])
                  DropdownMenuItem(value: s, child: Text(s)),
              ],
              onChanged: (v) => unit = v!,
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < values.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: values[i],
                  decoration: InputDecoration(
                    labelText: [
                      'pH (optional)',
                      'Nitrogen (optional)',
                      'Phosphorus (optional)',
                      'Potassium (optional)',
                    ][i],
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (text) {
                    if (text == null || text.trim().isEmpty) return null;
                    final number = double.tryParse(text);
                    if (number == null ||
                        !number.isFinite ||
                        number < 0 ||
                        (i == 0 && number > 14)) {
                      return i == 0
                          ? 'Use a pH from 0 to 14.'
                          : 'Enter a finite, nonnegative value.';
                    }
                    return null;
                  },
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (!form.currentState!.validate()) return;
                  final numbers = values
                      .map((v) => double.tryParse(v.text))
                      .toList();
                  final c = widget.c;
                  final record = SoilRecord(
                    type: type,
                    unit: unit,
                    date: DateTime.now().toUtc().toIso8601String(),
                    ph: numbers[0],
                    n: numbers[1],
                    p: numbers[2],
                    k: numbers[3],
                  );
                  await c.addSoil(record);
                  if (context.mounted && c.storageError == null) {
                    Navigator.pop(context);
                  }
                },
                child: Text(t('Save')),
              ),
            ),
            if (widget.c.storageError != null) Text(widget.c.storageError!),
          ],
        ),
      ),
    );
  }
}

Future<void> priceSheet(BuildContext context, AppController c) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => PriceEditor(c),
    );

class PriceEditor extends StatefulWidget {
  const PriceEditor(this.c, {super.key});
  final AppController c;
  @override
  State<PriceEditor> createState() => _PriceEditorState();
}

class _PriceEditorState extends State<PriceEditor> {
  final form = GlobalKey<FormState>();
  final crop = TextEditingController(),
      mandi = TextEditingController(),
      price = TextEditingController();
  @override
  void dispose() {
    crop.dispose();
    mandi.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => editorLayout(
    context,
    Form(
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings(widget.c.language)('Add a price note'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: crop,
            decoration: const InputDecoration(labelText: 'Crop / commodity'),
            validator: requiredText,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: mandi,
            decoration: const InputDecoration(labelText: 'Market / mandi'),
            validator: requiredText,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: price,
            decoration: InputDecoration(labelText: '₹ / ${widget.c.priceUnit}'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              final n = double.tryParse(v ?? '');
              return n == null || !n.isFinite || n <= 0
                  ? 'Enter a positive price.'
                  : null;
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                if (!form.currentState!.validate()) return;
                final c = widget.c;
                await c.addNote(
                  PriceNote(
                    crop.text.trim(),
                    mandi.text.trim(),
                    canonicalPrice(double.parse(price.text), c.priceUnit),
                    DateTime.now().toUtc().toIso8601String(),
                  ),
                );
                if (context.mounted && c.storageError == null) {
                  Navigator.pop(context);
                }
              },
              child: Text(Strings(widget.c.language)('Save')),
            ),
          ),
        ],
      ),
    ),
  );
}

String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required.' : null;
Widget editorLayout(BuildContext context, Widget child) => SafeArea(
  child: SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      22,
      8,
      22,
      MediaQuery.viewInsetsOf(context).bottom + 22,
    ),
    child: child,
  ),
);
