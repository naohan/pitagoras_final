/// No se encontró plantilla de examen para la carrera/área seleccionada.
class ExamTemplateNotFoundException implements Exception {
  ExamTemplateNotFoundException([
    this.message =
        'No hay simulacro para esta carrera. Vuelve a elegir universidad y una carrera del servidor (Sistemas o Civil).',
  ]);

  final String message;

  @override
  String toString() => message;
}
