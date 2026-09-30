import 'package:flutter/material.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';

class QuickEntryCardModel {
  final String id;
  final String title;
  final String description;
  final String bgAsset;
  final List<Color> gradient;
  final String filterCategory;
  final List<String> tags;

  QuickEntryCardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.bgAsset,
    required this.gradient,
    required this.filterCategory,
    required this.tags,
  });

  factory QuickEntryCardModel.fromJson(Map<String, dynamic> json) {
    List<Color> parseGradient(dynamic gradRaw) {
      if (gradRaw is List && gradRaw.isNotEmpty) {
        return gradRaw.map((hexStr) {
          final hex = hexStr.toString().replaceAll('#', '');
          if (hex.length == 6) {
            return Color(int.parse('FF$hex', radix: 16));
          } else if (hex.length == 8) {
            return Color(int.parse(hex, radix: 16));
          }
          return const Color(0xFF8E2DE2);
        }).toList();
      }
      return const [Color(0xFF8E2DE2), Color(0xFF4A00E0)];
    }

    final rawTags = json['tags'];
    List<String> tagsList = [];
    if (rawTags is List) {
      tagsList = rawTags.map((e) => e.toString()).toList();
    }

    return QuickEntryCardModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      bgAsset: json['bg_asset']?.toString() ?? 'assets/graphics/card_private.png',
      gradient: parseGradient(json['gradient']),
      filterCategory: json['filter_category']?.toString() ?? 'social',
      tags: tagsList,
    );
  }
}

class PopularHostModel {
  final int id;
  final int userId;
  final String username;
  final String? avatarUrl;
  final String? countryCode;
  final String badge;
  final String? activeRoomCode;
  final int? activeRoomId;
  final String? activeRoomTitle;
  final int memberCount;

  PopularHostModel({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.countryCode,
    this.badge = '🔥',
    this.activeRoomCode,
    this.activeRoomId,
    this.activeRoomTitle,
    this.memberCount = 0,
  });

  factory PopularHostModel.fromJson(Map<String, dynamic> json) {
    final activeRoom = json['active_room'] as Map<String, dynamic>?;
    return PopularHostModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? 'Host',
      avatarUrl: json['avatar_url']?.toString(),
      countryCode: json['country_code']?.toString(),
      badge: json['badge']?.toString() ?? '🔥',
      activeRoomCode: activeRoom?['room_code']?.toString(),
      activeRoomId: activeRoom?['room_id'] is int
          ? activeRoom!['room_id']
          : int.tryParse(activeRoom?['room_id']?.toString() ?? ''),
      activeRoomTitle: activeRoom?['title']?.toString(),
      memberCount: activeRoom?['member_count'] is int
          ? activeRoom!['member_count']
          : int.tryParse(activeRoom?['member_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] is int ? json['current_page'] : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int ? json['last_page'] : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is int ? json['per_page'] : int.tryParse(json['per_page']?.toString() ?? '15') ?? 15,
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      hasMore: json['has_more'] == true || json['has_more'] == 1,
    );
  }
}

class LobbyExploreData {
  final List<QuickEntryCardModel> quickEntryCards;
  final List<RoomModel> recommendedRooms;
  final PaginationModel? pagination;

  LobbyExploreData({
    required this.quickEntryCards,
    required this.recommendedRooms,
    this.pagination,
  });

  factory LobbyExploreData.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final cards = (data['quick_entry_cards'] as List<dynamic>?)
            ?.map((c) => QuickEntryCardModel.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    final rooms = (data['recommended_rooms'] as List<dynamic>?)
            ?.map((r) => RoomModel.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    final pagination = data['pagination'] != null
        ? PaginationModel.fromJson(data['pagination'] as Map<String, dynamic>)
        : null;

    return LobbyExploreData(
      quickEntryCards: cards,
      recommendedRooms: rooms,
      pagination: pagination,
    );
  }
}

class LobbyHotData {
  final List<PopularHostModel> popularHosts;
  final List<RoomModel> trendingRooms;
  final PaginationModel? pagination;

  LobbyHotData({
    required this.popularHosts,
    required this.trendingRooms,
    this.pagination,
  });

  factory LobbyHotData.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final hosts = (data['popular_hosts'] as List<dynamic>?)
            ?.map((h) => PopularHostModel.fromJson(h as Map<String, dynamic>))
            .toList() ??
        [];

    final rooms = (data['trending_rooms'] as List<dynamic>?)
            ?.map((r) => RoomModel.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    final pagination = data['pagination'] != null
        ? PaginationModel.fromJson(data['pagination'] as Map<String, dynamic>)
        : null;

    return LobbyHotData(
      popularHosts: hosts,
      trendingRooms: rooms,
      pagination: pagination,
    );
  }
}

class LobbyMyData {
  final String filter;
  final List<RoomModel> rooms;
  final PaginationModel? pagination;

  LobbyMyData({
    required this.filter,
    required this.rooms,
    this.pagination,
  });

  factory LobbyMyData.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final roomsList = (data['rooms'] as List<dynamic>?)
            ?.map((r) => RoomModel.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    final pagination = data['pagination'] != null
        ? PaginationModel.fromJson(data['pagination'] as Map<String, dynamic>)
        : null;

    return LobbyMyData(
      filter: data['filter']?.toString() ?? 'recently',
      rooms: roomsList,
      pagination: pagination,
    );
  }
}
