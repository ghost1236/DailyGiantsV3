import 'package:flutter/material.dart';
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
            config.color.withOpacity(0.7),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 패턴
          if (config.hasStripe)
            Positioned(
              right: 0,
              child: ClipOval(
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: size * 0.35,
                    color: config.stripeColor.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          // 팀 약자
          Text(
            config.abbr,
            style: TextStyle(
              color: config.textColor,
              fontSize: size * 0.32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  _TeamConfig _getTeamConfig(String teamName) {
    final name = teamName.trim();

    if (name.contains('롯데')) {
      return _TeamConfig(
        abbr: 'L',
        color: const Color(0xFF062045),
        textColor: Colors.white,
        hasStripe: true,
        stripeColor: const Color(0xFFC41919),
      );
    }
    if (name.contains('KIA') || name.contains('기아')) {
      return _TeamConfig(
        abbr: 'KIA',
        color: const Color(0xFFEA0029),
        textColor: Colors.white,
        hasStripe: true,
        stripeColor: const Color(0xFF000000),
      );
    }
    if (name.contains('SSG') || name.contains('랜더스')) {
      return _TeamConfig(
        abbr: 'SSG',
        color: const Color(0xFFCE0E2D),
        textColor: const Color(0xFFFFD700),
      );
    }
    if (name.contains('삼성') || name.contains('라이온즈')) {
      return _TeamConfig(
        abbr: 'SS',
        color: const Color(0xFF074CA1),
        textColor: Colors.white,
        hasStripe: true,
        stripeColor: Colors.white,
      );
    }
    if (name.contains('두산') || name.contains('베어스')) {
      return _TeamConfig(
        abbr: 'OB',
        color: const Color(0xFF131230),
        textColor: Colors.white,
        hasStripe: true,
        stripeColor: const Color(0xFFFF0000),
      );
    }
    if (name.contains('한화') || name.contains('이글스')) {
      return _TeamConfig(
        abbr: 'HH',
        color: const Color(0xFFFF6600),
        textColor: Colors.white,
      );
    }
    if (name.contains('NC') || name.contains('다이노스')) {
      return _TeamConfig(
        abbr: 'NC',
        color: const Color(0xFF315288),
        textColor: const Color(0xFFC6AA76),
      );
    }
    if (name.contains('키움') || name.contains('히어로즈')) {
      return _TeamConfig(
        abbr: 'KW',
        color: const Color(0xFF820024),
        textColor: Colors.white,
        hasStripe: true,
        stripeColor: const Color(0xFFFF6B00),
      );
    }
    if (name.contains('KT') || name.contains('kt') || name.contains('위즈')) {
      return _TeamConfig(
        abbr: 'KT',
        color: const Color(0xFF000000),
        textColor: const Color(0xFFEE2737),
      );
    }
    if (name.contains('LG') || name.contains('트윈스')) {
      return _TeamConfig(
        abbr: 'LG',
        color: const Color(0xFFC30452),
        textColor: Colors.white,
      );
    }

    return _TeamConfig(
      abbr: name.length >= 2 ? name.substring(0, 2) : name,
      color: AppColors.textTertiary,
      textColor: Colors.white,
    );
  }
}

class _TeamConfig {
  final String abbr;
  final Color color;
  final Color textColor;
  final bool hasStripe;
  final Color stripeColor;

  _TeamConfig({
    required this.abbr,
    required this.color,
    required this.textColor,
    this.hasStripe = false,
    this.stripeColor = Colors.transparent,
  });
}
