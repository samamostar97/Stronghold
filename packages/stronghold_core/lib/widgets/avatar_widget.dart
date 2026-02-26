import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Avatar with optional network image and initials fallback — Aether design.
class AvatarWidget extends StatelessWidget {
  final String initials;
  final double size;
  final String? imageUrl;
  final Gradient gradient;
  final Color textColor;
  final double borderRadius;

  const AvatarWidget({
    super.key,
    required this.initials,
    this.size = 40,
    this.imageUrl,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF4F8EF7), Color(0xFF38BDF8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.textColor = Colors.white,
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _initialsAvatar(),
        errorWidget: (context, url, error) => _initialsAvatar(),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    final fontSize = size * 0.38;
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
