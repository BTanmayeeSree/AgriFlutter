AgriFlutter

AgriFlutter is a Flutter/Dart farming companion for Android, iOS, and web, featuring a glassmorphism interface.

Implemented Features

- Five destinations: Home, Farm, Scan, Market, and Account.
- Translucent cards, gradients, floating navigation, and light/dark/system themes.
- Manual, GPS, and PIN-based district selection.
- Weather integration using Open-Meteo and a seven-day forecast.
- SQLite persistence for settings, soil histories, and personal price notes.
- Crop catalog with 24 source entries and English cultivation guides.
- Camera/gallery preview for crop analysis.
- Personal price notes with kg, quintal, and tonne conversions.
- English, Hindi, and Telugu navigation and key headings.

Run the Project

Install Flutter and the required platform tooling, then run:

flutter pub get
flutter analyze
flutter test
flutter devices
flutter run

To build the web version:

flutter create . --platforms web
flutter build web --release

The generated web files are saved in "build/web".

Verification

The project documentation reports 11 passing domain, service, and widget tests. Native plugin behavior and production device builds require additional verification.

Documentation

- "Product Requirements" (docs/PRD.md)
- "Source Analysis" (docs/SOURCE_ANALYSIS.md)
- "Implementation Plan" (docs/IMPLEMENTATION_PLAN.md)
- "Implementation Status" (docs/IMPLEMENTATION_STATUS.md)
- "Design" (docs/DESIGN.md)

Development Status

AgriFlutter is an ongoing project, not a completed production release. Backend accounts and synchronization, AI crop analysis, official market data integrations, complete localization, and release validation remain future work.