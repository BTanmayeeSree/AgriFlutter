# AgriFlutter — Product Requirements Document

Version 1.0 · 8 October 2026 · Ready for design and implementation planning

Source project: Agri_Sakshi. This is a separate mobile product. Application implementation follows this documentation stage.

## 1. Product and goals

AgriFlutter recreates AgriSakshi's farming companion as a Flutter/Dart application strictly for Android and iOS mobile users. It combines farm weather, soil records, crop suitability, cultivation guides, mandi prices and plant health scans. Use native Flutter widgets; exclude WebView wrappers, React Native, browser and desktop builds. Android is the first pilot target, with iOS included in v1 acceptance. Dedicated tablet layouts are outside scope.

Primary users are Indian farmers and family members using English, Hindi or Telugu, often with limited connectivity and smaller phones. Their core jobs are checking weather, recording soil tests, choosing suitable crops, reading growing guides, comparing reported prices and photographing possible plant problems. Advisors may review shared information but have no separate role/dashboard in v1.

Success means farmers can complete these jobs with readable screens, few taps, persistent records and clear distinctions between measurements, estimates and AI suggestions. Proposed pilot targets: 80% complete location setup within two minutes; 80% save a soil record and understand its source without assistance; 80% locate weather, crop guides and scanning within three taps from Home. Measure these in observed usability sessions. No model accuracy, yield or profit guarantee is implied.

## 2. Analysis basis and feature parity

Analysis is based on source inspection, not a running deployment. AgriSakshi uses React 18, TypeScript, Vite, Tailwind, shadcn UI, Supabase and service-specific integrations. Its README is generic Lovable documentation. Production APIs, database policies and agronomic validity remain unverified.

| Source capability | Mobile requirement | Priority |
| --- | --- | --- |
| Home with location/weather/soil and shortcuts | Independent summary cards and persistent selected farm | P0 |
| Climate/current weather/seven-day forecast | Weather detail and dated derived advisories | P0 |
| Regional soil lookup and manual entry | Labeled regional context plus persistent manual/lab records | P0 |
| Camera chloride/nitrate/phosphorus interpretation | Calibrated experimental workflow; manual kit values in v1 | Experimental |
| Crop ranking and growing guides | Explainable ranking and all 24 source catalog crops | P0 |
| Market quotations, estimates and overrides | Reported quotations and separate personal notes | P0 |
| Plant image analysis | Native camera/gallery, secure analysis, saved history | P0 |
| Profile, email/password auth and settings | Optional account, guest mode, profile and sync | P0 |
| English/Hindi/Telugu and unit/theme toggles | Complete localization and functional settings | P0 |
| Market forecasts | Clearly labeled forecasts after historical-data validation | P1 |
| Notification setting | Foreground inbox and optional local reminders | P0 |
| Server push, multiple farms, voice | Separate later work | P1 |

P0 is mandatory for release. P1 follows the core release. Experimental features are hidden from ordinary users until their validation gates pass. Exclude payments, produce trading, logistics, IoT, subsidy applications, continuous GPS and offline AI inference. The source Python CNN training script is not an integrated deployed inference model and will not automatically be ported.

Observed defects to correct: Index.tsx initializes shared forecast without updating it; SoilTab does not consume the parent's onChemicalResults callback; manual/auto soil changes stay in the tab instead of reaching shared recommendation context. RecommendationService makes a direct Anthropic request inconsistent with the common proxy. The claude-proxy implementation actually forwards through OpenRouter. Regional soil nutrients are generated, seasonal weather trends are fixed examples, and market values may use AI or deterministic fallback. Preserve user capabilities without treating these values as verified measurements.

## 3. Mobile navigation and journeys

Use five labeled bottom destinations: Home, Farm, Scan, Market, Account. Weather opens from Home. Soil, Recommendations and Crop Library open from Farm. Profile, Settings, Help and Privacy open from Account. Preserve each tab's navigation stack, scroll and drafts. System Back closes a sheet/editor before returning to its parent. No core interaction depends on hover or a gesture without a visible action.

Journeys:

