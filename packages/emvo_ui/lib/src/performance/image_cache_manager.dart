import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EmvoImageCache {
  static void configure() {
    // Configure image cache
    PaintingBinding.instance.imageCache.maximumSize = 100; // Max 100 images
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        50 * 1024 * 1024; // 50MB
  }

  static Widget loadImage({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _defaultError(),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }

  static Widget _defaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  static Widget _defaultError() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.error),
    );
  }

  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
