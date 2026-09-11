import 'package:flutter/rendering.dart';

/// One Flutter view binding used by automatic page semantics.
final class WebMcpViewBinding {
  /// Creates a binding with explicit owner identities.
  const WebMcpViewBinding({
    required this.pipelineOwner,
    required this.semanticsOwner,
  });

  /// The PipelineOwner that owns the view.
  final PipelineOwner? pipelineOwner;

  /// The SemanticsOwner reached only through [pipelineOwner].
  final SemanticsOwner? semanticsOwner;
}

/// Injectable source of Flutter views for fail-closed view-count tests.
abstract interface class WebMcpViewProvider {
  /// Returns the complete current Flutter view set.
  List<WebMcpViewBinding> getViews();
}

/// Production view provider backed by RendererBinding.renderViews.
final class WebMcpBindingViewProvider implements WebMcpViewProvider {
  /// Creates the production provider.
  const WebMcpBindingViewProvider();

  @override
  List<WebMcpViewBinding> getViews() {
    return RendererBinding.instance.renderViews
        .map((RenderView view) {
          final PipelineOwner? pipelineOwner = view.owner;
          return WebMcpViewBinding(
            pipelineOwner: pipelineOwner,
            semanticsOwner: pipelineOwner?.semanticsOwner,
          );
        })
        .toList(growable: false);
  }
}
