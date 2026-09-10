// Release-safe utilities for inspecting the live Flutter semantics tree.
//
// The fixture deliberately does not use RenderObject.debugSemantics because
// that API always returns null in release builds. Scope lookup starts from the
// SemanticsOwner associated with a concrete RenderView and resolves a marker
// through the public SemanticsNode.identifier property.
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// Data types
// ---------------------------------------------------------------------------

/// A snapshot of one SemanticsNode captured during a traversal walk.
class NodeRecord {
  const NodeRecord({
    required this.id,
    required this.label,
    required this.hint,
    required this.depth,
    required this.parentId,
    required this.isHidden,
    required this.isObscured,
    required this.isMergedIntoParent,
    required this.actionsValue,
  });

  final int id;
  final String label;
  final String hint;
  final int depth;
  final int? parentId;
  final bool isHidden;
  final bool isObscured;
  final bool isMergedIntoParent;

  final int actionsValue;

  @override
  String toString() =>
      'Node(id=$id depth=$depth label="$label" '
      'hidden=$isHidden obscured=$isObscured merged=$isMergedIntoParent)';
}

/// Budget configuration for traversal walks.
class TraversalBudget {
  const TraversalBudget({
    this.maxReturned = 200,
    this.maxVisited = 1000,
    this.maxDepth = 32,
    this.maxBytes = 65536,
  });

  // Default ceilings from the design (AC-009, AC-027).
  static const TraversalBudget defaults = TraversalBudget();

  final int maxReturned;
  final int maxVisited;
  final int maxDepth;
  final int maxBytes;
}

/// Result of a traversal walk.
class WalkResult {
  WalkResult({
    required this.nodes,
    required this.visitedCount,
    required this.truncated,
    required this.truncationReason,
    required this.estimatedBytes,
  });

  final List<NodeRecord> nodes;
  final int visitedCount;
  final bool truncated;
  final String? truncationReason;
  final int estimatedBytes;
}

// ---------------------------------------------------------------------------
// Core walk
// ---------------------------------------------------------------------------

/// Walk the semantics tree starting from [root] subject to [budget].
///
/// Returns a [WalkResult] containing collected [NodeRecord]s plus
/// coverage metadata. Always respects the budget; never returns more than
/// [budget.maxReturned] records or visits more than [budget.maxVisited] nodes.
WalkResult walkSemantics(
  SemanticsNode root, {
  TraversalBudget budget = TraversalBudget.defaults,
}) {
  final nodes = <NodeRecord>[];
  var visitedCount = 0;
  var estimatedBytes = 0;
  var truncated = false;
  String? truncationReason;

  void visit(SemanticsNode node, int depth, int? parentId) {
    if (truncated) return;

    visitedCount++;

    // Visit-count budget.
    if (visitedCount > budget.maxVisited) {
      truncated = true;
      truncationReason = 'maxVisited(${budget.maxVisited})';
      return;
    }

    // Depth budget.
    if (depth > budget.maxDepth) {
      truncated = true;
      truncationReason = 'maxDepth(${budget.maxDepth})';
      return;
    }

    // Build a record only from release-safe SemanticsNode and SemanticsData.
    final flags = node.flagsCollection;
    final data = node.getSemanticsData();
    final record = NodeRecord(
      id: node.id,
      label: node.attributedLabel.string,
      hint: node.attributedHint.string,
      depth: depth,
      parentId: parentId,
      isHidden: flags.isHidden,
      isObscured: flags.isObscured,
      isMergedIntoParent: node.isMergedIntoParent,
      actionsValue: data.actions,
    );

    // UTF-8 bytes are counted exactly for exposed strings. The fixed metadata
    // allowance is deterministic and intentionally conservative.
    final recordBytes =
        utf8.encode(record.label).length + utf8.encode(record.hint).length + 64;
    if (estimatedBytes + recordBytes > budget.maxBytes) {
      truncated = true;
      truncationReason = 'maxBytes(${budget.maxBytes})';
      return;
    }

    // Return-count budget.
    if (nodes.length >= budget.maxReturned) {
      truncated = true;
      truncationReason = 'maxReturned(${budget.maxReturned})';
      return;
    }

    nodes.add(record);
    estimatedBytes += recordBytes;

    node.visitChildren((child) {
      visit(child, depth + 1, node.id);
      return !truncated; // Stop visiting when truncated.
    });
  }

  visit(root, 0, null);

  return WalkResult(
    nodes: nodes,
    visitedCount: visitedCount,
    truncated: truncated,
    truncationReason: truncationReason,
    estimatedBytes: estimatedBytes,
  );
}

