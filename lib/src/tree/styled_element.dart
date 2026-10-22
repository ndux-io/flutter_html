import 'dart:collection';

import 'package:csslib/parser.dart' as css;
import 'package:flutter_html/src/style.dart';
import 'package:html/dom.dart' as dom;
// html has no public element-matching API. Keep its evaluator to preserve
// selector semantics; regression tests cover this remaining internal dependency.
// ignore: implementation_imports
import 'package:html/src/query_selector.dart' as qs;
import 'package:list_counter/list_counter.dart';

/// A [StyledElement] applies a style to all of its children.
class StyledElement {
  final String name;
  final String elementId;
  final List<String> elementClasses;
  List<StyledElement> children;
  Style style;
  final dom.Node node;
  final ListQueue<Counter> counters = ListQueue<Counter>();

  StyledElement({
    this.name = "[[No name]]",
    this.elementId = "[[No ID]]",
    this.elementClasses = const [],
    this.children = const [],
    required this.style,
    required this.node,
  });

  bool matches(dom.Element element, String selector) {
    try {
      final errors = <css.Message>[];
      final group = css.parseSelectorGroup(selector, errors: errors);
      if (group == null || errors.isNotEmpty) {
        return false;
      }
      return qs.SelectorEvaluator().matches(element, group);
    } catch (_) {
      return false;
    }
  }

  bool matchesSelector(String selector) {
    return (element != null && matches(element!, selector)) || name == selector;
  }

  Map<String, String> get attributes => node.attributes.map((key, value) {
        return MapEntry(key.toString(), value);
      });

  dom.Element? get element {
    if (node is dom.Element) {
      return node as dom.Element;
    }
    return null;
  }

  @override
  String toString() {
    String selfData =
        "[$name] ${children.length} ${elementClasses.isNotEmpty == true ? 'C:${elementClasses.toString()}' : ''}${elementId.isNotEmpty == true ? 'ID: $elementId' : ''}";
    for (var child in children) {
      selfData += ("\n${child.toString()}")
          .replaceAll(RegExp("^", multiLine: true), "-");
    }
    return selfData;
  }
}

FontSize numberToFontSize(String num) {
  switch (num) {
    case "1":
      return FontSize.xxSmall;
    case "2":
      return FontSize.xSmall;
    case "3":
      return FontSize.small;
    case "4":
      return FontSize.medium;
    case "5":
      return FontSize.large;
    case "6":
      return FontSize.xLarge;
    case "7":
      return FontSize.xxLarge;
  }
  if (num.startsWith("+")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 + relativeNum).toString());
  }
  if (num.startsWith("-")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 - relativeNum).toString());
  }
  return FontSize.medium;
}

extension DeepCopy on ListQueue<Counter> {
  ListQueue<Counter> deepCopy() {
    return ListQueue<Counter>.from(map((counter) {
      return Counter(counter.name, counter.value);
    }));
  }
}
