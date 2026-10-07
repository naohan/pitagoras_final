import '../../data/models/exam_model.dart';
import '../../features/catalog/providers/catalog_provider.dart';
import '../../features/exam/providers/exam_provider.dart';
import '../../features/preparation/providers/preparation_provider.dart';
import 'career_id_resolver.dart';
import 'exam_template_not_found.dart';
import 'session_manager.dart';

/// Resuelve la plantilla de examen según carrera (API) o proceso de admisión.
abstract final class ExamTemplateResolver {
  static Future<void> remember(SessionManager session, ExamTemplate template) async {
    if (template.id <= 0) return;
    await session.saveExamTemplateId(template.id);
    await session.saveAdmissionProcessId(template.admissionProcessId);
  }

  /// Prioridad: carrera → proceso de admisión (área) → plantilla guardada.
  static Future<ExamTemplate> resolveTemplate(
    SessionManager session,
    ExamProvider exam, {
    CatalogProvider? catalog,
    PreparationProvider? preparation,
  }) async {
    final careerId = await CareerIdResolver.ensure(
      session: session,
      catalog: catalog,
      preparation: preparation,
    );
    if (careerId != null) {
      try {
        final template = await exam.getDefaultTemplateForCareer(careerId);
        await remember(session, template);
        return template;
      } catch (_) {
        // Continúa con otros criterios.
      }
    }

    final admissionProcessId = await session.getAdmissionProcessId();
    if (admissionProcessId != null) {
      try {
        final template =
            await exam.getDefaultTemplateForAdmissionProcess(admissionProcessId);
        await remember(session, template);
        return template;
      } catch (_) {
        // Continúa con plantilla guardada.
      }
    }

    final savedId = await session.getExamTemplateId();
    if (savedId != null) {
      try {
        final template = await exam.getExamTemplate(savedId);
        await remember(session, template);
        return template;
      } catch (_) {
        await session.saveExamTemplateId(null);
      }
    }

    throw ExamTemplateNotFoundException();
  }
}
