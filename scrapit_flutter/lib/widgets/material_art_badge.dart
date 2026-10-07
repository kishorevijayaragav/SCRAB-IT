import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class MaterialArtBadge extends StatelessWidget {
  final String material;
  final double size;

  const MaterialArtBadge({
    super.key,
    required this.material,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = _getMaterialMeta(material);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.54,
          color: fg,
        ),
      ),
    );
  }

  static (Color, Color, IconData) _getMaterialMeta(String material) {
    switch (material.toLowerCase().trim()) {
      case 'aluminium':
      case 'aluminum':
        return (
          const Color(0xFFF0F4F7),
          AppColors.catAluminium,
          Icons.architecture_rounded,
        );
      case 'copper':
        return (
          const Color(0xFFFAF0E8),
          AppColors.catCopper,
          Icons.blur_circular_rounded,
        );
      case 'iron':
        return (
          const Color(0xFFECEFF1),
          AppColors.catIron,
          Icons.hardware_rounded,
        );
      case 'brass':
        return (
          const Color(0xFFFBF6E9),
          AppColors.catBrass,
          Icons.album_rounded,
        );
      case 'plastic':
        return (
          const Color(0xFFEBF5FC),
          AppColors.catPlastic,
          Icons.local_drink_rounded,
        );
      case 'paper':
        return (
          const Color(0xFFF8F5EE),
          AppColors.catPaper,
          Icons.newspaper_rounded,
        );
      case 'e-waste':
      case 'ewaste':
        return (
          const Color(0xFFEDF5F0),
          AppColors.catEWaste,
          Icons.memory_rounded,
        );
      default:
        return (
          AppColors.greenLight,
          AppColors.greenDark,
          Icons.recycling_rounded,
        );
    }
  }
}
