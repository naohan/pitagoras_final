import 'dart:convert';

/// Corrige texto UTF-8 mal interpretado (mojibake: "IngenierÃa" → "Ingeniería").
String fixMojibake(String input) {
  if (!_looksMojibake(input)) return input;

  try {
    final repaired = utf8.decode(latin1.encode(input), allowMalformed: true);
    if (!_looksMojibake(repaired)) return repaired;
  } catch (_) {
    // Continúa con reemplazos manuales.
  }

  return input
      .replaceAll('IngenierÃ­a', 'Ingeniería')
      .replaceAll('IngenierÃa', 'Ingeniería')
      .replaceAll('IngenierÃAs', 'Ingenierías')
      .replaceAll('IngenierÃas', 'Ingenierías')
      .replaceAll('PitÃ¡goras', 'Pitágoras')
      .replaceAll('PitÃgoras', 'Pitágoras')
      .replaceAll('AgustÃ­n', 'Agustín')
      .replaceAll('AgustÃn', 'Agustín')
      .replaceAll('CatÃ³lica', 'Católica')
      .replaceAll('CatÃlica', 'Católica')
      .replaceAll('MarÃ­a', 'María')
      .replaceAll('MarÃa', 'María')
      .replaceAll('Ã­', 'í')
      .replaceAll('Ã¡', 'á')
      .replaceAll('Ã©', 'é')
      .replaceAll('Ã³', 'ó')
      .replaceAll('Ãº', 'ú')
      .replaceAll('Ã±', 'ñ')
      .replaceAll('Ã', 'í')
      .replaceAll('â€”', '—')
      .replaceAll('â€“', '–');
}

bool _looksMojibake(String input) =>
    input.contains('Ã') || input.contains('â') || input.contains('Â');