// ---------------------------------------------------------------------------
// Release-safe accessors
// ---------------------------------------------------------------------------

/// Return debug/profile semantics for legacy diagnostic widget tests.
///
/// This intentionally returns null in release mode and is never used by the
/// executable gate runner.
SemanticsNode? semanticsNodeForContext(BuildContext context) {
  final renderObject = context.findRenderObject();
  return renderObject?.debugSemantics;
}

/// Get the [SemanticsOwner] for [renderView], or the primary view by default.
///
/// Returns null when semantics are not enabled.
SemanticsOwner? semanticsOwnerForView([RenderView? renderView]) {
  final views = RendererBinding.instance.renderViews;
  if (views.isEmpty) return null;
  return (renderView ?? views.first).owner?.semanticsOwner;
}

/// Get the root [SemanticsOwner] for the primary view.
SemanticsOwner? primarySemanticsOwner() => semanticsOwnerForView();

/// Get the root SemanticsNode for the primary view.
///
/// Returns null when semantics are disabled or no view is mounted.
SemanticsNode? primaryRootNode() => primarySemanticsOwner()?.rootSemanticsNode;

/// Find all nodes with the exact public semantics [identifier].
List<SemanticsNode> findNodesByIdentifier(
  SemanticsNode root,
  String identifier,
) {
  final matches = <SemanticsNode>[];

  void visit(SemanticsNode node) {
    if (node.identifier == identifier) {
      matches.add(node);
    }
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(root);
  return matches;
}

/// Resolve exactly one release-safe scope marker in [owner].
SemanticsNode? resolveUniqueScope(SemanticsOwner owner, String identifier) {
  final root = owner.rootSemanticsNode;
  if (root == null) return null;
  final matches = findNodesByIdentifier(root, identifier);
  return matches.length == 1 ? matches.single : null;
}

// ---------------------------------------------------------------------------
// Query helpers
// ---------------------------------------------------------------------------

/// Collect all SemanticsNode IDs reachable from [root].
Set<int> reachableIds(SemanticsNode root) {
  final ids = <int>{};
  void collect(SemanticsNode n) {
    ids.add(n.id);
    n.visitChildren((child) {
      collect(child);
      return true;
    });
  }

  collect(root);
  return ids;
}

/// Return labels of all nodes reachable from [root].
List<String> reachableLabels(SemanticsNode root) {
  final labels = <String>[];
  void collect(SemanticsNode n) {
    final label = n.attributedLabel.string;
    if (label.isNotEmpty) labels.add(label);
    n.visitChildren((child) {
      collect(child);
      return true;
    });
  }

  collect(root);
  return labels;
}

/// Return true when [label] exists anywhere in the subtree rooted at [root].
bool subtreeContainsLabel(SemanticsNode root, String label) =>
    reachableLabels(root).contains(label);

/// Return labels owned by [root], stopping before nested marked scopes.
///
/// This implements the proposed nearest-wrapper ownership rule without
/// removing the nested scope from Flutter's accessibility tree.
List<String> ownedLabels(SemanticsNode root, {required String markerPrefix}) {
  final labels = <String>[];

  void collect(SemanticsNode node, {required bool isRoot}) {
    if (!isRoot &&
        node.identifier.isNotEmpty &&
        node.identifier.startsWith(markerPrefix)) {
      return;
    }
    final label = node.attributedLabel.string;
    if (label.isNotEmpty) labels.add(label);
    node.visitChildren((child) {
      collect(child, isRoot: false);
      return true;
    });
  }

  collect(root, isRoot: true);
  return labels;
}
