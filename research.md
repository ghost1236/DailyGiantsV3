# Research — DailyGiants 메뉴 개편

## 1. 현재 앱 구조

### 1-1. 프로젝트 디렉토리 구조

```
lib/
├── main.dart
├── app_router.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── network/
│   │   ├── api_client.dart          # Dio 클라이언트
│   │   └── scraper_client.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── features/
│   ├── cheerleader/                 # 응원단 (삭제 대상)
│   │   ├── data/cheerleader_models.dart
│   │   ├── presentation/cheerleader_screen.dart
│   │   └── providers/cheerleader_provider.dart
│   ├── cheering_song/               # 응원가
│   │   ├── data/
│   │   │   ├── song_models.dart
│   │   │   └── local_songs.dart
│   │   ├── presentation/cheering_song_screen.dart
│   │   └── providers/song_provider.dart
│   ├── player/                      # 선수 (직관정보로 교체)
│   │   ├── data/
│   │   │   ├── player_models.dart
│   │   │   └── player_scraper.dart
│   │   ├── presentation/
│   │   │   ├── player_screen.dart
│   │   │   └── player_detail_screen.dart
│   │   └── providers/player_provider.dart
│   ├── ranking/
│   │   ├── data/ranking_models.dart
│   │   ├── presentation/ranking_screen.dart
│   │   └── providers/ranking_provider.dart
│   ├── schedule/
│   │   ├── data/schedule_models.dart
│   │   ├── presentation/schedule_screen.dart
│   │   └── providers/schedule_provider.dart
│   └── scoreboard/
│       ├── data/
│       │   ├── lineup_models.dart
│       │   └── scoreboard_models.dart
│       ├── presentation/scoreboard_screen.dart
│       └── providers/
│           ├── lineup_provider.dart
│           └── scoreboard_provider.dart
└── shared/
    └── widgets/
        ├── app_header.dart
        ├── banner_ad_widget.dart
        ├── error_view.dart
        ├── loading_indicator.dart
        ├── main_shell.dart          # 하단 네비게이션
        ├── section_header.dart
        └── team_logo.dart
```

### 1-2. 하단 네비게이션 구성

- **방식**: GoRouter ShellRoute + 커스텀 Row 기반 네비게이션 (main_shell.dart)
- **위치 판별**: `GoRouterState.of(context).uri.toString()`으로 현재 경로 확인

| 인덱스 | 메뉴 | 경로 | 아이콘 |
|--------|------|------|--------|
| 0 | 스코어 | /scoreboard | Icons.sports_baseball |
| 1 | 일정 | /schedule | ic_cal.png |
| 2 | 순위 | /ranking | ic_rank.png |
| 3 | 선수단 | /players | ic_player.png |
| 4 | 응원가 | /songs | ic_cheersong.png |
| 5 | 응원단 | /cheerleaders | Icons.stars |

### 1-3. 선수 메뉴 관련 파일 (교체 대상)

| 구분 | 파일 |
|------|------|
| Screen | `features/player/presentation/player_screen.dart` |
| Screen | `features/player/presentation/player_detail_screen.dart` |
| Provider | `features/player/providers/player_provider.dart` |
| Model | `features/player/data/player_models.dart` |
| Scraper | `features/player/data/player_scraper.dart` |
| Route | `app_router.dart` — `/players`, `/player/:id` |
| Nav | `shared/widgets/main_shell.dart` — index 3 |

### 1-4. 응원단 메뉴 관련 파일 (삭제 대상)

| 구분 | 파일 |
|------|------|
| Screen | `features/cheerleader/presentation/cheerleader_screen.dart` |
| Provider | `features/cheerleader/providers/cheerleader_provider.dart` |
| Model | `features/cheerleader/data/cheerleader_models.dart` |
| Route | `app_router.dart` — `/cheerleaders` |
| Nav | `shared/widgets/main_shell.dart` — index 5 |
| API | `core/constants/api_constants.dart` — `cheerleaderList` |

---

## 2. 네트워크 레이어

### 2-1. Dio 설정