1. First launch: language → short purpose/privacy introduction → confirmed farm location → optional farm details → Home. Guest use requires no account.
2. Weather: Home summary → current conditions/seven days → advisory details.
3. Farm decision: Farm → Soil → manual/lab record → save → refreshed crop ranking → crop detail → cultivation guide.
4. Scan: Scan → camera/gallery → preview/retake → submission consent → progress → result → saved history.
5. Price check: Market → commodity/mandi/date filters → quotation → optional personal price note.
6. Account: optional sign-up/sign-in/reset → profile and sync; settings remain locally available to guests.

Deep links resolve after authentication if required and show an appropriate unavailable screen for missing/inaccessible records.

## 4. Design specification and screen inventory

Use a calm agricultural palette with opaque readable cards, restrained imagery and clear hierarchy. Proposed tokens: forest primary #25633F, warm background #F7F8F2, white surface, body #18251D, secondary text #526258. Verify contrast before adoption. Dark theme uses equivalent semantic tokens. Severity uses text/icon alongside color. Bundle licensed imagery and fonts supporting all three scripts; do not reuse photographic backgrounds behind dense text.

Phone layout: one vertical column; 16 logical-pixel horizontal padding; 8-point spacing scale; 12–16 card radius; minimum 48×48 touch targets; body text starting at 16, section headings 20–24. Respect safe areas and keyboards. Primary actions use verbs. Charts require numeric summaries. Replace desktop tables with price/forecast cards. Keep an information source/date visible close to the number it describes.

| Screen | Required hierarchy and controls |
| --- | --- |
| Language/onboarding | Language names in their own scripts, concise explanation, skip optional setup |
| Location selection | GPS, six-digit PIN, manual state/district; candidates and confirmation |
| Home | Selected farm, refresh age, current advisory, weather, Soil/Recommend/Scan/Market shortcuts, latest soil and highlights |
| Weather | Source/time, main conditions, seven-day cards, advisory list; secondary metrics only when provided |
| Farm | Farm summary, current soil provenance, recommendations CTA, searchable crop library |
| Soil summary/editor | Regional context vs measured record, values/units/date/source, edit/save, optional notes |
| Recommendations | Top three then full ranking, season filter, missing-input explanation, reasons/risks |
| Crop detail/guide | Suitability factors, sowing/harvest assumptions, cultivation sections; offline availability |
| Scan capture/preview | Framing guidance, camera/gallery, optional crop, retake, Analyze |
| Scan result/history | Possible issue/no visible issue/inconclusive; uncertainty, urgency, observations, next steps, saved records |
| Market | Commodity/mandi/date filters, reported min/modal/max and reporting date, provenance, personal notes |
| Auth/profile | Guest status, optional email account/reset, name/phone/location/area/crops, sync status |
| Settings/privacy/help | Locale, theme, units, notifications, permission guidance, cache/records/account controls |

Each data screen must have intentional loading, empty, populated, partial, stale, offline-with-cache, offline-without-cache and error states. Retry should retain useful prior content. Home cards load independently so one provider failure does not hide other data.

## 5. Functional requirements and acceptance

### FR-01 Location and onboarding — P0

Select English/Hindi/Telugu before other onboarding text. Ask foreground GPS permission only when Use my location is tapped. Offer PIN lookup and manual district/state; distinguish invalid input, no match, offline and service failure. Confirm candidates because a PIN can cover several settlements. Store method and precision. Farm location differs from the phone's current location; do not silently substitute Hyderabad or another default.

Acceptance: denied GPS permits manual setup and Home access; relaunch restores the confirmed location; changing farm cancels old requests and invalidates dependent weather/soil/recommendation/market caches; late responses cannot overwrite the new farm context.

### FR-02 Weather — P0

Display temperature, condition, humidity, precipitation and wind with units and observation timestamp. Seven-day entries show min/max temperature, rainfall and wind when available. Preserve null for absent UV, visibility or other fields rather than showing zero. Derive advisories using versioned, reviewed rules and available data; label them App-generated weather advisory. Include severity, category and validity dates; sort by urgency and remove expired alerts. Fixed source seasonal curves may only be labeled educational examples.

Acceptance: partial provider data remains usable; refresh keeps prior data until replacement; cache shows age/source/offline label; expired advisories do not notify; rules create stable deduplicated IDs. Forecast dates use the farm timezone.

