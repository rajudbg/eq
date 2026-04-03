# Emvo - EQ Assessment App

Monorepo for the Emvo EQ assessment and coaching experience (Flutter packages under `packages/`, app under `apps/emvo_mobile`).

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel), with `flutter doctor` clean for your targets
- [Dart](https://dart.dev/get-dart) (bundled with Flutter)

## Setup

1. Install dependencies and link the workspace:

   ```bash
   dart pub global activate melos
   melos bootstrap
   ```

   From the repo root you can also run Melos via the workspace dev dependency:

   ```bash
   dart run melos bootstrap
   ```

2. (Optional) Generate code where needed (e.g. DI / assessment code):

   ```bash
   dart run melos run build_runner:build
   ```

## Run the mobile app

From the repo root, the default script runs the app in Chrome (avoids multi-device prompts):

```bash
dart run melos run run-mobile
```

To run on a specific device from `apps/emvo_mobile`:

```bash
cd apps/emvo_mobile
flutter run -d macos
# or: flutter devices   then   flutter run -d <deviceId>
```

### Android flavors (dev / staging / prod)

Android product flavors are defined in `apps/emvo_mobile/android/app/build.gradle.kts`. When building or running from the CLI, pass `--flavor` and match Dart env with `--dart-define`:

```bash
cd apps/emvo_mobile
flutter run --flavor dev --dart-define=FLAVOR=dev
flutter run --flavor staging --dart-define=FLAVOR=staging
flutter run --flavor prod --dart-define=FLAVOR=prod
```

Release APK example:

```bash
cd apps/emvo_mobile
flutter build apk --release --flavor prod --dart-define=FLAVOR=prod
```

**VS Code / Cursor:** use the launch configurations in `.vscode/launch.json` (Emvo Dev / Staging / Prod), which set `toolArgs` for `flutter run` and `FLAVOR` for Dart.

Release signing on Android uses `apps/emvo_mobile/android/key.properties` when present (see Android Gradle setup in the app module).

## Tests and analysis

```bash
dart run melos run test:all      # unit + widget tests across packages
dart run melos run test:unit
dart run melos run test:widget
dart run melos run test:integration
dart run melos run analyze
```

## Useful Melos scripts

| Script | Purpose |
|--------|---------|
| `bootstrap` | Link packages and run `pub get` |
| `clean` | Clean artifacts |
| `build_runner:build` | Code generation for selected packages |
| `run-mobile` | Run `emvo_mobile` in Chrome |

Script names and commands are defined in `melos.yaml` at the repo root. For help: `dart run melos help run`.
