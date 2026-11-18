/// Bagisto API endpoint
/// Defaults to Android emulator endpoint (http://10.0.2.2/api/graphql).
/// Can be overridden at compile-time with:
///   --dart-define=BAGISTO_ENDPOINT=...
/// or via:
///   --dart-define-from-file=secrets.local.json
const String bagistoEndpoint = String.fromEnvironment(
  'BAGISTO_ENDPOINT',
  defaultValue: 'http://10.0.2.2/api/graphql',
);

/// Storefront key for Bagisto API
/// Configured at compile-time via:
///   --dart-define=STOREFRONT_KEY=...
/// or via:
///   --dart-define-from-file=secrets.local.json
const String storefrontKey = String.fromEnvironment(
  'STOREFRONT_KEY',
  defaultValue: '',
);

/// Default channel code used by request headers.
const String channelCode = 'default';

/// Default Bagisto channel ID used during app bootstrap.
const int channelId = 1;

/// Company name
const String companyName = 'Sana Al Ward';
