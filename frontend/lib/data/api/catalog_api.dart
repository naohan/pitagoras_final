import '../dto/catalog_dto.dart';
import 'api_client.dart';
import 'api_paths.dart';
import 'base_response.dart';

class CatalogApi {
  const CatalogApi(this._client);

  final ApiClient _client;

  Future<BaseResponse<List<UniversityResponseDto>>> listUniversities({
    bool activeOnly = true,
  }) {
    return _client.requestList(
      call: () => _client.get(
        ApiPaths.universities,
        queryParameters: {'active_only': activeOnly},
      ),
      itemParser: UniversityResponseDto.fromJson,
    );
  }

  Future<BaseResponse<List<CareerResponseDto>>> listCareers({
    required int universityId,
    bool activeOnly = true,
    int? admissionProcessId,
  }) {
    return _client.requestList(
      call: () => _client.get(
        ApiPaths.careers,
        queryParameters: {
          'university_id': universityId,
          'active_only': activeOnly,
          if (admissionProcessId != null)
            'admission_process_id': admissionProcessId,
        },
      ),
      itemParser: CareerResponseDto.fromJson,
    );
  }

  Future<BaseResponse<List<AreaResponseDto>>> listAreas({
    bool activeOnly = true,
    int? admissionProcessId,
  }) {
    return _client.requestList(
      call: () => _client.get(
        ApiPaths.areas,
        queryParameters: {
          'active_only': activeOnly,
          if (admissionProcessId != null)
            'admission_process_id': admissionProcessId,
        },
      ),
      itemParser: AreaResponseDto.fromJson,
    );
  }
}
