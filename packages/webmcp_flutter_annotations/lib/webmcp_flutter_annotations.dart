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
    this.title,
    this.debugging,
    this.exposedTo,
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

  /// Optional display title.
  ///
  /// Null means the generated tool omits the member. A non-null title must not
  /// be empty or whitespace only.
  final String? title;

  /// Optional debugging hint forwarded in the tool annotations.
  ///
  /// Null means the generated annotations omit the member.
  final bool? debugging;

  /// Optional origin strings forwarded to the browser.
  ///
  /// Null means the generated tool omits the member. An empty list is emitted
  /// as an empty list and is distinct from null.
  final List<String>? exposedTo;
}
