# 데일리 자이언츠 (Daily Giants)

롯데 자이언츠 팬을 위한 올인원 모바일 앱

## 주요 기능

- **스코어보드** — 실시간 경기 스코어 및 라인업 확인
- **경기 일정** — 캘린더 기반 월별 경기 일정 조회
- **팀 순위** — KBO 리그 팀 순위 현황
- **선수 정보** — 선수 프로필 및 상세 기록
- **응원가** — 팀/선수 응원가 재생
- **구장 가이드** — 좌석, 교통, 주차, 맛집, 꿀팁 정보

## 기술 스택

| 구분 | 기술 |
|------|------|
| Framework | Flutter 3.x (Dart SDK >=3.4.3) |
| 상태관리 | Riverpod + riverpod_generator |
| 라우팅 | GoRouter |
| 네트워크 | Dio |
| 오디오 | just_audio |
| UI | Google Fonts, cached_network_image, shimmer, flutter_svg |

## 프로젝트 구조

```
lib/
├── core/           # 상수, 네트워크, 테마
├── features/       # 기능별 모듈 (scoreboard, schedule, ranking, player, cheering_song, stadium)
├── shared/         # 공통 위젯
├── app_router.dart
└── main.dart
```

## 실행 방법

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## 빌드

```bash
# Android
flutter build appbundle

# iOS
flutter build ios
```

## 버전

v2.0.2 (build 1049)
