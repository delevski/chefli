import 'dart:convert';

import 'package:flutter/material.dart';

/// Fallback image used when a recipe has no image URL.
const String kRecipeImageFallbackUrl =
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';

/// Returns an [ImageProvider] for [url], which may be either a network
/// http(s) URL or a `data:image/...;base64,...` URI (as returned by the
/// backend's image generation). [Image.network]/[NetworkImage] cannot load
/// data URIs, so those are decoded into a [MemoryImage].
ImageProvider recipeImageProvider(String? url) {
  final effectiveUrl =
      (url != null && url.isNotEmpty) ? url : kRecipeImageFallbackUrl;

  if (effectiveUrl.startsWith('data:image')) {
    const marker = ';base64,';
    final markerIndex = effectiveUrl.indexOf(marker);
    if (markerIndex != -1) {
      try {
        final bytes = base64Decode(effectiveUrl.substring(markerIndex + marker.length));
        return MemoryImage(bytes);
      } catch (_) {
        // Fall through to a network image on malformed data URIs.
      }
    }
  }

  return NetworkImage(effectiveUrl);
}
