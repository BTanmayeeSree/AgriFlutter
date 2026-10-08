# AgriFlutter

Flutter/Dart mobile farming companion for Android and iOS, based on AgriSakshi. The first implementation is now present, with a clean glassmorphism interface. This is an initial working foundation, not the completed PRD or a production release.

## Implemented

- Five destinations: Home, Farm, Scan, Market, Account.
- Translucent cards, gradient atmosphere, blurred floating navigation, light/dark/system themes and bundled licensed typography.
- Manual/GPS/PIN district selection; confirmed GPS coordinates support Open-Meteo weather and a seven-day forecast.
- SQLite snapshot persistence for settings, soil histories and personal price notes; farm soil scopes are separate.
- All 24 source crop entries and English cultivation guides; preliminary deterministic catalog compatibility ranking.
- Camera/gallery preview using platform plugins. No inference/upload is performed until the analysis backend is implemented.
- Personal price notes and consistent kg/quintal/tonne display conversion.
- English/Hindi/Telugu navigation and key headings; full content localization remains outstanding.

## Run and verify

Developed with Flutter 3.47.6 / Dart 3.13.5. Use a compatible stable Flutter SDK and Android tooling; iOS requires macOS/Xcode. Only android and ios platform directories exist.

```powershell
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d <mobile-device-id>
```

A session-local SDK is available at C:\Users\anant\.codex\visualizations\2026\10\07\01a117b1-0b4d-7152-bc42-21ca24fe7f37\flutter\bin\flutter.bat. It was used through its explicit path, without changing your global PATH. Android SDK was not found, so an APK/native device run has not been verified. No mobile device was connected during development.

## Verification

11 domain/service/widget tests passed. Flutter analyze reported no issues after final fixes. Tests cover unit conversion, catalog import, stable ranking, persistence through an injected repository, farm record isolation, PIN lookup, cached weather on failure, late-response protection, small-phone navigation and 200% text. Flutter-rendered golden images were visually inspected. Native SQLite/plugin behavior, device performance and iOS compilation are still unverified.

## Documentation

- [PRD](docs/PRD.md)
- [Source analysis](docs/SOURCE_ANALYSIS.md)
- [Implementation plan](docs/IMPLEMENTATION_PLAN.md)
- [Implementation status](docs/IMPLEMENTATION_STATUS.md)
- [Glassmorphism design](docs/DESIGN.md)

Home/Farm preview images under docs/previews use explicit test fixtures, not live farm data. Production code does not substitute fixture weather or market quotations.

The original ../Agri_Sakshi source remains unchanged. Backend accounts/sync, AI analysis, official market adapters, complete localization, calibrated chemical testing and release validation remain later work.
