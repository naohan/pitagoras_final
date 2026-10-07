import '../../data/models/catalog_model.dart';
import '../../features/catalog/providers/catalog_provider.dart';
import '../../features/preparation/providers/preparation_provider.dart';
import '../utils/text_encoding.dart';
import 'session_manager.dart';

/// Asegura un `career_id` numérico en sesión (necesario para plantillas/simulacro).
abstract final class CareerIdResolver {
  static Future<int?> ensure({
    required SessionManager session,
    CatalogProvider? catalog,
    PreparationProvider? preparation,
  }) async {
    final existing = await session.getCareerId();
    if (existing != null) return existing;

    if (preparation != null) {
      try {
        final profile = await preparation.getProfile();
        if (profile.careerId != null) {
          await session.saveCareerId(profile.careerId);
          if (profile.careerName != null && profile.careerName!.isNotEmpty) {
            await session.saveCareerName(profile.careerName);
          }
          if (profile.universityId != null) {
            await session.saveUniversityId(profile.universityId);
          }
          if (profile.universityName != null &&
              profile.universityName!.isNotEmpty) {
            await session.saveUniversityName(profile.universityName);
          }
          if (profile.admissionProcessId != null) {
            await session.saveAdmissionProcessId(profile.admissionProcessId);
          }
          return profile.careerId;
        }
      } catch (_) {
        // Sigue con catálogo.
      }
    }

    if (catalog == null) return null;

    final careerName = await session.getCareerName();
    if (careerName == null || careerName.isEmpty) return null;

    try {
      final match = await _findCareer(session, catalog, careerName);
      if (match == null) return null;
      await session.saveCareerId(match.career.id);
      await session.saveCareerName(match.career.name);
      await session.saveUniversityId(match.universityId);
      return match.career.id;
    } catch (_) {
      return null;
    }
  }

  static Future<({Career career, int universityId})?> _findCareer(
    SessionManager session,
    CatalogProvider catalog,
    String careerName,
  ) async {
    var universityId = await session.getUniversityId();
    if (universityId == null) {
      universityId = await _inferUniversityId(session, catalog);
    }

    if (universityId != null) {
      final careers = await catalog.listCareers(universityId);
      final match = _matchCareer(careers, careerName);
      if (match != null) {
        return (career: match, universityId: universityId);
      }
    }

    // Último recurso: buscar la carrera por nombre en todas las universidades.
    final universities = await catalog.listUniversities();
    for (final university in universities) {
      final careers = await catalog.listCareers(university.id);
      final match = _matchCareer(careers, careerName);
      if (match != null) {
        return (career: match, universityId: university.id);
      }
    }
    return null;
  }

  static Future<int?> _inferUniversityId(
    SessionManager session,
    CatalogProvider catalog,
  ) async {
    final universityName = await session.getUniversityName();
    if (universityName == null || universityName.isEmpty) return null;
    final universities = await catalog.listUniversities();
    final target = _normalize(universityName);
    for (final university in universities) {
      final name = _normalize(university.name);
      final code = university.code.toLowerCase();
      if (name == target ||
          name.contains(target) ||
          target.contains(name) ||
          target.contains(code)) {
        return university.id;
      }
    }
    return null;
  }

  static Career? _matchCareer(List<Career> careers, String rawName) {
    final target = _normalize(rawName);
    for (final career in careers) {
      if (_normalize(career.name) == target) return career;
    }
    for (final career in careers) {
      final name = _normalize(career.name);
      if (name.contains(target) || target.contains(name)) return career;
    }
    if (target.contains('sistem')) {
      for (final career in careers) {
        if (_normalize(career.name).contains('sistem')) return career;
      }
    }
    if (target.contains('civil')) {
      for (final career in careers) {
        if (_normalize(career.name).contains('civil')) return career;
      }
    }
    return null;
  }

  static String _normalize(String input) {
    final fixed = fixMojibake(input).toLowerCase().trim();
    return fixed
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
