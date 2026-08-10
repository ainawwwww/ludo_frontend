import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/home/models/home_data_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRepository(apiClient: apiClient);
});

final homeDataProvider = FutureProvider.autoDispose<HomeDataModel>((ref) async {
  final homeRepository = ref.watch(homeRepositoryProvider);
  return await homeRepository.getHomeData();
});

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<HomeDataModel> getHomeData() async {
    final response = await _apiClient.get(ApiEndpoints.home);
    return HomeDataModel.fromJson(response);
  }
}
