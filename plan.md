# Plan — DailyGiants 메뉴 개편

> research.md 분석 결과 기반. 실제 프로젝트는 **Riverpod + GoRouter** 사용 (문서의 GetX 대신).

---

## 1. 삭제 대상 파일 목록

### 1-1. 응원단 메뉴 삭제

**삭제 순서:**

1. `app_router.dart` — `/cheerleaders` 라우트 제거
2. `shared/widgets/main_shell.dart` — 응원단 NavItem 제거, index 조정
3. `core/constants/api_constants.dart` — `cheerleaderList` 엔드포인트 제거
4. 디렉토리 전체 삭제:
   - `features/cheerleader/presentation/cheerleader_screen.dart`
   - `features/cheerleader/providers/cheerleader_provider.dart`
   - `features/cheerleader/data/cheerleader_models.dart`

**참조 확인 체크리스트:**
- [ ] app_router.dart — CheerleaderScreen import 제거
- [ ] main_shell.dart — index 5 (응원단) 제거, 응원가 index 4 유지
- [ ] api_constants.dart — cheerleaderList 상수 제거

### 1-2. 선수 메뉴 코드 보존

선수 관련 파일은 삭제하지 않고 라우트/네비게이션에서만 교체.
향후 선수 기능 복원 가능성을 위해 `features/player/` 디렉토리 유지.

---

## 2. 직관정보 화면 구조 설계

### 2-1. 신규 생성 파일

```
lib/features/stadium/
├── data/
│   └── stadium_models.dart          # Stadium, StadiumDetail 모델
├── presentation/
│   ├── stadium_list_screen.dart     # 구장 목록
│   ├── stadium_detail_screen.dart   # 구장 상세 (TabBar 5탭)
│   └── tabs/
│       ├── transport_tab.dart       # 교통
│       ├── parking_tab.dart         # 주차
│       ├── seats_tab.dart           # 좌석
│       ├── food_tab.dart            # 맛집
│       └── tips_tab.dart            # 꿀팁
└── providers/
    └── stadium_provider.dart        # Riverpod providers
```

### 2-2. 모델 설계

```dart
class Stadium {
  final int id;
  final String name;        // 사직야구장
  final String team;        // 롯데 자이언츠
  final String address;     // 부산광역시 동래구...
  final String imageUrl;    // 구장 이미지
  final bool isHome;        // 홈구장 여부 (사직 최상단 고정용)

  factory Stadium.fromJson(Map<String, dynamic> json);
}

class StadiumDetail {
  final Stadium stadium;
  final List<StadiumInfo> transport;  // 교통 정보
  final List<StadiumInfo> parking;    // 주차 정보
  final List<StadiumInfo> seats;      // 좌석 정보
  final List<StadiumInfo> food;       // 맛집 정보
  final List<StadiumInfo> tips;       // 꿀팁 정보

  factory StadiumDetail.fromJson(Map<String, dynamic> json);
}

class StadiumInfo {
  final String title;
  final String content;
  final String? imageUrl;
  final String? link;

  factory StadiumInfo.fromJson(Map<String, dynamic> json);
}
```

---

## 3. Dio API 연동 설계

### 3-1. API 엔드포인트 추가

```dart
// api_constants.dart 에 추가
static const String stadiumList = '/apis/stadiums';
static String stadiumDetail(int id) => '/apis/stadiums/$id';
```

### 3-2. Provider 설계 (Riverpod)

```dart
// stadium_provider.dart
final stadiumListProvider = FutureProvider<List<Stadium>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get(ApiConstants.stadiumList);
  final List data = response.data is List
      ? response.data
      : response.data['data'] ?? response.data['list'] ?? [];
  final stadiums = data.map((json) => Stadium.fromJson(json)).toList();
  // 사직구장(홈) 최상단 고정
  stadiums.sort((a, b) {
    if (a.isHome) return -1;
    if (b.isHome) return 1;
    return 0;
  });
  return stadiums;
});

final stadiumDetailProvider = FutureProvider.family<StadiumDetail, int>((ref, id) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get(ApiConstants.stadiumDetail(id));
  return StadiumDetail.fromJson(response.data['data'] ?? response.data);
});

final stadiumTabProvider = StateProvider<int>((ref) => 0);
```

---

## 4. 네비게이션 변경 계획

### 4-1. main_shell.dart 변경

**변경 전 (6탭):**
스코어 | 일정 | 순위 | 선수단 | 응원가 | 응원단

**변경 후 (5탭):**
스코어 | 일정 | 순위 | 직관정보 | 응원가

| 인덱스 | 메뉴 | 경로 | 아이콘 |
|--------|------|------|--------|
| 0 | 스코어 | /scoreboard | Icons.sports_baseball |
| 1 | 일정 | /schedule | ic_cal.png |
| 2 | 순위 | /ranking | ic_rank.png |
| 3 | 직관정보 | /stadiums | Icons.stadium_outlined / Icons.stadium |
| 4 | 응원가 | /songs | ic_cheersong.png |

### 4-2. app_router.dart 변경

```dart
// 삭제
GoRoute(path: '/cheerleaders', ...)
GoRoute(path: '/players', ...)
GoRoute(path: '/player/:id', ...)

// 추가
GoRoute(path: '/stadiums', builder: StadiumListScreen)
GoRoute(path: '/stadium/:id', builder: StadiumDetailScreen)  // ShellRoute 밖
```

---

## 5. 구장 상세 TabBar 설계

기존 앱은 커스텀 버튼 Row 패턴이지만, 5탭은 TabBar+TabBarView가 적합.

```dart
// stadium_detail_screen.dart
class StadiumDetailScreen extends ConsumerStatefulWidget {
  // TabController 필요 → StatefulWidget + SingleTickerProviderStateMixin
}

// 탭 순서 (고정)
tabs: [교통, 주차, 좌석, 맛집, 꿀팁]
```

---

## 6. Trade-off 검토

| 항목 | 선택 | 이유 |
|------|------|------|
| 탭 UI | TabBar+TabBarView | 5탭은 커스텀 버튼보다 TabBar가 적합, 스와이프 제스처 지원 |
| 데이터 캐싱 | FutureProvider 기본 캐싱 | 구장 정보는 자주 안 바뀜, Riverpod 자체 캐싱 충분 |
| 구장 목록 UI | ListView (카드) | 구장 수가 10개 내외, 이미지+정보 표시에 ListView 적합 |
| 사직구장 고정 | 클라이언트 정렬 | isHome 플래그 기반, 서버 의존 최소화 |
| 선수 코드 | 보존 (라우트만 제거) | 향후 복원 가능, 빌드에 영향 없음 |

---

## 7. 구현 순서

1. 응원단 관련 코드 삭제 및 참조 정리
2. app_router.dart — 선수/응원단 라우트 제거, 구장 라우트 추가
3. main_shell.dart — 네비게이션 5탭으로 변경
4. api_constants.dart — 구장 엔드포인트 추가, 응원단 엔드포인트 삭제
5. Stadium 모델 클래스 생성
6. stadium_provider.dart 생성
7. StadiumListScreen 구현
8. StadiumDetailScreen 구현 (TabBar + 5탭)
9. 탭 Widget 5개 구현
10. 빌드 확인 및 에뮬레이터 테스트
