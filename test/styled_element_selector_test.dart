import 'package:flutter_html/src/style.dart';
import 'package:flutter_html/src/tree/styled_element.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

void main() {
  late dom.Document document;
  late dom.Element target;
  late StyledElement styled;

  setUp(() {
    document = html.parse('''
      <section class="lesson">
        <p class="before">Before</p>
        <p id="answer" class="ql-align-center selected" data-id="42">Answer</p>
        <p class="after">After</p>
      </section>
    ''');
    target = document.querySelector('#answer')!;
    styled = StyledElement(name: 'p', node: target, style: Style());
  });

  for (final selector in [
    'p',
    '.ql-align-center',
    '#answer',
    '[data-id="42"]',
    'p.selected[data-id="42"]',
    'section p',
    'section > p',
    '.before + p',
    '.before ~ p',
    'p:not(.before)',
    'span, #answer',
  ]) {
    test('matches $selector without changing the DOM', () {
      final before = document.outerHtml;
      final parent = target.parentNode;

      expect(styled.matchesSelector(selector), isTrue);
      expect(document.outerHtml, before);
      expect(target.parentNode, same(parent));
    });
  }

  for (final selector in [
    'div',
    '.missing',
    '#missing',
    '[data-id="other"]',
    '.after + p',
    'p:nth-child(even)',
    '[',
    'p[',
    'p:unsupported-pseudo',
  ]) {
    test('does not match $selector', () {
      expect(styled.matchesSelector(selector), isFalse);
    });
  }

  test('matches a detached element without attaching it', () {
    final detached = dom.Element.tag('span')..classes.add('ql-formula');
    final element = StyledElement(
      name: 'span',
      node: detached,
      style: Style(),
    );

    expect(element.matchesSelector('span.ql-formula'), isTrue);
    expect(element.matchesSelector('div > span'), isFalse);
    expect(detached.parentNode, isNull);
  });

  test('retains the name fallback for non-element nodes', () {
    final element = StyledElement(
      name: 'custom',
      node: dom.Text('text'),
      style: Style(),
    );

    expect(element.matchesSelector('custom'), isTrue);
    expect(element.matchesSelector('.custom'), isFalse);
  });
}
