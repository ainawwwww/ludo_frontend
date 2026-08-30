class UserModel {
  final int id;
  final String username;
  final String? email;
  final int coins;
  final int diamonds;
  final int level;
  final bool isGuest;
  final String? avatarUrl;
  final String? token;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    required this.coins,
    required this.diamonds,
    required this.level,
    this.isGuest = false,
    this.avatarUrl,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    // Backend wraps response as { status, data: { token, user } }
    // Unwrap the 'data' layer if present
    final Map<String, dynamic> payload =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json;

    final userJson =
        payload.containsKey('user') && payload['user'] is Map<String, dynamic>
            ? payload['user'] as Map<String, dynamic>
            : payload;
    final extractedToken = token ?? payload['token']?.toString();

    return UserModel(
      id: userJson['id'] is int
          ? userJson['id']
          : int.tryParse(userJson['id'].toString()) ?? 0,
      username: userJson['username']?.toString() ?? 'User',
      email: userJson['email']?.toString(),
      coins: userJson['coins'] is int
          ? userJson['coins']
          : int.tryParse(userJson['coins'].toString()) ?? 0,
      diamonds: userJson['diamonds'] is int
          ? userJson['diamonds']
          : int.tryParse(userJson['diamonds'].toString()) ?? 0,
      level: userJson['level'] is int
          ? userJson['level']
          : int.tryParse(userJson['level'].toString()) ?? 1,
      isGuest: userJson['is_guest'] == true || userJson['is_guest'] == 1,
      avatarUrl: userJson['avatar_url']?.toString(),
      token: extractedToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'coins': coins,
      'diamonds': diamonds,
      'level': level,
      'is_guest': isGuest,
      'avatar_url': avatarUrl,
      if (token != null) 'token': token,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    int? coins,
    int? diamonds,
    int? level,
    bool? isGuest,
    String? avatarUrl,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      level: level ?? this.level,
      isGuest: isGuest ?? this.isGuest,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
    );
  }
}
