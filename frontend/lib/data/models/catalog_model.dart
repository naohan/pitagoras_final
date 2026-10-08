import 'base_model.dart';

class University extends BaseModel {
  const University({
    required this.id,
    required this.code,
    required this.name,
    required this.country,
    required this.isActive,
  });

  final int id;
  final String code;
  final String name;
  final String country;
  final bool isActive;
}

class Career extends BaseModel {
  const Career({
    required this.id,
    required this.universityId,
    required this.code,
    required this.name,
    required this.isActive,
    this.targetScore,
    this.scoreMin,
    this.scoreMax,
    this.scoreRangeLabel,
  });

  final int id;
  final int universityId;
  final String code;
  final String name;
  final bool isActive;
  final double? targetScore;
  final double? scoreMin;
  final double? scoreMax;
  final String? scoreRangeLabel;
}

class AcademicArea extends BaseModel {
  const AcademicArea({
    required this.id,
    required this.admissionProcessId,
    required this.name,
    required this.displayOrder,
    required this.isActive,
  });

  final int id;
  final int admissionProcessId;
  final String name;
  final int displayOrder;
  final bool isActive;
}
