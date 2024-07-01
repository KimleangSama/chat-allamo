import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/markdown/code_element_builder.dart';
import 'package:chat_allamo/util/markdown/editor_highlighter_style.dart';
import 'package:chat_allamo/util/markdown/highlighter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class GeneratedMessage extends StatelessWidget {
  final String message;

  const GeneratedMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/icons/ollama.png'),
                radius: 14,
              ),
            ),
            Expanded(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                decoration: const BoxDecoration(
                  color: scaffoldColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Markdown(
                  data: message.trim(),
                  selectable: true,
                  physics: const NeverScrollableScrollPhysics(),
                  syntaxHighlighter: MdHightLighter(editorHighlighterStyle),
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 6, bottom: 6),
                  styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
                  inlineSyntaxes: const [],
                  extensionSet: md.ExtensionSet.gitHubWeb,
                  onSelectionChanged: (_, __, ___) {},
                  shrinkWrap: true,
                  builders: {'code': CodeElementBuilder()},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
