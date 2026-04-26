# Claude Code 요청 문서
# DailyGiants Flutter — 메뉴 개편
### 선수 → 직관정보 교체 / 응원단 메뉴 삭제 / Dio 연동
### 플랫폼: Android + iOS

---

## 1. 목적

기존 데일리 자이언츠 Flutter 앱의 하단 네비게이션 메뉴 2개를 개편한다.

| 기존 메뉴 | 변경 | 비고 |
|-----------|------|------|
| 선수 | 직관정보 | 구장별 교통/주차/좌석/맛집/꿀팁 |
| 응원단 | 삭제 | 메뉴 및 관련 코드 전체 제거 |

- HTTP 클라이언트: Dio
- 상태관리: GetX
- 플랫폼: Android + iOS

---

## 2. Phase 1 — Research (research.md 출력)

아래 항목을 깊이/매우 상세히/세부사항 수준으로 분석하여 research.md에 정리할 것.

### 2-1. 현재 앱 구조 파악

- 프로젝트 전체 디렉토리 구조 (lib/ 하위 전체)
- 하단 네비게이션 구성 방식 — BottomNavigationBar or BottomAppBar or GetX 라우팅
- 현재 메뉴 항목 전체 (스코어보드 / 일정 / 기록 / 선수 / 응원가 / 응원단)
- 선수 메뉴 관련 파일 전체 목록 (Screen, Controller, Repository, Model, Widget)
- 응원단 메뉴 관련 파일 전체 목록 (동일 항목)
- GetX 라우팅 설정 파일 (AppPages, AppRoutes) 구조

### 2-2. 네트워크 레이어 파악

- Dio 설정 파일 위치 (BaseUrl, Interceptor, Header 설정)
- 기존 API 호출 패턴 (Repository 패턴 or GetX Service)
- 기존 응답 모델 클래스 패턴 (fromJson, toJson)
- 에러 처리 방식 (DioException 핸들링)

### 2-3. GetX 구조 파악

- Controller 바인딩 방식 (Binding 클래스 or Get.lazyPut)
- Obx / GetBuilder 사용 패턴
- 기존 Controller 생명주기 관리 방식 (onInit, onClose)

### 2-4. 직관정보 UI 요구사항 분석

- 구장 목록 → 구장 선택 → 탭(교통/주차/좌석/맛집/꿀팁) 상세 구조
- 기존 앱 내 TabBar 사용 사례 확인
- ListView / GridView 사용 패턴
- 기존 공통 Widget 목록 (커스텀 카드, 로딩 인디케이터, 에러 화면 등)

---

## 3. Phase 2 — Planning (plan.md 출력)

research.md 결과를 바탕으로 아래 항목을 plan.md에 작성할 것. 파일 경로, 코드 스니펫, trade-off 포함.

### 3-1. 삭제 대상 파일 목록

응원단 메뉴 관련 파일을 모두 나열하고, 삭제 순서 및 참조 정리 방법 명시.

- Screen / Controller / Repository / Model / Widget
- AppPages / AppRoutes 에서 응원단 라우트 제거
- BottomNavigationBar 에서 응원단 항목 제거

### 3-2. 직관정보 화면 구조 설계

신규 생성 파일 목록과 경로를 plan.md에 명시.

```
lib/
└── features/stadium/
    ├── binding/
    │   ├── stadium_list_binding.dart
    │   └── stadium_detail_binding.dart
    ├── controller/
    │   ├── stadium_list_controller.dart
    │   └── stadium_detail_controller.dart
    ├── repository/
    │   └── stadium_repository.dart
    ├── model/
    │   ├── stadium.dart
    │   ├── stadium_detail.dart
    │   ├── stadium_transport.dart
    │   ├── stadium_parking.dart
    │   ├── stadium_seat.dart
    │   ├── stadium_food.dart
    │   └── stadium_tip.dart
    └── view/
        ├── stadium_list_screen.dart      # 구장 목록
        ├── stadium_detail_screen.dart    # 구장 상세 (TabBar)
        └── tabs/
            ├── transport_tab.dart
            ├── parking_tab.dart
            ├── seats_tab.dart
            ├── food_tab.dart
            └── tips_tab.dart
```

