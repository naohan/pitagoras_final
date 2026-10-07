import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_client.dart';
import 'session_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);
  return ApiClient(sessionManager: sessionManager);
});
