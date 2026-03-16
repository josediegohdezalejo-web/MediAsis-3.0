import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget que muestra el logo de MediAsis con el nombre y eslogan.
class MediAsisLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool horizontal;

  const MediAsisLogo({
    super.key,
    this.size = 120,
    this.showTagline = true,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogoIcon(),
          const SizedBox(width: 12),
          _buildText(),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoIcon(),
        const SizedBox(height: 12),
        _buildText(),
      ],
    );
  }

  Widget _buildLogoIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Escudo
          Positioned(
            child: Container(
              width: size * 0.5,
              height: size * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(8),
                  bottom: Radius.circular(size * 0.15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cruz médica
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size * 0.08,
                        height: size * 0.2,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        width: size * 0.2,
                        height: size * 0.08,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        width: size * 0.08,
                        height: size * 0.2,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Mano protectora (arco inferior)
          Positioned(
            bottom: size * 0.15,
            child: Container(
              width: size * 0.7,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(size * 0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Medi',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            Text(
              'Asis',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTeal,
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'TU ASISTENCIA MÉDICA INTEGRAL',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size * 0.08,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryTeal,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget de logo simplificado para el AppBar
class MediAsisAppBarLogo extends StatelessWidget {
  final double height;

  const MediAsisAppBarLogo({
    super.key,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: height,
          height: height,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Container(
              width: height * 0.7,
              height: height * 0.5,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Container(
                  width: height * 0.15,
                  height: height * 0.15,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Medi',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: height * 0.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Asis',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: height * 0.5,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
