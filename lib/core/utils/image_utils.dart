import 'package:flutter/foundation.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';

/// Utility to clean and format image URLs for Web and Mobile platforms,
/// handling relative backend paths and CORS-restricted third-party avatars (like Google).
String? formatAvatarUrl(String? url) {
  if (url == null) return null;
  String cleanUrl = url.trim().replaceAll(r'\/', '/');
  if (cleanUrl.isEmpty) return null;

  // Handle relative backend URLs (e.g., /storage/avatars/user.png)
  if (cleanUrl.startsWith('/')) {
    try {
      final baseUri = Uri.parse(ApiEndpoints.baseUrl);
      final portPart = baseUri.hasPort ? ':${baseUri.port}' : '';
      cleanUrl = '${baseUri.scheme}://${baseUri.host}$portPart$cleanUrl';
    } catch (_) {
      cleanUrl = 'http://127.0.0.1:8000$cleanUrl';
    }
  }

  // On Flutter Web, external URLs (especially Google lh3.googleusercontent.com)
  // are blocked by CanvasKit/Skwasm due to CORS restrictions.
  // We route through weserv / cors proxy to ensure 100% reliable loading.
  if (kIsWeb && cleanUrl.startsWith('http')) {
    if (cleanUrl.contains('googleusercontent.com') ||
        cleanUrl.contains('lh3.google.com') ||
        cleanUrl.contains('ggpht.com')) {
      return 'https://images.weserv.nl/?url=${Uri.encodeComponent(cleanUrl)}&default=avatar';
    }
  }

  return cleanUrl;
}
