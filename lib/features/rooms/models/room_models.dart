enum RoomType { private, vip, team }

enum LudoRoomMode { classic, arrow, quick, master }

extension LudoRoomModeLabel on LudoRoomMode {
  String get label => switch (this) {
        LudoRoomMode.classic => 'Classic',
        LudoRoomMode.arrow => 'Arrow',
        LudoRoomMode.quick => 'Quick',
        LudoRoomMode.master => 'Master',
      };
}

enum RoomRole { host, guest }

enum RoomStatus { configuring, waiting, starting, playing, completed }

class RoomSettings {
  const RoomSettings({
    this.maxPlayers = 4,
    this.turnSeconds = 15,
    this.entryFee = 1000,
    this.friendsOnly = true,
    this.voiceEnabled = true,
    this.mode = LudoRoomMode.classic,
    this.magicDice = false,
  });

  final int maxPlayers;
  final int turnSeconds;
  final int entryFee;
  final bool friendsOnly;
  final bool voiceEnabled;
  final LudoRoomMode mode;
  final bool magicDice;

  RoomSettings copyWith({
    int? maxPlayers,
    int? turnSeconds,
    int? entryFee,
    bool? friendsOnly,
    bool? voiceEnabled,
    LudoRoomMode? mode,
    bool? magicDice,
  }) {
    return RoomSettings(
      maxPlayers: maxPlayers ?? this.maxPlayers,
      turnSeconds: turnSeconds ?? this.turnSeconds,
      entryFee: entryFee ?? this.entryFee,
      friendsOnly: friendsOnly ?? this.friendsOnly,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      mode: mode ?? this.mode,
      magicDice: magicDice ?? this.magicDice,
    );
  }
}

class RoomParticipant {
  const RoomParticipant({
    required this.id,
    required this.name,
    required this.seat,
    required this.role,
    this.ready = false,
    this.muted = false,
  });

  final String id;
  final String name;
  final int seat;
  final RoomRole role;
  final bool ready;
  final bool muted;

  RoomParticipant copyWith({bool? ready, bool? muted}) => RoomParticipant(
    id: id,
    name: name,
    seat: seat,
    role: role,
    ready: ready ?? this.ready,
    muted: muted ?? this.muted,
  );
}

class RoomSession {
  const RoomSession({
    required this.id,
    required this.code,
    required this.type,
    required this.settings,
    required this.participants,
    required this.currentUserRole,
    this.status = RoomStatus.waiting,
  });

  final int id;
  final String code;
  final RoomType type;
  final RoomSettings settings;
  final List<RoomParticipant> participants;
  final RoomRole currentUserRole;
  final RoomStatus status;

  bool get isHost => currentUserRole == RoomRole.host;
  bool get canStart =>
      participants.length >= 2 &&
      participants.where((p) => p.role == RoomRole.guest).every((p) => p.ready);

  RoomSession copyWith({
    RoomSettings? settings,
    List<RoomParticipant>? participants,
    RoomStatus? status,
  }) {
    return RoomSession(
      id: id,
      code: code,
      type: type,
      settings: settings ?? this.settings,
      participants: participants ?? this.participants,
      currentUserRole: currentUserRole,
      status: status ?? this.status,
    );
  }
}

class RoomFlowState {
  const RoomFlowState({this.session, this.isLoading = false, this.error});

  final RoomSession? session;
  final bool isLoading;
  final String? error;

  RoomFlowState copyWith({
    RoomSession? session,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RoomFlowState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
