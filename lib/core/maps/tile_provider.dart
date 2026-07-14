class OpenStreetMapConfig {
  static const String defaultUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String defaultUserAgent = 'com.bussu.app';

  final String urlTemplate;
  final String userAgentPackageName;

  const OpenStreetMapConfig({
    this.urlTemplate = defaultUrlTemplate,
    this.userAgentPackageName = defaultUserAgent,
  });
}