### FR-03 Soil records and context — P0

Support soil type, pH, N/P/K, texture, organic matter, drainage, salinity, test date and notes when known. Classify provenance as farmer entry, lab report, regional estimate or validated kit reading. Require explicit units for nutrient values; preserve original laboratory units and do not invent mg/L↔mg/kg conversions. Accept partial records. Validate finite pH in 0–14, nonnegative nutrients, organic matter in 0–100%. Confirm unusually large values in their stated units. Blank means unknown, never zero.

Regional mapping can offer likely soil type/texture if reviewed; it cannot generate field pH/N/P/K. Save records locally and queue optional sync. All screens consume the same selected soil record. Changing soil marks existing recommendations outdated.

Acceptance: a manual soil edit reaches Home, Farm and new recommendations; records persist across restart; units/provenance survive sync; changing an estimate does not reclassify it as a measured laboratory result.

### FR-04 Chemical kit workflow — Experimental

Preserve chloride, nitrate and phosphorus kit workflows in the design, behind a disabled release flag. Require supported kit identity, approved reagent protocol, calibration reference, lighting guidance and sample metadata. Reject blur/glare/missing calibration. Arbitrary RGB tables from the source are not validated measurement. P0 allows manual entry of actual kit readings.

Enable only after agronomic approval and evaluation on labeled samples across supported phones, concentration ranges and lighting conditions. Define repeatability/error thresholds before evaluation. Store kit/version/unit/calibration metadata. Without this evidence, automatic concentration inference remains unavailable to ordinary users.

### FR-05 Crop ranking and library — P0

Use available region/location, season, soil with provenance, current weather and forecast, with optional farm area/irrigation. Primary ranking is deterministic and versioned; document factor weights and review them before release. AI may explain scores through the server, not silently replace the rule ranking. Label the number Suitability, not predicted profit or a calibrated probability. Explain missing inputs, risks, dates and assumptions. A seven-day forecast is not a full-season climate model.

Carry over all 24 catalog crops: rice, wheat, maize, barley, jowar, bajra, ragi, moong, urad, masoor, chana, groundnut, mustard, soybean, sunflower, sesame, sugarcane, tea, coffee, coconut, banana, tomato, onion and potato. Review source guides for land preparation, sowing/spacing, irrigation, fertilization, pest/disease management, harvest and storage. Other profile options such as cotton/chilli/turmeric are not automatically complete catalog entries.

Acceptance: identical inputs/rule versions give stable results and tie ordering; soil/location/season changes invalidate prior rankings; missing data permits library use and clearly limited ranking; offline ranking uses saved inputs and bundled rules; yields/windows show units, region and assumptions or are omitted when unsupported. Compare up to three crops in a readable sheet.

### FR-06 Plant health scan — P0

Use rear camera or platform photo picker. Request camera permission at use; do not request broad storage access for the system picker. Preview and retake before upload. Accept source images up to 10 MB; normalize rotation, convert supported formats to JPEG/PNG, strip GPS EXIF and compress toward ≤2 MB without destroying diagnostic detail. Optional crop input helps context. Explain remote processing before submission.

Server result statuses: possible_issue, no_visible_issue, inconclusive, rejected. Show visible symptoms, possible crop/issue, uncertainty, severity and practical next steps. Model-supplied confidence is not verified accuracy; avoid percentages unless evaluated calibration supports them. Chemical treatments must come from reviewed crop/region references; exclude generated dosage instructions. Unknown/non-plant/blurred images receive guidance rather than fabricated diagnosis.

Acceptance: permission denial offers gallery/help; progress/cancel/timeout/retry preserve draft; malformed output becomes error/inconclusive; no visible issue does not promise disease absence; local result history works offline; image retention requires explicit choice. Offline capture remains a draft, with submission confirmed when online. Use idempotent request IDs to avoid duplicate inference charges.

### FR-07 Market — P0

Show reported min/modal/max quotations with commodity, variety if provided, mandi, district/state, reporting date, source, currency and unit. Filter by location/mandi/commodity/date and show freshest available reports. Mark records older than 48 hours stale. Fetch time is distinct from observed price date. Missing min/max remain blank; percentage change requires comparable genuine observations.

