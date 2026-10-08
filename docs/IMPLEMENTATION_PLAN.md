# AgriFlutter implementation backlog

Execute against PRD v1.0. Application development begins after this planning stage. IDs below map to the PRD functional requirements. No delivery dates are promised before tooling/provider access is confirmed.

## Milestone 1 — Mobile foundation

| ID | Deliverable | Dependency | Validation |
| --- | --- | --- | --- |
| AF-001 | Verify Flutter/Dart/Android toolchain and iOS build access; scaffold Android/iOS only with Dart name agri_flutter and display name AgriFlutter | None | Android build; iOS compilation in macOS environment |
| AF-002 | Semantic theme, mobile components, safe areas and five-destination router | AF-001 | 320–430 widths, back behavior, draft/scroll preservation |
| AF-003 | English/Hindi/Telugu ARB resources and language selection | AF-001 | Complete core strings, 200% text |
| AF-004 | Typed domain records, SQLite persistence, owner scopes, units and provenance | AF-001 | Restart persistence, null handling, conversion tests |
| AF-005 | Guest onboarding and manual/PIN/GPS location selection (FR-01) | AF-002–004 | Permission denial/manual fallback and confirmed location |

## Milestone 2 — Farm intelligence

| ID | Deliverable | Dependency | Validation |
| --- | --- | --- | --- |
| AF-006 | Confirm location/weather providers, adapters and contracts (FR-02) | AF-005 | Empty/malformed/timeout fixtures; provider terms/config |
| AF-007 | Home/current/seven-day weather and derived advisory inbox | AF-006 | Independent card failure, expiry/deduplication, dated cache |
| AF-008 | Manual/lab soil editor, history and shared farm context (FR-03) | AF-004–005 | Edits reach Home and ranking; units/source preserved |
| AF-009 | Extract/review all 24 crop entries and localized cultivation guides | AF-003 | Complete catalog and content-review inventory |
| AF-010 | Versioned deterministic scoring/explanations and ranking UI (FR-05) | AF-006,008,009 | Stable ordering, missing inputs, invalidation and offline use |

## Milestone 3 — Scan and market

| ID | Deliverable | Dependency | Validation |
| --- | --- | --- | --- |
| AF-011 | Separate backend environment, schemas and secure purpose-specific endpoints | AF-004 | Owner policies, guest quotas, secret isolation, schema rejection |
| AF-012 | Camera/gallery preview, rotation/format handling, EXIF stripping and drafts | AF-002,004 | Physical-device capture, denied permissions, large images |
| AF-013 | Plant analysis result/history (FR-06), reviewed next-step content | AF-011–012 | Inconclusive/rejected/timeout paths, idempotency and no fake results |
| AF-014 | Reported mandi quotations, filters and personal price notes (FR-07) | AF-011 | Provenance/date, unavailable provider, unit conversions |

## Milestone 4 — Accounts and reliability

| ID | Deliverable | Dependency | Validation |
| --- | --- | --- | --- |
| AF-015 | Email account/confirmation/reset/deep links and profile (FR-08) | AF-011 | Confirmation/reset and account isolation |
| AF-016 | Outbox, explicit guest import, conflict/version handling | AF-004,011,015 | Offline saves/reconnect, no duplicated records, owner isolation |
| AF-017 | Persistent theme/locale/units and data controls (FR-09) | AF-003–004,015 | All screens honor preferences; deletion scopes clear |
| AF-018 | Optional local reminders, help/privacy/support (FR-10) | AF-007,017 | Expiry/cancel/denial/deep link |
| AF-019 | Image retention, account deletion and operational controls | AF-011,013,015 | Private image access, deletion/retention jobs, budget kill switch |

## Milestone 5 — Release readiness

AF-020: Complete agronomic and translation review, provider terms/coverage and privacy/support decisions.
AF-021: Test all PRD journeys on physical Android and iPhone, with offline/error/permission and accessibility cases.
AF-022: Measure performance, crash reporting with consent, security ownership checks and quota controls.
AF-023: Prepare signing/store metadata and release builds only after P0 gates pass. Publishing is a separate subsequent action.

## Deferred work

AF-024 (Experimental / FR-04): fund supported kit protocols, calibration dataset and multi-device validation before enabling chemical concentration inference.
AF-025 (P1): verified price history and separately labeled forecast evaluation.
AF-026 (P1): server push, multiple farms and voice workflows after separate requirements.

## Decisions before dependent implementation

- App identifiers/store organization and SDK/plugin baseline.
- Supabase development environment; approved AI and market providers/keys/budgets.
- iOS/macOS build availability and test phones.
- Named agronomic and Telugu/Hindi content reviewers.
- Support contact, retention and backup expiry disclosures.

Foundation work can proceed using local adapters and synthetic development fixtures. Fixtures must remain visibly development-only and must never replace unavailable production observations.

## Implementation progress
The initial mobile foundation is present. See IMPLEMENTATION_STATUS.md for precise completed/partial/outstanding scope and verification evidence. Milestones are not considered complete until their acceptance gates pass.
