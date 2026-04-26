import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';

class TeamLogo extends StatelessWidget {
  final String team;
  final double size;

  const TeamLogo({super.key, required this.team, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final config = _getTeamConfig(team);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.color,
            config.colorDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: config.assetPath.isNotEmpty
            ? Padding(
                padding: EdgeInsets.all(size * 0.1),
                child: SvgPicture.asset(
                  config.assetPath,
                  fit: BoxFit.contain,
                ),
              )
            : Center(
                child: Text(
                  config.fallbackText ?? '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
      ),
    );
  }

  _TeamConfig _getTeamConfig(String teamName) {
    final name = teamName.trim();

    if (name.contains('롯데')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/lotte_mascot.svg',
        color: const Color(0xFF002B7F),
        colorDark: const Color(0xFF001A4D),
      );
    }
    if (name.contains('LG') || name.contains('트윈스')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/lg_mascot.svg',
        color: const Color(0xFFC8102E),
        colorDark: const Color(0xFF9B0D24),
      );
    }
    if (name.contains('KIA') || name.contains('기아') || name.contains('타이거')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/kia_mascot.svg',
        color: const Color(0xFFC8102E),
        colorDark: const Color(0xFF9B0D24),
      );
    }
    if (name.contains('삼성') || name.contains('라이온즈')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/samsung_mascot.svg',
        color: const Color(0xFF074CA1),
        colorDark: const Color(0xFF053672),
      );
    }
    if (name.contains('두산') || name.contains('베어스')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/doosan_mascot.svg',
        color: const Color(0xFF131230),
        colorDark: const Color(0xFF0A0A1A),
      );
    }
    if (name.contains('SSG') || name.contains('랜더스')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/ssg_mascot.svg',
        color: const Color(0xFFCE0E2D),
        colorDark: const Color(0xFF9B0B22),
      );
    }
    if (name.contains('한화') || name.contains('이글스')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/hanwha_mascot.svg',
        color: const Color(0xFFF37321),
        colorDark: const Color(0xFFCC5E18),
      );
    }
    if (name.contains('NC') || name.contains('다이노스')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/nc_mascot.svg',
        color: const Color(0xFF071D49),
        colorDark: const Color(0xFF041230),
      );
    }
    if (name.contains('KT') || name.contains('kt') || name.contains('위즈')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/kt_mascot.svg',
        color: const Color(0xFF000000),
        colorDark: const Color(0xFF1A1A1A),
      );
    }
    if (name.contains('키움') || name.contains('히어로즈')) {
      return _TeamConfig(
        assetPath: 'assets/mascots/kbo/kiwoom_mascot.svg',
        color: const Color(0xFF820024),
        colorDark: const Color(0xFF5C001A),
      );
    }

    // 매칭 안 되면 텍스트 기반 폴백
    return _TeamConfig(
      assetPath: '',
      color: AppColors.textTertiary,
      colorDark: AppColors.textSecondary,
      fallbackText: name.length >= 2 ? name.substring(0, 2) : name,
    );
  }
}

class _TeamConfig {
  final String assetPath;
  final Color color;
  final Color colorDark;
  final String? fallbackText;

  _TeamConfig({
    required this.assetPath,
    required this.color,
    required this.colorDark,
    this.fallbackText,
  });
}
