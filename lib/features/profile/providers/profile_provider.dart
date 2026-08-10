import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String username;
  final String userId;
  final int avatarIndex;
  final String gender;
  final String birthDay;
  final String birthMonth;
  final String country;
  final String bio;

  const ProfileState({
    this.username = 'Guest_37869213',
    this.userId = '37869213',
    this.avatarIndex = 0,
    this.gender = 'Unspecified',
    this.birthDay = 'Day',
    this.birthMonth = 'Month',
    this.country = 'Select Country',
    this.bio = '',
  });

  ProfileState copyWith({
    String? username,
    String? userId,
    int? avatarIndex,
    String? gender,
    String? birthDay,
    String? birthMonth,
    String? country,
    String? bio,
  }) {
    return ProfileState(
      username: username ?? this.username,
      userId: userId ?? this.userId,
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

  void updateUsername(String newName) {
    state = state.copyWith(username: newName);
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

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
