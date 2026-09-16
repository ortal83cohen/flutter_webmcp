import 'package:flutter/foundation.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

/// Mutable state used by the example's imperative tools and by the
/// hand-written tool source built on top of it.
///
/// Notifies its listeners on every mutation, so widgets and observers can
/// react to changes without polling.
final class ExampleCounter extends ChangeNotifier {
  int _value = 0;

  /// The current counter value. There is no public setter; the value only
  /// changes through this class's three mutating methods.
  int get value => _value;

  /// Adds one to the counter and returns the new value.
  int increment() {
    _value += 1;
    notifyListeners();
    return _value;
  }

  /// Adds [amount] to the counter and returns the new value.
  ///
  /// Contract: [amount] must be strictly positive. A non-positive [amount]
  /// throws an [ArgumentError] rather than being silently ignored or
  /// clamped. Callers that need to expose this method across the registry
  /// boundary — where handlers must never throw for argument problems and
  /// instead return a failure envelope — are expected to validate `amount`
  /// themselves before calling this method, and to catch [ArgumentError] as
  /// a defensive fallback.
  int incrementBy(int amount) {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be positive');
    }
    _value += amount;
    notifyListeners();
    return _value;
  }

  /// Resets the counter to zero and returns the new value.
  int reset() {
    _value = 0;
    notifyListeners();
    return _value;
  }
}

/// Registers the two imperative tools demonstrated by the example.
void registerExampleTools(ExampleCounter counter) {
  WebMcp.instance
    ..registerTool(
      WebMcpTool(
        name: 'example.counter.read',
        description: 'Reads the example counter.',
        handler: (Map<String, Object?> arguments) => counter.value,
      ),
    )
    ..registerTool(
      WebMcpTool(
        name: 'example.counter.increment',
        description: 'Increments the example counter.',
        handler: (Map<String, Object?> arguments) => counter.increment(),
      ),
    );
}
