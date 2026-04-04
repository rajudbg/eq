enum Flavor {
  dev,
  staging,
  prod,
}

class F {
  static Flavor? appFlavor;

  /// Reads [Flavor] from `--dart-define=FLAVOR=dev|staging|prod`.
  /// Default `dev` matches `default-flavor` in pubspec for local runs; release and
  /// prod CI must pass `--dart-define=FLAVOR=prod` (see repo README).
  static void initFromDartDefine() {
    const raw = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    appFlavor = switch (raw) {
      'dev' => Flavor.dev,
      'staging' => Flavor.staging,
      'prod' => Flavor.prod,
      _ => Flavor.prod,
    };
  }

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Emvo Dev';
      case Flavor.staging:
        return 'Emvo Staging';
      case Flavor.prod:
        return 'Emvo';
      default:
        return 'title';
    }
  }

  static String get apiBaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return 'https://api-dev.emvo.app';
      case Flavor.staging:
        return 'https://api-staging.emvo.app';
      case Flavor.prod:
        return 'https://api.emvo.app';
      default:
        return '';
    }
  }

  static bool get isProd => appFlavor == Flavor.prod;
  static bool get isDev => appFlavor == Flavor.dev;
}
