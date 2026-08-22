import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/profile/models/profile_model.dart';

class ProfileState {
  final String userId;
  final String username;
  final int avatarIndex;
  final String gender;
  final String birthDay;
  final String birthMonth;
  final String country;
  final String bio;

  const ProfileState({
    this.userId = '12345678',
    this.username = 'Player',
    this.avatarIndex = 0,
    this.gender = 'Secret',
    this.birthDay = '01',
    this.birthMonth = 'January',
    this.country = 'Global',
    this.bio = '',
  });

  ProfileState copyWith({
    String? userId,
    String? username,
    int? avatarIndex,
    String? gender,
    String? birthDay,
    String? birthMonth,
    String? country,
    String? bio,
  }) {
    return ProfileState(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      gender: gender ?? this.gender,
      birthDay: birthDay ?? this.birthDay,
      birthMonth: birthMonth ?? this.birthMonth,
      country: country ?? this.country,
      bio: bio ?? this.bio,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  void setAvatar(int index) {
    state = state.copyWith(avatarIndex: index);
  }

  void updateUsername(String username) {
    state = state.copyWith(username: username);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateDateOfBirth(String day, String month) {
    state = state.copyWith(birthDay: day, birthMonth: month);
  }

  void updateCountry(String country) {
    state = state.copyWith(country: country);
  }

  void updateBio(String bio) {
    state = state.copyWith(bio: bio);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) => ProfileNotifier());

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
