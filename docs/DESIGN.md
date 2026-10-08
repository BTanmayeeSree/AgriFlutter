# Glassmorphism design system

Accepted direction: user requested a modern, clean UI using glassmorphism on 8 October 2026. This supplements PRD section 4.

## Surfaces

Use a pale sage/cream/mint gradient atmosphere, subtle radial light pools and translucent white cards (80% opacity). Dark mode uses deep forest surfaces and muted light pools. Frosted panels have a 26-pixel radius, a fine light border and restrained shadow. Blur is limited to selected panels and the floating navigation; ordinary scrolling cards rely on tint and transparency to reduce GPU work. Measure native-device performance before claiming this is optimized.

Forest #205B45 anchors buttons, icons and primary identity. Mint #BCE9CD marks selection. Body text uses opaque dark forest in light mode and near-white in dark mode. Informational badges use an icon and words, never color alone.

## Hierarchy and mobile ergonomics

Single-column pages with 20-pixel page gutters and at least 48-pixel action targets. Large weather temperature is light-weight; headings use compact bold typography. Card content begins with the most useful detail, with provenance/date alongside data. Text expands and pages scroll at large font scales. Bottom navigation is a floating frosted capsule with five labeled destinations.

Do not put key information over busy photographs or increase blur across every card. Empty/unconfigured services use real informative states; decorative glass does not obscure sources or unknown values.

## Components

lib/ui/glass.dart: Glass, Atmosphere, SectionTitle, Tag and EmptyCard.
lib/main.dart: semantic light/dark themes, typography, button/input styles and locale setup.
lib/ui/screens.dart: Home, Farm, Scan, Market, Account and detail screens.
lib/ui/editors.dart: responsive bottom sheets for language, farm location, soil and prices.

Bundled Roboto assets include their license. Hindi/Telugu shaping and fallback fonts must be verified on native devices before release.

## Preview evidence

- previews/home-fixture.png: real Flutter-rendered Home using explicitly cached test weather.
- previews/farm-fixture.png: real Flutter-rendered Farm using a test soil record and preliminary compatibility rules.
- previews/scan.png: real Flutter-rendered camera/gallery interface with the service-unavailable state.

These are screenshots rendered by Flutter's widget test engine, not AI-generated mockups and not evidence of a physical-device run. Light surfaces and typography were visually inspected. Native contrast, screen readers, other locales, all themes and performance still need a broader audit.
