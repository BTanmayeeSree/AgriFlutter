# AgriSakshi source analysis

Inspected 8 October 2026. Source: ../Agri_Sakshi. Method: static source inspection; no build, live API requests, database verification or model accuracy evaluation.

## Structure

React/TypeScript/Vite browser app using Tailwind/shadcn, React Query, React Router and Supabase. src/pages/Index.tsx switches eight tabs; src/components/TabNavigation.tsx lays all eight out in one row. Shared context lives in React state and some service caches; settings and price overrides use browser localStorage.

## Evidence and translation to Flutter

| Files | Observed behavior | Planning consequence |
| --- | --- | --- |
| src/pages/Index.tsx | Home, Climate, Soil, Crop, Market, Disease Detection, Profile, Settings; forecast state is never populated | Central farm repositories and five mobile destinations |
| src/components/tabs/HomeTab.tsx | Sequential GPS → weather → soil; shared location/weather/soil callbacks | Independent loading and manual location fallback |
| src/services/locationService.ts | Geolocation, postalpincode PIN lookup, Nominatim reverse lookup | Confirm location and verify provider policies |
| src/services/weatherService.ts | Open-Meteo current/daily requests; rules derive advisories; seasonal trends are fixed | Nullable fields, dated cache, derived labels; no fake climatology |
| src/services/soilService.ts | Regional soil mapping with generated/stable pseudo-random nutrients | Regional context cannot stand in for field measurement |
| src/components/tabs/SoilTab.tsx | Manual soil state and RGB test-tube matching for chloride/nitrate/phosphorus | Persistent manual records; camera chemistry experimental |
| src/services/recommendationService.ts | AI score attempt and deterministic fallback, input cache | Versioned primary rules and optional server explanations |
| src/data/crops.ts and CropGuide.tsx | 24 catalog crops with cultivation guides | Review and migrate structured localized content |
| src/services/marketService.ts | data.gov.in/Agmarknet attempt, AI enrichment, deterministic fallback and local overrides | Separate reported/cached/personal/forecast values |
| src/services/diseaseService.ts and DiseaseDetectionTab.tsx | Image upload/analysis, model confidence and treatment arrays | Native camera/gallery, typed uncertainty, reviewed treatments |
| src/services/apiClient.ts | Sends Claude-format request to Supabase claude-proxy | Central purpose-specific secured server contract |
| supabase/functions/claude-proxy/index.ts | Converts to OpenRouter request with server secret, auto model selection | Name/comments do not establish actual inference provider/accuracy |
| ProfileTab.tsx | Supabase email/password and user_profiles CRUD | Optional guest/account mode and verified owner policies |
| SettingsTab.tsx and languageService.ts | Three languages, units/theme/notifications preferences, local/cloud save | Complete localization; settings must change app behavior |
| src/integrations/supabase/types.ts | Profiles/settings/history type declarations | Types do not prove deployed tables/policies or connected history workflows |
| src/train_disease_cnn.py | Standalone TensorFlow dataset/training script | Not an integrated mobile inference artifact |

## Concrete integration gaps

1. Index.tsx declares forecast and setter, but never supplies forecast updates to it; recommendations receive its empty forecast array.
2. Index.tsx supplies onChemicalResults to SoilTab, but SoilTabProps and the component do not consume that prop. Chemical results therefore lack the intended parent handoff.
3. Manual and auto soil changes update SoilTab-local state rather than Index's soil context. Recommendations can keep using an older Home-provided record.
4. recommendationService.ts defines a direct Anthropic HTTP call with only Content-Type, rather than using the authenticated common proxy. This code path does not establish a working authenticated provider integration.
5. Names/comments say Claude while the edge function calls OpenRouter. Treat actual provider/model as backend metadata, not a hardcoded user claim.
6. Regional soil nutrient values are generated; fixed seasonal curves and AI/deterministic prices must not be relabeled as real observations.
7. Source camera chemistry uses center-region RGB matching against tables. No calibration/evaluation evidence was found in inspected project files.
8. Browser-specific image paths/navigation/storage cannot simply transfer to native Flutter.

## Catalog inventory

Rice, wheat, maize, barley, jowar, bajra, ragi, moong, urad, masoor, chana, groundnut, mustard, soybean, sunflower, sesame, sugarcane, tea, coffee, coconut, banana, tomato, onion and potato. Extra profile choices are not necessarily complete guide entries.

## Verification limits

No production readiness claim is made. Verify provider endpoint capabilities, credentials, quota/terms, database migrations/RLS, content validity and model outputs during implementation. No secrets or environment files were copied. Original source files were not edited.
