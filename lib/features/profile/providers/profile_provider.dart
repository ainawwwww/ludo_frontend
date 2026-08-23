import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/profile/models/profile_model.dart';

const List<String> kProfileMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

class ProfileState {
  final String userId;
  final String username;
  final int avatarIndex;
  final String? avatarUrl;
  final String gender;
  final String birthDay;
  final String birthMonth;
  final String country;
  final String bio;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.userId = '12345678',
    this.username = 'Player',
    this.avatarIndex = 0,
    this.avatarUrl,
    this.gender = 'Secret',
    this.birthDay = '01',
    this.birthMonth = 'January',
    this.country = 'Global',
    this.bio = '',
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    String? userId,
    String? username,
    int? avatarIndex,
    String? avatarUrl,
    String? gender,
    String? birthDay,
    String? birthMonth,
    String? country,
    String? bio,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      birthDay: birthDay ?? this.birthDay,
      birthMonth: birthMonth ?? this.birthMonth,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileNotifier({
    required ProfileRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(const ProfileState()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      state = state.copyWith(isLoading: true);
      final profile = await _repository.getProfile();
      initFromProfile(profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void initFromProfile(ProfileModel profile) {
    String parsedDay = state.birthDay;
    String parsedMonth = state.birthMonth;

    if (profile.dob != null && profile.dob!.isNotEmpty) {
      final parts = profile.dob!.split('-');
      if (parts.length == 3) {
        final mIdx = int.tryParse(parts[1]) ?? 1;
        parsedDay = parts[2].padLeft(2, '0');
        if (mIdx >= 1 && mIdx <= 12) {
          parsedMonth = kProfileMonthNames[mIdx - 1];
        }
      }
    }

    String formattedGender = profile.gender ?? 'Unspecified';
    if (formattedGender.toLowerCase() == 'male') formattedGender = 'Male';
    if (formattedGender.toLowerCase() == 'female') formattedGender = 'Female';
    if (formattedGender.toLowerCase() == 'unspecified') formattedGender = 'Unspecified';

    state = state.copyWith(
      userId: profile.id.toString(),
      username: profile.name.isNotEmpty ? profile.name : state.username,
      avatarUrl: profile.avatarUrl,
      gender: formattedGender,
      birthDay: parsedDay,
      birthMonth: parsedMonth,
      country: (profile.country != null && profile.country!.isNotEmpty) ? profile.country : 'Global',
      bio: profile.bio ?? '',
      isLoading: false,
    );
  }

  void setAvatar(int index) {
    state = state.copyWith(avatarIndex: index);
  }

  void setAvatarUrl(String? url) {
    state = state.copyWith(avatarUrl: url);
  }

  Future<bool> updateUsername(String username) async {
    final oldUsername = state.username;
    state = state.copyWith(username: username);
    try {
      final updated = await _repository.updateProfile(name: username);
      initFromProfile(updated);
      return true;
    } catch (e) {
      state = state.copyWith(username: oldUsername, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateGender(String gender) async {
    final oldGender = state.gender;
    state = state.copyWith(gender: gender);
    try {
      final updated = await _repository.updateProfile(gender: gender.toLowerCase());
      initFromProfile(updated);
      return true;
    } catch (e) {
      state = state.copyWith(gender: oldGender, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateDateOfBirth(String day, String month) async {
    final oldDay = state.birthDay;
    final oldMonth = state.birthMonth;
    state = state.copyWith(birthDay: day, birthMonth: month);

    final mIdx = kProfileMonthNames.indexOf(month) + 1;
    final mStr = (mIdx > 0 ? mIdx : 1).toString().padLeft(2, '0');
    final dStr = (int.tryParse(day) ?? 1).toString().padLeft(2, '0');
    final dobStr = '2000-$mStr-$dStr';

    try {
      final updated = await _repository.updateProfile(dob: dobStr);
      initFromProfile(updated);
      return true;
    } catch (e) {
      state = state.copyWith(birthDay: oldDay, birthMonth: oldMonth, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateCountry(String country) async {
    final oldCountry = state.country;
    state = state.copyWith(country: country);
    try {
      final updated = await _repository.updateProfile(country: country);
      initFromProfile(updated);
      return true;
    } catch (e) {
      state = state.copyWith(country: oldCountry, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateBio(String bio) async {
    final oldBio = state.bio;
    state = state.copyWith(bio: bio);
    try {
      final updated = await _repository.updateProfile(bio: bio);
      initFromProfile(updated);
      return true;
    } catch (e) {
      state = state.copyWith(bio: oldBio, errorMessage: e.toString());
      return false;
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository: repository, ref: ref);
});

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
