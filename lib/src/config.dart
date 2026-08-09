class AnalyticsConfig {
  final String apiKey;
  final String baseUrl;
  final Duration flushInterval;
  final int batchSize;
  final bool debug;

  const AnalyticsConfig({
    required this.apiKey,
    required this.baseUrl,
    this.flushInterval = const Duration(seconds: 10),
    this.batchSize = 20,
    this.debug = false,
  });
}