Personal price notes include value/unit/mandi/date and My price note label; they never overwrite provider quotations. Validate finite positive prices. AI/fixed fallback prices cannot appear as live quotations. P1 forecasts require generation date, horizon, assumptions and separate forecast label; historical charts require genuine historical records.

Acceptance: consistent conversion between ₹/kg, ₹/quintal and ₹/tonne using 100 kg/quintal and 1,000 kg/tonne; changing display unit preserves original value; offline cache exposes source/date; unavailable provider offers useful empty state and personal notes, not simulated prices.

### FR-08 Auth, profile and sync — P0

Guest access covers core local functionality. Optional Supabase email/password sign-up/sign-in includes confirmation, reset and sign-out. Profile: name, optional phone, district/state, farm area with acres/hectares, primary crops and language; optional land type/irrigation are planned additions. Phone profile data is not authentication. Guest data stays on-device; on sign-in offer explicit import and deduplicate by stable IDs.

Acceptance: validate email/positive area; show Pending sync until confirmed server save; account A cannot see account B data; sign-out clears account-sensitive cache/tokens while preserving separate guest records; reset links return to mobile routes; account deletion requires reauthentication and removes owned records/storage. Cloud sync is not a prerequisite for soil/history use.

### FR-09 Settings/localization/accessibility — P0

Persist English/Hindi/Telugu, light/dark/system theme, °C/°F, market units and acres/hectares. Language/theme updates apply immediately and survive restart. Use complete translated UI/errors/consent and reviewed localized guides/advisories; label any content fallback. Separate clearing downloaded cache, deleting local farm records and deleting account/cloud data, with explicit confirmations.

Acceptance: all relevant screens honor unit conversions; canonical values remain unchanged. TalkBack/VoiceOver have meaningful labels/order. Normal text contrast ≥4.5:1; 200% scaling does not hide actions; widths 320–430 logical pixels do not overflow horizontally. No gesture/color-only core controls.

### FR-10 Inbox/reminders/help — P0

Provide foreground derived-advisory inbox. Optional local reminders need explicit OS permission and valid advisory dates; cancel on expiration/farm change. Denial does not disable the inbox. Turning reminders off cancels future reminders. Server push is P1; do not promise continuously refreshed background warnings. Help explains sources, estimates, offline use, scans and data controls; display support contact only once configured.

Acceptance: reminders deduplicate and open the correct advisory; expired reminders are canceled; app-generated advisories are never branded official warnings.

## 6. Data contracts and shared state

Stable UUIDs, UTC timestamps and local presentation. Forecast calendar dates retain farm timezone. Unknown numbers are nullable. External/derived records include source, observedAt, fetchedAt, farm/location key and provenance; cached/stale flags are additional attributes.

| Entity | Required fields/behavior |
| --- | --- |
| FarmContext | id, owner/guest scope, confirmed location, name, optional area/irrigation, version |
| Location | nullable coordinates for manual selection, state/district/PIN, method/precision |
| SoilRecord | id/farmId, nullable metrics and units, source/test date, notes/version |
| Weather/Forecast | location key, timezone, nullable typed metrics, provider/observation dates |
| Advisory | stable farm/category/date/rule ID, severity, validity, derived source |
| CropCatalog | stable crop IDs, localized guides/conditions, reviewed content version |
| Recommendation | input hashes/versions, ranking/reasons, ruleVersion, time/limitations |
| Quotation/PriceNote | separate provider quotation vs owned note, commodity/mandi/date/unit/value |
| ScanRecord | result status, provider/model version, timestamps, result, image retention choice |
| Profile/Settings | owner ID, fields/units/locale/theme; device permissions remain local |
| SyncOperation | UUID/action/entity/baseVersion/owner scope/retries/status |

Existing Supabase type definitions mention profiles/settings/history, but deployment and ownership policies are not established by types. Design verified migrations. Mobile cannot automatically read browser localStorage; browser history migration is outside v1 unless explicit export/import is later designed.

## 7. Flutter architecture and service boundaries

