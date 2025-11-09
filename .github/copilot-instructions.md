## Quick orientation

- Project type: Flutter (Dart) app. Entry point: `lib/main.dart` (simple `MaterialApp`/`MainApp` scaffold).
- SDK: Dart >= 3.9.2 (see `pubspec.yaml`). No additional packages currently declared besides `flutter` and `flutter_lints`.
- Design/prototypes: static HTML mockups live in `mockups/` (Tailwind-based visual references). These are design artifacts, not part of the Flutter build.

## High-level architecture (what an agent should know)

- Single-app mobile/web/desktop scaffold located under `lib/`. `lib/main.dart` is the app entry.
- UI components are standard Flutter widgets (Material). Look for screens/widgets under `lib/` when expanding features.
- No backend service code is present in the repository. If work requires network or persistence, confirm where the API/service should live and whether to add packages.

## Developer workflows / useful commands

- Install dependencies: `flutter pub get` (run in the repo root where `pubspec.yaml` is located).
- Run locally: `flutter run` (add `-d chrome` for web, or `-d windows` on Windows desktop). Use PowerShell on Windows.
- Static analysis: `dart analyze` or `flutter analyze` (the project uses `flutter_lints`).
- Tests: `flutter test` (no tests are present currently; create tests under `test/` following Flutter conventions).

## Project-specific conventions & patterns

- Minimal current codebase: `lib/main.dart` contains the app entry and a single stateless `MainApp`. Follow existing style: small, focused widgets.
- File naming: follow Dart/Flutter conventions (snake_case filenames, UpperCamelCase classes). `pubspec.yaml` uses default `flutter` layout.
- Mockups: The `mockups/` folder contains static HTML prototypes (Tailwind CSS). Use these as visual references when building Flutter screens but do not copy Tailwind markup directly—recreate UI using Flutter widgets.

## Integration points & external dependencies

- No external API endpoints or package integrations are present. If adding dependencies, update `pubspec.yaml` and run `flutter pub get`.
- Keep dependency changes minimal and request approval for major additions (state management libraries, heavy UI kits).

## Examples to cite when making edits

- Entry point: `lib/main.dart` — small `MainApp` and `MaterialApp` scaffold; use as a template for new routes/screens.
- SDK and lints: `pubspec.yaml` — shows Dart SDK constraint and `flutter_lints`.
- Visual spec: `mockups/homeScreen.html` and `mockups/loginScreen.html` — use for spacing, color, and flow guidance.

## Rules for an AI coding agent (concrete, actionable)

1. Prefer small, incremental changes. For UI work, create one new screen/widget at a time and link it from `main.dart` or a simple router.
2. Do not add new packages without explicitly noting them in the PR description and updating `pubspec.yaml`.
3. When altering UI, include a reference to the mockup file you used (e.g., "implemented login UI based on `mockups/loginScreen.html`").
4. Keep logic and UI separated: stateful or business logic should be placed in separate files under `lib/` (e.g., `lib/services/`, `lib/models/`) rather than embedding long methods in widgets.
5. If a task requires backend/API work, stop and ask where the API should be hosted and whether to add networking packages (e.g., `http`, `dio`).

## What I looked for (notes for reviewers)

- No existing `.github/copilot-instructions.md` or AGENT.md was found in the repository root; this file is being created from repository inspection.
- The repo currently contains scaffolded Flutter files and static mockups; no tests or CI were detected.

---
If any section is unclear or you'd like more granular guidance (routing patterns, recommended state management, or a starter screen scaffold), tell me which part to expand and I will update this file.
