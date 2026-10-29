import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/incident.dart';

class IncidentPhoto extends StatelessWidget {
  const IncidentPhoto(
      this.incident, {
        super.key,
        this.width,
        this.height,
        this.fit = BoxFit.cover,
        this.fallback,
      });

  final Incident incident;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;

  static final Map<String, Uint8List> _cache = {};

  @override
  Widget build(BuildContext context) {
    final placeholder = fallback ??
        Container(
          width: width,
          height: height,
          color: AppColors.stone,
          child: const Icon(Icons.image_not_supported_outlined,
              color: AppColors.slate),
        );

    final data = incident.photoData;
    if (data != null) {
      final bytes = _cache.putIfAbsent(
          '${incident.id}:${data.length}', () => base64Decode(data));
      return Image.memory(bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => placeholder);
    }
    final url = incident.photoUrl;
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      );
    }
    return placeholder;
  }
}