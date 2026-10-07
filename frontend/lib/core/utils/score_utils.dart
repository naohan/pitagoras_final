/// Normaliza puntajes que vienen como 0–100 (API) o 0–1 (mock UI).
abstract final class ScoreUtils {
  static double toUnit(double percent) {
    if (percent > 1) return (percent / 100).clamp(0.0, 1.0);
    return percent.clamp(0.0, 1.0);
  }

  static double toDisplayPercent(double percent) {
    if (percent > 1) return percent.clamp(0, 100);
    return (percent * 100).clamp(0, 100);
  }

  static String formatPercent(double percent, {int decimals = 0}) {
    return '${toDisplayPercent(percent).toStringAsFixed(decimals)}%';
  }
}
