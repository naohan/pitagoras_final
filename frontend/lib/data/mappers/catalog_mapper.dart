import '../dto/catalog_dto.dart';
import '../models/catalog_model.dart';

abstract final class CatalogMapper {
  static University toUniversity(UniversityResponseDto dto) {
    return University(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      country: dto.country,
      isActive: dto.isActive,
    );
  }

  static Career toCareer(CareerResponseDto dto) {
    return Career(
      id: dto.id,
      universityId: dto.universityId,
      code: dto.code,
      name: dto.name,
      isActive: dto.isActive,
      targetScore: dto.targetScore,
      scoreMin: dto.scoreMin,
      scoreMax: dto.scoreMax,
      scoreRangeLabel: dto.scoreRangeLabel,
    );
  }

  static AcademicArea toArea(AreaResponseDto dto) {
    return AcademicArea(
      id: dto.id,
      admissionProcessId: dto.admissionProcessId,
      name: dto.name,
      displayOrder: dto.displayOrder,
      isActive: dto.isActive,
    );
  }
}
