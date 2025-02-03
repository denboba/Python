import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

class ArticleContentView extends StatelessWidget {
  final String content;
  final bool readOnly;
  final double? height;

  const ArticleContentView({
    super.key,
    required this.content,
    this.readOnly = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    try {
      // Parse the content from JSON string to map
      final contentMap = json.decode(content);

      // Create a QuillController with the content
      final quillController = QuillController(
        document: Document.fromJson(contentMap['ops']),
        selection: const TextSelection.collapsed(offset: 0),
      );

      return SizedBox(
        height: height,
        child: QuillEditor.basic(
          configurations: QuillEditorConfigurations(
            controller: quillController,
            padding: const EdgeInsets.all(16),
            autoFocus: false,
            showCursor: !readOnly,
            // customStyles: DefaultStyles(
            //   paragraph: DefaultTextBlockStyle(
            //     const TextStyle(
            //       fontSize: 16,
            //       height: 1.5,
            //     )
            //         .copyWith(color: CupertinoColors.systemGrey),
            //     const VerticalSpacing(8, 0) as HorizontalSpacing,
            //     const VerticalSpacing(0, 0) as VerticalSpacing,
            //     null,
            //
            //   ),
            //   h1: DefaultTextBlockStyle(
            //     const TextStyle(
            //       fontSize: 32,
            //       height: 1.3,
            //       fontWeight: FontWeight.bold,
            //     ),
            //     const VerticalSpacing(16, 0),
            //     const VerticalSpacing(0, 0),
            //     null,
            //   ),
            //   h2: DefaultTextBlockStyle(
            //     const TextStyle(
            //       fontSize: 24,
            //       height: 1.3,
            //       fontWeight: FontWeight.bold,
            //     ),
            //     const VerticalSpacing(12, 0),
            //     const VerticalSpacing(0, 0),
            //     null,
            //   ),
            //   h3: DefaultTextBlockStyle(
            //     const TextStyle(
            //       fontSize: 20,
            //       height: 1.3,
            //       fontWeight: FontWeight.bold,
            //     ),
            //     const VerticalSpacing(10, 0),
            //     const VerticalSpacing(0, 0),
            //     null,
            //   ),
            //   link: const TextStyle(
            //     decoration: TextDecoration.underline,
            //   ),
            //   bold: const TextStyle(fontWeight: FontWeight.bold),
            //   italic: const TextStyle(fontStyle: FontStyle.italic),
            //   underline: const TextStyle(decoration: TextDecoration.underline),
            //   strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
            // ),
          ),
        ),
      );
    } catch (e) {
      print('Error rendering article content: $e');
      return Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      );
    }
  }
}
