import '../../../core/constants/app_assets.dart';

class UniversityOption {
  const UniversityOption({
    required this.id,
    required this.acronym,
    required this.fullName,
    this.logoAsset,
    this.initials,
    this.initialsColor,
  });

  final String id;
  final String acronym;
  final String fullName;
  final String? logoAsset;
  final String? initials;
  final int? initialsColor;
}

class AreaOption {
  const AreaOption({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
  });

  final String id;
  final String title;
  final String description;
  final String iconAsset;
}

class CareerOption {
  const CareerOption({
    required this.id,
    required this.name,
    required this.areaName,
    required this.iconAsset,
    required this.minScore,
    required this.maxScore,
  });

  final String id;
  final String name;
  final String areaName;
  final String iconAsset;
  final double minScore;
  final double maxScore;

  String get scoreRange =>
      '${minScore.toStringAsFixed(1)} - ${maxScore.toStringAsFixed(1)}';
}

abstract final class OnboardingMockData {
  static const universities = [
    UniversityOption(
      id: 'unsa',
      acronym: 'UNSA',
      fullName: 'Universidad Nacional de San Agustín',
      logoAsset: AppAssets.logoUnsa,
    ),
    UniversityOption(
      id: 'ucsm',
      acronym: 'UCSM',
      fullName: 'Universidad Católica de Santa María',
      logoAsset: AppAssets.logoCato,
    ),
    UniversityOption(
      id: 'utp',
      acronym: 'UTP',
      fullName: 'Universidad Tecnológica del Perú',
      initials: 'UTP',
      initialsColor: 0xFFDC2626,
    ),
  ];

  static const areas = [
    AreaOption(
      id: 'ingenierias',
      title: 'Ingenierías',
      description:
          'Incluye: Civil, Sistemas, Minas, Mecánica, Eléctrica, Industrial, Informática y más.',
      iconAsset: AppAssets.iconIngenieria,
    ),
    AreaOption(
      id: 'biomedicas',
      title: 'Ciencias Biomédicas',
      description:
          'Incluye: Medicina, Enfermería, Biología, Nutrición, Farmacia y más.',
      iconAsset: AppAssets.iconMedicina,
    ),
    AreaOption(
      id: 'sociales',
      title: 'Ciencias Sociales y Humanidades',
      description:
          'Incluye: Derecho, Administración, Economía, Educación, Psicología y más.',
      iconAsset: AppAssets.iconSociales,
    ),
  ];

  static const engineeringCareers = [
    CareerOption(
      id: 'sistemas',
      name: 'Ingeniería de Sistemas',
      areaName: 'Ingenierías',
      iconAsset: AppAssets.iconSistemas,
      minScore: 60.0,
      maxScore: 72.5,
    ),
    CareerOption(
      id: 'civil',
      name: 'Ingeniería Civil',
      areaName: 'Ingenierías',
      iconAsset: AppAssets.iconCivil,
      minScore: 58.5,
      maxScore: 70.0,
    ),
    CareerOption(
      id: 'arquitectura',
      name: 'Arquitectura',
      areaName: 'Ingenierías',
      iconAsset: AppAssets.iconArquitectura,
      minScore: 55.0,
      maxScore: 68.0,
    ),
    CareerOption(
      id: 'industrial',
      name: 'Ingeniería Industrial',
      areaName: 'Ingenierías',
      iconAsset: AppAssets.iconIndustrial,
      minScore: 57.0,
      maxScore: 69.5,
    ),
  ];

  static List<CareerOption> careersForArea(String areaId) {
    switch (areaId) {
      case 'ingenierias':
        return engineeringCareers;
      case 'biomedicas':
        return const [
          CareerOption(
            id: 'medicina',
            name: 'Medicina Humana',
            areaName: 'Ciencias Biomédicas',
            iconAsset: AppAssets.iconMedicina,
            minScore: 72.0,
            maxScore: 85.0,
          ),
        ];
      case 'sociales':
        return const [
          CareerOption(
            id: 'derecho',
            name: 'Derecho',
            areaName: 'Ciencias Sociales y Humanidades',
            iconAsset: AppAssets.iconSociales,
            minScore: 62.0,
            maxScore: 74.0,
          ),
        ];
      default:
        return engineeringCareers;
    }
  }

  static String areaTitle(String areaId) {
    return areas
        .firstWhere(
          (area) => area.id == areaId,
          orElse: () => areas.first,
        )
        .title;
  }
}
