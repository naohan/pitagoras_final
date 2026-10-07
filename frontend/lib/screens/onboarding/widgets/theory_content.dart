import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Renderiza la teoría de un subtema, escrita en markdown ligero por el
/// enriquecedor del backend (`#`, `##`, `###`, `**negrita**`, viñetas `-` y
/// enlaces http).
class TheoryContent extends StatelessWidget {
  const TheoryContent({super.key, required this.text});

  final String text;

  static const _bodyStyle = TextStyle(
    fontSize: 14.5,
    height: 1.55,
    color: AppColors.navy,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _blocks().toList(),
    );
  }

  Iterable<Widget> _blocks() sync* {
    final paragraph = <String>[];

    Widget? flushParagraph() {
      if (paragraph.isEmpty) return null;
      final joined = paragraph.join(' ');
      paragraph.clear();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SelectableText.rich(
          TextSpan(children: _inlineSpans(joined, _bodyStyle)),
          style: _bodyStyle,
        ),
      );
    }

    for (final rawLine in text.split('\n')) {
      final line = rawLine.trimRight();
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        final block = flushParagraph();
        if (block != null) yield block;
        continue;
      }

      final heading = RegExp(r'^(#{1,4})\s+(.*)$').firstMatch(trimmed);
      if (heading != null) {
        final block = flushParagraph();
        if (block != null) yield block;
        yield _heading(heading.group(1)!.length, heading.group(2)!.trim());
        continue;
      }

      if (trimmed.startsWith('- ') || trimmed.startsWith('• ')) {
        final block = flushParagraph();
        if (block != null) yield block;
        yield _bullet(trimmed.substring(2).trim());
        continue;
      }

      // Línea que solo contiene negrita: subtítulo de sección enciclopédica.
      final boldOnly = RegExp(r'^\*\*(.+)\*\*$').firstMatch(trimmed);
      if (boldOnly != null) {
        final block = flushParagraph();
        if (block != null) yield block;
        yield _heading(4, boldOnly.group(1)!.trim());
        continue;
      }

      paragraph.add(trimmed);
    }

    final last = flushParagraph();
    if (last != null) yield last;
  }

  Widget _heading(int level, String value) {
    if (level == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      );
    }
    if (level == 2) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (level == 3) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 6, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.navyLight,
        ),
      ),
    );
  }

  Widget _bullet(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7, right: 8),
            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
          ),
          Expanded(
            child: SelectableText.rich(
              TextSpan(children: _inlineSpans(value, _bodyStyle)),
              style: _bodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _inlineSpans(String value, TextStyle base) {
    final pattern = RegExp(r'\*\*(.+?)\*\*|(https?://\S+)');
    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in pattern.allMatches(value)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: value.substring(cursor, match.start)));
      }
      final bold = match.group(1);
      if (bold != null) {
        spans.add(
          TextSpan(
            text: bold,
            style: base.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: match.group(2)!,
            style: base.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }
      cursor = match.end;
    }

    if (cursor < value.length) {
      spans.add(TextSpan(text: value.substring(cursor)));
    }
    return spans;
  }
}