### 3-3. Dio API 연동 설계

기존 프로젝트 Repository 패턴에 맞춰 작성.

```dart
class StadiumRepository {
  final Dio _dio;
  StadiumRepository(this._dio);

  Future<List<Stadium>> getStadiums() async {
    final response = await _dio.get('/api/stadiums');
    return (response.data['data'] as List)
        .map((e) => Stadium.fromJson(e))
        .toList();
  }

  Future<StadiumDetail> getStadiumDetail(int id) async {
    final response = await _dio.get('/api/stadiums/$id');
    return StadiumDetail.fromJson(response.data['data']);
  }
}
```

### 3-4. GetX Controller 설계

```dart
class StadiumListController extends GetxController {
  final StadiumRepository repository;
  StadiumListController(this.repository);

  final stadiums = <Stadium>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStadiums();
  }

  Future<void> fetchStadiums() async {
    isLoading.value = true;
    try {
      stadiums.value = await repository.getStadiums();
    } catch (e) {
      Get.snackbar('오류', '구장 정보를 불러올 수 없습니다.');
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 3-5. 네비게이션 변경 계획

- BottomNavigationBar — 선수 항목 → 직관정보로 교체 (아이콘: Icons.stadium or Icons.location_on), 응원단 항목 삭제
- AppRoutes — `/stadium-list`, `/stadium-detail` 라우트 추가, 응원단 라우트 삭제
- AppPages — StadiumListBinding, StadiumDetailBinding 등록
- 구장 상세로 이동 시 stadiumId 전달 — `Get.toNamed('/stadium-detail', arguments: stadium.id)`

### 3-6. Trade-off 검토 항목

- 구장 상세 탭 — TabBar+TabBarView vs PageView (기존 앱 패턴에 맞춤)
- 데이터 캐싱 — GetX Controller keepAlive vs 매번 API 호출 (구장 정보는 자주 안 바뀜)
- 구장 목록 UI — ListView vs GridView (2열 카드 레이아웃 고려)
- 사직구장 최상단 고정 방법 — 서버 정렬 vs 클라이언트 정렬

---

## 4. Phase 3 — Implementation

plan.md 승인 후 아래 순서로 구현할 것.

1. 응원단 메뉴 관련 파일 전체 삭제 및 참조 정리
2. AppRoutes / AppPages / BottomNavigationBar 수정
3. Stadium 모델 클래스 생성 (fromJson 포함)
4. StadiumRepository 생성 (Dio 연동)
5. Binding 클래스 2개 생성
6. Controller 2개 생성 (List / Detail)
7. StadiumListScreen 구현 (구장 목록 ListView)
8. StadiumDetailScreen 구현 (TabBar + TabBarView)
9. 탭 Widget 5개 구현 (교통/주차/좌석/맛집/꿀팁)
10. Android + iOS 에뮬레이터 동작 확인

---

## 5. 주의사항

- 응원단 관련 코드 삭제 시 참조 누락으로 빌드 오류 나지 않도록 전수 확인
- 기존 선수 메뉴 코드는 삭제 전 별도 브랜치 백업 권장
- Dio BaseUrl / Interceptor 설정 변경 금지
- 기존 앱 공통 Widget (로딩, 에러, 카드 등) 최대한 재사용
- 구장 목록은 사직구장(롯데)을 최상단 고정 표시
- TabBar 탭 순서 — 교통 / 주차 / 좌석 / 맛집 / 꿀팁 순서 고정
- iOS 빌드 확인 필수 (Podfile 의존성 이슈 주의)

---

> **Phase 1, 2 끝나고 승인 전까지 코드 작성하지 말 것.**
