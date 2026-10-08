import 'api_client.dart';
import 'api_paths.dart';
import 'base_response.dart';
import '../dto/demo_dto.dart';

class DemoApi {
  const DemoApi(this._client);

  final ApiClient _client;

  Future<BaseResponse<HackathonProfileDto>> getHackathonProfile() {
    return _client.request(
      call: () => _client.get(ApiPaths.hackathonProfile),
      parser: (json) =>
          HackathonProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
