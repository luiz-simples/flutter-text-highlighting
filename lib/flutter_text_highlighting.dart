library flutter_text_highlighting;

import 'dart:math';
import 'package:flutter/material.dart';

class FlutterTextHighlighting extends StatelessWidget {
  //FlutterTextHighlighting
  final String text;
  final List<String> highlights;
  final Color color;
  final TextStyle style;
  final bool caseSensitive;
  final bool accentSensitive;

  //RichText
  final TextAlign textAlign;
  final TextDirection textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
  final Locale locale;
  final StrutStyle strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior textHeightBehavior;

  FlutterTextHighlighting({
    //FlutterTextHighlighting
    Key key,
    this.text,
    this.highlights,
    this.color = Colors.yellow,
    this.style = const TextStyle(
      color: Colors.black,
    ),
    this.caseSensitive = true,
    this.accentSensitive = true,

    //RichText
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  })  : assert(text != null),
        assert(highlights != null),
        assert(color != null),
        assert(style != null),
        assert(caseSensitive != null),
        assert(accentSensitive != null),
        assert(textAlign != null),
        assert(softWrap != null),
        assert(overflow != null),
        assert(textScaleFactor != null),
        assert(maxLines == null || maxLines > 0),
        assert(textWidthBasis != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    //Controls
    if (text == '') {
      return _richText(_normalSpan(text));
    }
    if (highlights.isEmpty) {
      return _richText(_normalSpan(text));
    }
    for (int i = 0; i < highlights.length; i++) {
      if (highlights[i] == null) {
        assert(highlights[i] != null);
        return _richText(_normalSpan(text));
      }
      if (highlights[i].isEmpty) {
        assert(highlights[i].isNotEmpty);
        return _richText(_normalSpan(text));
      }
    }

    // All the accents with all the variations
    // First character of each element is the main ascii character
    List<String> accents = [
      'aàáâãăäåą',
      "AÀÁÂÃĂÄÅĄ",
      'cç',
      'CÇ',
      'eèéêëèěęėĕē',
      'EÈÉÊËÈĚĘĖĔĒ',
      'gğġģĝ',
      'GĞĠĢĜ',
      'iìíîïĩīĭį',
      'IÌÍÎÏĨĪĬĮ',
      'lĺļľŀł',
      'LĹĻĽĿŁ',
      'nñńņňŋ',
      'NÑŃŅŇŊ',
      'oōŏőòóôõö',
      'OŌŎŐÒÓÔÕÖ',
      'rŕŗř',
      'RŔŖŘ',
      'sśşš',
      'SŚŞŠ',
      'tţťŧ',
      'TŢŤŦ',
      'uùúûüũūŭůűų',
      'UÙÚÛÜŨŪŬŮŰŲ',
    ];
    // Map with all accents
    Map<String, String> accentsMap = Map.fromEntries(accents
        .map((accents) => accents.split('').map((e) => MapEntry(e, accents[0])))
        .toList()
        .expand((i) => i));

    //Main code
    List<TextSpan> _spans = List();
    int _start = 0;

    //For "No Case Sensitive" option
    String _lowerCaseText = text.toLowerCase();
    List<String> _lowerCaseHighlights = List();

    highlights.forEach((element) {
      _lowerCaseHighlights.add(element.toLowerCase());
    });

    while (true) {
      Map<int, String> _highlightsMap = Map(); //key (index), value (highlight).

      if (caseSensitive) {
        for (int i = 0; i < highlights.length; i++) {
          int _index = accentSensitiveText(text, accentsMap)
              .indexOf(accentSensitiveText(highlights[i], accentsMap), _start);
          if (_index >= 0) {
            _highlightsMap.putIfAbsent(_index, () => highlights[i]);
          }
        }
      } else {
        for (int i = 0; i < highlights.length; i++) {
          int _index = accentSensitiveText(_lowerCaseText, accentsMap).indexOf(
              accentSensitiveText(_lowerCaseHighlights[i], accentsMap), _start);
          if (_index >= 0) {
            _highlightsMap.putIfAbsent(_index, () => highlights[i]);
          }
        }
      }

      if (_highlightsMap.isNotEmpty) {
        List<int> _indexes = List();
        _highlightsMap.forEach((key, value) => _indexes.add(key));

        int _currentIndex = _indexes.reduce(min);
        String _currentHighlight = text.substring(_currentIndex,
            _currentIndex + _highlightsMap[_currentIndex].length);

        if (_currentIndex == _start) {
          _spans.add(_highlightSpan(_currentHighlight));
          _start += _currentHighlight.length;
        } else {
          _spans.add(_normalSpan(text.substring(_start, _currentIndex)));
          _spans.add(_highlightSpan(_currentHighlight));
          _start = _currentIndex + _currentHighlight.length;
        }
      } else {
        _spans.add(_normalSpan(text.substring(_start, text.length)));
        break;
      }
    }

    return _richText(TextSpan(children: _spans));
  }

  TextSpan _highlightSpan(String value) {
    if (style.color == null) {
      return TextSpan(
        text: value,
        style: style.copyWith(
          color: Colors.black,
          backgroundColor: color,
        ),
      );
    } else {
      return TextSpan(
        text: value,
        style: style.copyWith(
          backgroundColor: color,
        ),
      );
    }
  }

  TextSpan _normalSpan(String value) {
    if (style.color == null) {
      return TextSpan(
        text: value,
        style: style.copyWith(
          color: Colors.black,
        ),
      );
    } else {
      return TextSpan(
        text: value,
        style: style,
      );
    }
  }

  RichText _richText(TextSpan text) {
    return RichText(
      key: key,
      text: text,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  String removeAccents(String text, Map accentsMap) {
    return text
        .split('')
        .map((e) => accentsMap.containsKey(e) ? accentsMap[e] : e)
        .toList()
        .fold('', (previousValue, element) => previousValue + element);
  }

  String accentSensitiveText(text, Map accentsMap) {
    if (!accentSensitive) return removeAccents(text, accentsMap);
    return text;
  }
}
