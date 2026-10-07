import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';

/// Sincroniza el flag local de diagnóstico con el examen guardado en servidor.
Future<bool> resolveDiagnosticCompleted(WidgetRef ref) async {
  final session = ref.read(sessionManagerProvider);
  if (await session.isDiagnosticCompleted()) return true;

  final diagnosticExamId = await session.getDiagnosticStudentExamId();
  if (diagnosticExamId == null) return false;

  try {
    await ref.read(diagnosticProvider).getDiagnostic(diagnosticExamId);
    await session.setDiagnosticCompleted(true);
    return true;
  } catch (_) {
    return false;
  }
}
