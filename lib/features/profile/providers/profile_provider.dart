import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/profile/models/profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});

final profileDataProvider = FutureProvider.autoDispose<ProfileModel>((ref) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return await profileRepository.getProfile();
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ProfileModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    return ProfileModel.fromJson(response);
  }

  Future<ProfileModel> updateProfile({
    String? name,
    File? avatarFile,
    String? gender,
    String? dob,
    String? country,
    String? bio,
  }) async {
    final fields = <String, dynamic>{
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender,
      if (dob != null) 'dob': dob,
      if (country != null) 'country': country,
      if (bio != null) 'bio': bio,
    };

    dynamic response;
    if (avatarFile != null) {
      response = await _apiClient.uploadMultipart(
        ApiEndpoints.profile,
        fields: fields,
        files: {'avatar': avatarFile},
        method: 'PUT',
      );
    } else {
      response = await _apiClient.put(
        ApiEndpoints.profile,
        data: fields,
      );
    }

    return ProfileModel.fromJson(response);
  }
}
