import 'package:flutter/material.dart';

final editorHighlighterStyle = defaultHighlighterStyle.copyWith(fontSize: 13);

const defaultHighlighterStyle = TextStyle(
  height: 1.2,
  fontSize: 15,
  fontFamily: 'SourceCode',
  color: Color(0xFFD4D4D4),
  backgroundColor: Color(0xFF373B3B),
  decorationColor: Color(0xFFD4D4D4),
  fontVariations: <FontVariation>[
    FontVariation('wght', 500.0),
  ],
);
