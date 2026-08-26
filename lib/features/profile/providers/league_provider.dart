import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/features/profile/models/league_model.dart';

final leagueRepositoryProvider = Provider<LeagueRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LeagueRepository(apiClient: apiClient);
});

final leagueTiersProvider = FutureProvider.autoDispose<List<LeagueTierModel>>((ref) async {
  final repository = ref.watch(leagueRepositoryProvider);
  return await repository.getTiers();
});

final leagueDivisionProvider = FutureProvider.autoDispose<LeagueDivisionResponse>((ref) async {
  final repository = ref.watch(leagueRepositoryProvider);
  return await repository.getMyDivision();
});

class LeagueRepository {
  final ApiClient _apiClient;

  LeagueRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<LeagueTierModel>> getTiers() async {
    final response = await _apiClient.get('/leagues');
    final dataList = (response['data'] as List<dynamic>?) ?? [];
    return dataList.map((e) => LeagueTierModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LeagueDivisionResponse> getMyDivision() async {
    final response = await _apiClient.get('/leagues/my-division');
    return LeagueDivisionResponse.fromJson(response);
  }
}
