enum RoomMode {
  quickMatch,
  private,
  vip,
  team;

  static RoomMode fromString(String? value) {
    if (value == null) return RoomMode.quickMatch;
    switch (value.toLowerCase()) {
      case 'private':
        return RoomMode.private;
      case 'vip':
        return RoomMode.vip;
      case 'team':
        return RoomMode.team;
      case 'quickmatch':
      case 'quick_match':
      default:
        return RoomMode.quickMatch;
    }
  }
}