- **파일**: `lib/core/network/api_client.dart`
- **Provider**: `apiClientProvider` (Riverpod Provider)
- **BaseUrl**: `http://smiling.kr:5580/DailyGiants_api`
- **Timeout**: connect 10s, receive 10s
- **Header**: `Content-Type: application/json`
- **Interceptor**: LogInterceptor (request/response body 출력)

### 2-2. API 호출 패턴

```dart
// Provider에서 직접 apiClientProvider를 읽어 호출
final someProvider = FutureProvider<List<Model>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get(ApiConstants.endpoint);
  final List data = response.data['list'] ?? [];
  return data.map((json) => Model.fromJson(json)).toList();
});
```

### 2-3. 응답 패턴

- Rankings: `{ "list": [...] }`
- Schedule: `{ "match": [...] }`
- Players: `{ "list": [...] }`
- Cheerleaders: `{ "list": [...] }`
- Songs: `[...]` 또는 `{ "data": [...] }`

### 2-4. 에러 처리

- `AsyncValue.when(data:, loading:, error:)` 패턴
- 공통 위젯: `LoadingIndicator`, `ErrorView` (재시도 버튼 포함)

---

## 3. 상태관리 구조 (Riverpod)

> **주의**: 요청 문서에 GetX로 명시되어 있으나, 실제 프로젝트는 **Riverpod + GoRouter** 사용. 기존 아키텍처에 맞춰 Riverpod으로 구현.

### 3-1. Provider 패턴

| 유형 | 용도 | 예시 |
|------|------|------|
| StateProvider | 단순 상태 | songTabProvider, positionFilterProvider |
| FutureProvider | API 데이터 | playerListProvider, teamRankProvider |
| FutureProvider.family | 파라미터 API | scheduleProvider(month), playerDetailProvider(id) |
| AsyncNotifier | 복잡 비동기 | LineupNotifier |
| Provider | 계산/싱글톤 | filteredPlayerProvider, apiClientProvider |

### 3-2. Consumer 패턴

- `ConsumerWidget` — 대부분의 화면
- `ref.watch()` — 반응형 상태 읽기
- `ref.read()` — 일회성 읽기 (이벤트 핸들러)
- `ref.invalidate()` — 캐시 무효화

---

## 4. 직관정보 UI 요구사항 분석

### 4-1. 기존 TabBar 사용 사례

앱 내 TabBar/TabBarView를 직접 사용하는 곳 없음. 모든 탭 UI는 **커스텀 버튼 Row** 방식:

- 순위: 팀/선수 토글 → 타자/투수 토글
- 응원가: 팀 응원가/선수 응원가 토글
- 일정: 캘린더/목록 토글

→ 직관정보 상세의 5탭은 기존 패턴과 다르므로 **TabBar+TabBarView** 사용 권장 (탭 5개는 커스텀 버튼으로 처리하기 어려움)

### 4-2. ListView/GridView 사용 패턴

- **GridView**: 선수(3열), 응원단(2열)
- **ListView**: 일정, 응원가, 순위
- 구장 목록은 ListView 또는 GridView(2열) 적합

### 4-3. 재사용 가능한 공통 Widget

| Widget | 파일 | 용도 |
|--------|------|------|
| AppHeader | app_header.dart | 표준 앱바 (네이비 배경) |
| LoadingIndicator | loading_indicator.dart | 로딩 표시 |
| ErrorView | error_view.dart | 에러 + 재시도 |
| SectionHeader | section_header.dart | 섹션 제목 |
| TeamLogo | team_logo.dart | 팀 로고 원형 |

---

## 5. API Endpoints (api_constants.dart)

```
Base URL: http://smiling.kr:5580/DailyGiants_api

/apis/matchs/{year}/{month}   — 경기 일정
/apis/teamRank                 — 팀 순위
/apis/hitterRank               — 타자 순위
/apis/PitcherRank              — 투수 순위
/apis/player                   — 선수 목록
/apis/player/{id}              — 선수 상세
/apis/teamsongs                — 팀 응원가
/apis/playersongs              — 선수 응원가
/apis/cheerleaderlist          — 응원단 목록

(신규 필요)
/apis/stadiums                 — 구장 목록
/apis/stadiums/{id}            — 구장 상세
```