Feature-based application with views/controllers, immutable domain models and repositories owning local/remote access. Repositories expose cached and refreshed data with typed states. This separation is aligned with [Flutter architecture guidance](https://docs.flutter.dev/app-architecture) and [offline-first patterns](https://docs.flutter.dev/app-architecture/design-patterns/offline-first).

Proposed choices to verify/pin during implementation: Riverpod for state/dependency injection, go_router for routing, Dio or equivalent HTTP client, Supabase Flutter, SQLite-backed records, secure token storage, platform camera/photo/geolocation plugins. This is a proposal, not a compatibility claim. Use ARB/generated localization per [Flutter internationalization guidance](https://docs.flutter.dev/ui/internationalization).

Planned directories: lib/app (bootstrap/router/theme), lib/core (network/storage/errors/units/provenance), lib/features (onboarding/home/weather/farm/soil/crops/scan/market/account/settings), assets/catalog, test, integration_test, supabase/migrations and functions, android and ios. Generate application directories in the next stage.

Use separate AgriFlutter development backend first. Reusing the original production database requires explicit schema/security verification. Privileged provider/service-role secrets remain server-side. Purpose-specific endpoints:

| Boundary | Input | Output |
| --- | --- | --- |
| Location | PIN or coordinates | confirmed candidate metadata/precision; typed no-match/failure |
| Weather | coordinates/horizon | validated nullable metrics/timezone/source |
| Market | commodity/region/mandi/date/page | reported dated quotations/pagination |
| Ranking | typed farm/soil/weather/season context | rule ranking/input hashes; optional server explanation |
| Plant analysis | image reference/crop/locale/request UUID | typed status/result/provider version |
| Sync | owned entity/action/base version/operation UUID | server confirmation/version or conflict |

Enforce authentication or short-lived quota-limited guest access, payload limits, schema validation and per-caller rate limits. Initial configurable scan quotas: guest 5/day, account 20/day; adjust after cost measurement. API timeout/error messages are localized; logs omit keys/raw sensitive payloads. Use server budgets and AI/experimental kill switches.

Source provider references (Open-Meteo, postalpincode, Nominatim, data.gov.in, OpenRouter/Anthropic) are candidates, not verified production commitments. Check endpoint support, keys, coverage, attribution and usage terms before integration. No synthetic production fallback.

## 8. Offline, persistence and synchronization

Bundle reviewed guides and ranking rules. Save farm/settings/soil/history locally. Weather/market display last available observations with exact age/provenance; first-use offline provides an empty state. New inference/prices require internet. Scan drafts never auto-submit upon reconnection without confirmation.

Initial fetch cache policy: current weather 30 minutes; forecast 3 hours; market 6 hours. Stale notices: weather observations older than 3 hours, forecast fetched more than 12 hours ago, market reports older than 48 hours. Keep observational age distinct from cache freshness. Keys include location/filters/locale where relevant and schema/rule versions. Manual refresh bypasses freshness without deleting useful cached content.

Use outbox and bounded exponential backoff for idempotent writes. Stop retrying authorization/validation failures. Profile/settings conflicts can resolve per-field latest edit; soil/history use immutable versions, preserve conflicted records and let the user choose active soil. Separate owner scopes and outboxes on account changes. Connectivity is a hint; actual request outcomes determine availability.

## 9. Privacy and operational requirements

Explain precise location/image processing before submission. Foreground GPS only; strip image location EXIF. Default raw remote images are temporary, deleted within 24 hours; provider capabilities must match the disclosed policy before launch. Saving images is optional and uses private storage/signed URLs. Local unsaved drafts expire after 30 days. Account deletion removes owned cloud data/storage; finalize backup-expiry disclosures before release.

Verify row-level ownership for every table/storage path with two-account and anonymous tests. Secure session storage; no credentials in source, screenshots or logs. Separate dev/staging/production and use synthetic fixtures. Optional analytics excludes coordinates, image content, phone/email and notes. Support opt-out.

## 10. Nonfunctional targets

Proposed baseline: Android API 26+ and iOS 15+, verified against chosen SDK/plugins before scaffolding. Android-first physical test device with 3 GB RAM plus supported iPhone. Portrait primary; landscape remains usable. iOS builds/signing require macOS access.

Measure, do not assume: cached Home usable at cold launch p95 under 3 seconds; cached navigation under 300 ms; ≥95% frames within device refresh budget; initial non-image fetch under 500 KB excluding bundle; uploads target ≤2 MB. Provider fetch timeout 15 seconds, analysis timeout 60 seconds with recoverable draft/cancel. Separate provider latency from rendering. Target ≥99.5% crash-free pilot sessions when consented measurement is available.

Opt-in events: onboarding outcome, location method/outcome, weather load/error, soil saved, recommendation generated/viewed, guide opened, scan status/error/duration, market viewed, sync failure. No personal payloads; completion denominators are relevant attempts, with cancellations/failures separated.

## 11. Testing and release acceptance

Domain checks: conversions, nullable fields, crop rules/ties, advisory validity/deduplication, location cache invalidation, outbox identity and AI schema rejection. Widget checks: each loading/error/offline/partial state; routing, translations and enlarged text. End-to-end journeys: denied-GPS guest setup; soil→updated ranking; camera/gallery→result→history; offline restart; guest import; account switching; reset deep link.

Manual QA at 320/360/390/430 widths, all locales/themes, 200% text, TalkBack/VoiceOver, keyboards/safe areas, interruption/background/resume and permission denial. Physical camera tests cover rotation, photo format conversion, large images and low light. Provider contracts cover empty/malformed/quota/timeout/unauthorized responses. Backend tests prove owner-only rows and image access. Agronomic and translation reviewers approve core content.

Release gate: all P0 acceptance passed on Android and iOS; no unresolved critical/high access/privacy/data-loss bugs; no fake live data; reviewed content/translations; verified provider configuration/terms; retention/deletion/support policies; device performance evidence; signing/store metadata and permission declarations. Publishing is a later task.

## 12. Milestones and implementation decisions

M0: analysis + PRD + backlog; no app code.
M1: Android/iOS scaffold, themes, localization, navigation, local persistence, guest onboarding. Gate: small-phone/offline/localized screens.
M2: farm/location/weather adapters, soil records/shared context, catalog/ranking. Gate: all changes propagate and cache identity holds.
M3: secure plant inference, capture/drafts/history, market quotation adapters/notes. Gate: errors never fabricate results; quotas/provenance verified.
M4: account/reset, owner migrations, sync/conflicts, settings/reminders/deletion. Gate: offline and account isolation pass.
M5: review, accessibility, performance, physical devices and signed release builds.

Dependencies: Flutter/Android tools, macOS/iOS access, backend/provider environment and keys, reviewer availability and physical devices. Estimate dates after these are established.

Defaults chosen: Android-first validation but both platforms in v1; optional email/password; one selected farm; all 24 source crops; manual/lab soil; deterministic ranking; saved offline content; no generated live prices. Open production decisions: app identifiers/store owner, actual providers/budgets/coverage, retention/backups/support contact, reviewer names, SDK baseline validation and funding for calibrated chemical-kit work. These do not prevent implementing the local mobile foundation.

## 13. Risks and definition of done

| Risk | Required mitigation |
| --- | --- |
| Estimates look measured | Field provenance, unknown nutrient values |
| Hallucinated diagnosis/treatment | Typed inconclusive result and reviewed content |
| Missing mandi data | Dated cache/empty state, separate notes |
| Misleading crop scores/yields | Reviewed rules, assumptions, no profit promise |
| Connectivity/conflicts | Local persistence, outbox, immutable record versions |
| Language omissions | Reviewed resources and full journey QA |
| AI endpoint abuse | Quotas, limits, cost budgets, kill switch |
| Unvalidated camera chemistry | Hidden experimental feature and validation gate |
| Unverified original database | Fresh migrations/ownership verification |

This PRD is complete when a reviewer can trace each source capability to a mobile destination, priority, acceptance criteria, data/integration contract and milestone; distinguish current source behavior from planned additions; and implement without treating prototype values as authoritative. Version the PRD and backlog when these decisions change.

## Design direction update — 8 October 2026
The user selected modern, clean glassmorphism. Use translucent surfaces, subtle gradients, restrained blur and readable text as documented in DESIGN.md. The first mobile foundation is implemented; see IMPLEMENTATION_STATUS.md for remaining requirements. This update does not waive original acceptance gates.
