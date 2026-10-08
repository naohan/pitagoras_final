import '../dto/json_parse.dart';
import 'base_dto.dart';

class UniversityResponseDto extends BaseDto {
  const UniversityResponseDto({
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

  factory UniversityResponseDto.fromJson(Map<String, dynamic> json) {
    return UniversityResponseDto(
      id: parseInt(json['id']),
      code: json['code'] as String,
      name: json['name'] as String,
      country: json['country'] as String? ?? 'PE',
      isActive: parseBool(json['is_active'], fallback: true),
    );
  }
}

class CareerResponseDto extends BaseDto {
  const CareerResponseDto({
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

  factory CareerResponseDto.fromJson(Map<String, dynamic> json) {
    return CareerResponseDto(
      id: parseInt(json['id']),
      universityId: parseInt(json['university_id']),
      code: json['code'] as String,
      name: json['name'] as String,
      isActive: parseBool(json['is_active'], fallback: true),
      targetScore: json['target_score'] == null
          ? null
          : parseDecimal(json['target_score']),
      scoreMin:
          json['score_min'] == null ? null : parseDecimal(json['score_min']),
      scoreMax:
          json['score_max'] == null ? null : parseDecimal(json['score_max']),
      scoreRangeLabel: json['score_range_label'] as String?,
    );
  }
}

class AreaResponseDto extends BaseDto {
  const AreaResponseDto({
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

  factory AreaResponseDto.fromJson(Map<String, dynamic> json) {
    return AreaResponseDto(
      id: parseInt(json['id']),
      admissionProcessId: parseInt(json['admission_process_id']),
      name: json['name'] as String,
      displayOrder: parseIntOrNull(json['display_order']) ?? 0,
      isActive: parseBool(json['is_active'], fallback: true),
    );
  }
}
