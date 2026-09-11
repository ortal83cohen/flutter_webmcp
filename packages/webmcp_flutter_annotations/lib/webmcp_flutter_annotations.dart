/// Annotations consumed by `webmcp_flutter_generator`.
library;

/// Exposes one public instance method as an explicit WebMCP domain action.
///
/// The generated adapter always receives a consumer-created live instance.
/// This annotation does not construct services or grant authorization.
final class WebMcpDomainAction {
  /// Creates metadata for one explicitly exposed method.
  const WebMcpDomainAction({
    required this.description,
    this.name,
    this.readOnlyHint = false,
    this.untrustedContentHint = false,
    this.consequentialHint = false,
  });

  /// Human-readable tool description.
  final String description;

  /// Optional global tool-name override.
  final String? name;

  /// Whether the application declares this operation read-only.
  final bool readOnlyHint;

  /// Whether the application declares returned content untrusted.
  final bool untrustedContentHint;

  /// Whether the application declares significant real-world consequences.
  final bool consequentialHint;
}
