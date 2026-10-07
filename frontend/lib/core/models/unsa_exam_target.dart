/// Meta de postulación UNSA — solo UI/local (sin backend).
enum UnsaExamTarget {
  quinto,
  cepreunsa,
  ordinario;

  String get storageKey => name;

  String get label {
    switch (this) {
      case UnsaExamTarget.quinto:
        return 'Quinto UNSA';
      case UnsaExamTarget.cepreunsa:
        return 'CEPREUNSA';
      case UnsaExamTarget.ordinario:
        return 'Ordinario UNSA';
    }
  }

  String get shortLabel {
    switch (this) {
      case UnsaExamTarget.quinto:
        return 'Quinto';
      case UnsaExamTarget.cepreunsa:
        return 'CEPREUNSA';
      case UnsaExamTarget.ordinario:
        return 'Ordinario';
    }
  }

  String get description {
    switch (this) {
      case UnsaExamTarget.quinto:
        return 'Ingreso anticipado para estudiantes de quinto de secundaria.';
      case UnsaExamTarget.cepreunsa:
        return 'Centro Preuniversitario de la UNSA — ruta de preparación intensiva.';
      case UnsaExamTarget.ordinario:
        return 'Examen de admisión ordinario para todas las carreras de ingeniería.';
    }
  }

  String get simulacroFocus {
    switch (this) {
      case UnsaExamTarget.quinto:
        return 'Simulacros tipo Quinto UNSA: 80 preguntas en 150 minutos.';
      case UnsaExamTarget.cepreunsa:
        return 'Simulacros tipo CEPREUNSA: 80 preguntas en 150 minutos.';
      case UnsaExamTarget.ordinario:
        return 'Simulacros tipo Ordinario UNSA: 80 preguntas en 150 minutos.';
    }
  }

  static UnsaExamTarget? fromStorage(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value == 'prequinto') return UnsaExamTarget.quinto;
    for (final target in UnsaExamTarget.values) {
      if (target.storageKey == value) return target;
    }
    return null;
  }

  static bool isUnsaUniversity(String? name, {String? code}) {
    final normalizedCode = code?.trim().toUpperCase();
    if (normalizedCode == 'UNSA') return true;
    final normalizedName = name?.trim().toUpperCase() ?? '';
    return normalizedName.contains('UNSA');
  }
}
