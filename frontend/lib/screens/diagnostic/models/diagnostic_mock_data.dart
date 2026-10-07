import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';

class DiagnosticQuestionOption {
  const DiagnosticQuestionOption({
    required this.label,
    required this.text,
    this.isCorrect = false,
  });

  final String label;
  final String text;
  final bool isCorrect;
}

class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.area,
    required this.stem,
    required this.options,
  });

  final String area;
  final String stem;
  final List<DiagnosticQuestionOption> options;
}

class DiagnosticAreaProgress {
  const DiagnosticAreaProgress({
    required this.name,
    required this.iconAsset,
    required this.percent,
    this.isProcessing = false,
  });

  final String name;
  final String iconAsset;
  final double percent;
  final bool isProcessing;
}

class DiagnosticStrengthItem {
  const DiagnosticStrengthItem({required this.name, required this.isStrength});

  final String name;
  final bool isStrength;
}

abstract final class DiagnosticMockData {
  static const int totalQuestions = 60;
  static const int durationMinutes = 60;
  static const int evaluatedAreas = 5;

  static const demoQuestion = DiagnosticQuestion(
    area: 'Matemática',
    stem: 'Si f(x) = x² - 3x + 2, ¿cuál es el valor de f(-2)?',
    options: [
      DiagnosticQuestionOption(label: 'A', text: '0'),
      DiagnosticQuestionOption(label: 'B', text: '12', isCorrect: true),
      DiagnosticQuestionOption(label: 'C', text: '8'),
      DiagnosticQuestionOption(label: 'D', text: '6'),
      DiagnosticQuestionOption(label: 'E', text: '4'),
    ],
  );

  static const processingAreas = [
    DiagnosticAreaProgress(
      name: 'Matemática',
      iconAsset: AppAssets.iconIngenieria,
      percent: 1,
    ),
    DiagnosticAreaProgress(
      name: 'Comunicación',
      iconAsset: AppAssets.iconBook,
      percent: 1,
    ),
    DiagnosticAreaProgress(
      name: 'Ciencia y Tecnología',
      iconAsset: AppAssets.iconMaps,
      percent: 1,
    ),
    DiagnosticAreaProgress(
      name: 'Ciencias Sociales',
      iconAsset: AppAssets.iconSociales,
      percent: 1,
    ),
    DiagnosticAreaProgress(
      name: 'Inglés',
      iconAsset: AppAssets.iconQuestions,
      percent: 0,
      isProcessing: true,
    ),
  ];

  static const resultAreas = [
    DiagnosticAreaProgress(
      name: 'Matemática',
      iconAsset: AppAssets.iconIngenieria,
      percent: 0.82,
    ),
    DiagnosticAreaProgress(
      name: 'Comunicación',
      iconAsset: AppAssets.iconBook,
      percent: 0.64,
    ),
    DiagnosticAreaProgress(
      name: 'Ciencia y Tecnología',
      iconAsset: AppAssets.iconMaps,
      percent: 0.70,
    ),
    DiagnosticAreaProgress(
      name: 'Ciencias Sociales',
      iconAsset: AppAssets.iconSociales,
      percent: 0.61,
    ),
    DiagnosticAreaProgress(
      name: 'Inglés',
      iconAsset: AppAssets.iconQuestions,
      percent: 0.55,
    ),
  ];

  static const strengths = [
    DiagnosticStrengthItem(name: 'Álgebra', isStrength: true),
    DiagnosticStrengthItem(name: 'Geometría', isStrength: true),
    DiagnosticStrengthItem(
      name: 'Ciencia y Tecnología',
      isStrength: false,
    ),
    DiagnosticStrengthItem(
      name: 'Comprensión lectora',
      isStrength: false,
    ),
  ];

  static const double obtainedScore = 62.4;
  static const double minHistorical = 60.0;
  static const double maxHistorical = 72.5;

  static Color progressColor(double percent) {
    if (percent >= 0.7) return const Color(0xFF22C55E);
    if (percent >= 0.6) return const Color(0xFFEAB308);
    return const Color(0xFFF59E0B);
  }
}
