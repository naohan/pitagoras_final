import '../../data/models/rag_model.dart';

/// Convierte el diagrama a texto plano para copiar o exportar.
String materialDiagramToText(MaterialDiagram diagram) {
  final buffer = StringBuffer()
    ..writeln(diagram.title)
    ..writeln('=' * diagram.title.length.clamp(3, 80))
    ..writeln();

  for (final node in diagram.nodes) {
    _writeNode(buffer, node, 0);
  }

  if (diagram.chunkCount > 0) {
    buffer
      ..writeln()
      ..writeln('Fragmentos analizados: ${diagram.chunkCount}');
  }

  return buffer.toString().trim();
}

void _writeNode(StringBuffer buffer, MaterialDiagramNode node, int depth) {
  final indent = '  ' * depth;
  final prefix = depth == 0 ? '' : '- ';
  buffer.writeln('$indent$prefix${node.label}');
  for (final child in node.children) {
    _writeNode(buffer, child, depth + 1);
  }
}

String materialDiagramFileName(String title) {
  final cleaned = title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9áéíóúñü\s-]', caseSensitive: false), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');
  final base = cleaned.isEmpty ? 'diagrama-apuntes' : cleaned;
  return '$base.txt';
}
