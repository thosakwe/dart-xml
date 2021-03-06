library xml.nodes.node;

import '../iterators/ancestors.dart';
import '../iterators/descendants.dart';
import '../iterators/following.dart';
import '../iterators/preceding.dart';
import '../utils/node_type.dart';
import '../utils/owned.dart';
import '../utils/writable.dart';
import '../visitors/normalizer.dart';
import '../visitors/transformer.dart';
import '../visitors/visitable.dart';
import 'attribute.dart';
import 'cdata.dart';
import 'text.dart';

/// Immutable abstract XML node.
abstract class XmlNode extends Object
    with XmlVisitable, XmlWritable
    implements XmlOwned {
  /// Return the direct children of this node in document order.
  List<XmlNode> get children => const [];

  /// Return the attribute nodes of this node in document order.
  List<XmlAttribute> get attributes => const [];

  /// Return a lazy [Iterable] of the nodes preceding the opening tag of this
  /// node in document order.
  Iterable<XmlNode> get preceding => XmlPrecedingIterable(this);

  /// Return a lazy [Iterable] of the descendants of this node (children,
  /// grandchildren, ...) in document order.
  Iterable<XmlNode> get descendants => XmlDescendantsIterable(this);

  /// Return a lazy [Iterable] of the nodes following the closing tag of this
  /// node in document order.
  Iterable<XmlNode> get following => XmlFollowingIterable(this);

  /// Return a lazy [Iterable] of the ancestors of this node (parent,
  /// grandparent, ...) in reverse document order.
  Iterable<XmlNode> get ancestors => XmlAncestorsIterable(this);

  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Return the first child of this node, or `null` if there are no children.
  XmlNode get firstChild => children.isEmpty ? null : children.first;

  /// Return the last child of this node, or `null` if there are no children.
  XmlNode get lastChild => children.isEmpty ? null : children.last;

  /// Return the text contents of this node and all its descendants.
  String get text => descendants
      .where((node) => node is XmlText || node is XmlCDATA)
      .map((node) => node.text)
      .join();

  /// Return the next sibling of this node or `null`.
  XmlNode get nextSibling {
    if (parent != null) {
      final siblings = parent.children;
      for (var i = 0; i < siblings.length - 1; i++) {
        if (siblings[i] == this) {
          return siblings[i + 1];
        }
      }
    }
    return null;
  }

  /// Return the previous sibling of this node or `null`.
  XmlNode get previousSibling {
    if (parent != null) {
      final siblings = parent.children;
      for (var i = siblings.length - 1; i > 0; i--) {
        if (siblings[i] == this) {
          return siblings[i - 1];
        }
      }
    }
    return null;
  }

  /// Return a copy of this node and its subtree.
  XmlNode copy() => XmlTransformer.defaultInstance.visit(this);

  /// Puts all child nodes into a "normalized" form, that is no text nodes in
  /// the sub-tree are empty and there are no adjacent text nodes.
  void normalize() => XmlNormalizer.defaultInstance.visit(this);
}
