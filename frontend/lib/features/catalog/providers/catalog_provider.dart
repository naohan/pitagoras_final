import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/dev/offline_data.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/catalog_model.dart';
import '../../../data/repositories/catalog_repository.dart';

class CatalogProvider {
  CatalogProvider({required CatalogRepository repository})
      : _repository = repository;

  final CatalogRepository _repository;

  Future<List<University>> listUniversities() {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.universities);
    }
    return _repository.listUniversities(activeOnly: true);
  }

  Future<List<Career>> listCareers(
    int universityId, {
    int? admissionProcessId,
  }) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.careersForUniversity(universityId));
    }
    return _repository.listCareers(
      universityId: universityId,
      activeOnly: true,
      admissionProcessId: admissionProcessId,
    );
  }

  Future<List<AcademicArea>> listAreas({bool activeOnly = true}) {
    if (AppConfig.offlineMode) {
      return Future.value(OfflineData.areas);
    }
    return _repository.listAreas(activeOnly: activeOnly);
  }
}

final catalogProvider = Provider<CatalogProvider>((ref) {
  return CatalogProvider(repository: ref.watch(catalogRepositoryProvider));
});
