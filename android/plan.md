
한 달의 목표도 다음처럼 잡는 편이 현실적입니다.

> **Compose와 기존 View 기반 화면을 모두 읽고 수정하면서, ViewModel·Flow·생명주기·데이터 계층·시스템 API를 테스트 가능한 구조로 연결하고, Telecom/Telephony 기능을 TDD로 안전하게 변경할 수 있는 상태**

2026년 8월 기준 Android 공식 아키텍처 권장안은 신규 UI에 Compose를 사용하고, 화면 수준 ViewModel, 단방향 데이터 흐름, `StateFlow`, 생명주기 인식 상태 수집, Repository와 Fake 중심 테스트를 권장합니다. 다만 기존 View 기반 앱에 Compose를 점진적으로 섞는 상호운용도 공식 지원하므로, 통신사의 대형 레거시 앱을 대비하려면 **Compose만 공부해서는 부족합니다.** 

## 권장 시간 배분

```text
사용자 화면·UX·앱 아키텍처       50%
Android 시스템·Telecom/Telephony 30%
테스트·디버깅·성능·레거시 대응    20%
```

한 달 동안 여러 개의 토이 앱을 만드는 것보다, 하나의 앱을 계속 확장하는 방식을 추천합니다.

---

# 한 달 동안 만들 프로젝트

프로젝트 이름은 임시로 **Telecom Client Lab**이라고 하겠습니다.

```text
Telecom Client Lab
├── 권한·역할 안내 화면
├── 홈 대시보드
├── SIM / Subscription 선택 화면
├── 네트워크·Telephony 상태 화면
├── 통화 내역 목록
├── 통화 상세 화면
├── 가상 수신·발신 통화 화면
├── 통화 중 화면
├── 오디오 경로 선택 화면
├── 진단 이벤트 타임라인
├── 진단 리포트 업로드
└── 설정 화면
```

실제 통화를 처음부터 구현하는 것이 아닙니다.

초반에는 `FakeCallEventSource`, `FakeTelephonyEventSource`로 통화와 네트워크 이벤트를 생성하고, 3주 차부터 공개 Android API를 연결합니다. 이 방식이면 권한이나 단말 환경 때문에 개발이 막히지 않으면서도, 실제 코드와 같은 상태 전이와 UI를 TDD로 연습할 수 있습니다.

최종 앱에는 다음을 넣습니다.

```text
UI
├── Compose 화면 7~8개
├── XML + Fragment 화면 1개
├── View 안의 ComposeView 1개
└── Compact / Expanded 적응형 화면

Data
├── Fake API
├── 실제 HTTP Client 경계
├── Room
├── DataStore
└── WorkManager

Platform
├── ConnectivityManager
├── SubscriptionManager
├── TelephonyManager
├── TelephonyCallback
├── Telecom 상태 모델
├── 오디오 경로
└── Notification / Foreground Service
```

---

# 학습 프로젝트의 권장 구조

처음부터 10개 이상의 Gradle 모듈을 만들지는 마세요. 1~3주 차에는 단일 `app` 모듈 안에서 패키지 경계를 명확히 하고, 마지막 주에 필요성이 확인된 일부만 분리합니다.

```text
app
├── feature
│   ├── dashboard
│   ├── subscription
│   ├── call
│   ├── history
│   ├── diagnosis
│   └── settings
│
├── data
│   ├── repository
│   ├── remote
│   └── local
│
├── platform
│   ├── connectivity
│   ├── telephony
│   ├── telecom
│   ├── audio
│   └── notification
│
├── domain
│   ├── call
│   ├── diagnosis
│   └── policy
│
└── core
    ├── ui
    ├── model
    └── testing
```

`domain`에는 실제로 복잡한 정책이 있는 것만 둡니다.

```text
좋은 Domain 후보
├── 통화 상태 머신
├── 품질 진단 규칙
├── 재시도 정책
├── 오디오 경로 정책
└── Subscription 전환 정책

굳이 Domain이 필요 없는 것
├── 단순 Repository 호출
├── 화면 제목 반환
├── 버튼 클릭 전달
└── 단순 데이터 매핑 한 줄
```

---

# 화면을 TDD로 만드는 기본 구조

화면은 다음 두 단계로 나누는 습관을 들이세요.

```kotlin
@Composable
fun CallRoute(
    viewModel: CallViewModel,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    CallScreen(
        uiState = uiState,
        onAction = viewModel::onAction,
    )
}

@Composable
fun CallScreen(
    uiState: CallUiState,
    onAction: (CallAction) -> Unit,
) {
    // 순수 렌더링
}
```

역할은 다음과 같습니다.

```text
CallRoute
├── ViewModel 획득
├── lifecycle-aware 상태 수집
├── navigation 연결
└── Android 의존성 연결

CallScreen
├── 전달받은 상태만 렌더링
├── 사용자 동작을 callback으로 전달
├── Preview 가능
└── Compose UI Test 가능
```

재사용 가능한 UI 컴포넌트에 ViewModel을 직접 넣지 않고 상태와 callback을 전달하는 방식이 좋습니다. 공식 아키텍처도 화면 수준에서 ViewModel을 사용하고, 재사용 컴포넌트에는 일반 상태 홀더나 hoisted state를 사용하도록 권장합니다. 

화면 하나를 만들 때 다음 순서를 반복합니다.

```text
1. 화면 상태를 먼저 열거한다
2. ViewModel 또는 Reducer 실패 테스트를 작성한다
3. 최소한의 상태 전이만 구현한다
4. Stateless Composable을 만든다
5. 각 상태의 Compose UI Test를 작성한다
6. Repository 또는 Platform Adapter를 연결한다
7. 핵심 사용자 흐름 하나만 E2E 테스트로 만든다
```

---

# 테스트 전략

테스트는 다음 네 단계로 나눕니다.

```text
1. 순수 Kotlin 로컬 테스트
   └── 상태 머신, Validator, Policy, Reducer

2. ViewModel / Repository 로컬 테스트
   └── Flow, Coroutine, Fake Repository

3. Component UI 테스트
   ├── Compose UI Test
   └── Espresso

4. 실제 기기·에뮬레이터 테스트
   ├── 권한
   ├── Activity/Service
   ├── Telephony callback
   ├── UI Automator
   └── 전체 사용자 흐름
```

기기 계측 테스트는 실제 Android 프레임워크와 높은 일치도를 제공하지만 로컬 테스트보다 느립니다. 따라서 프레임워크가 필요하지 않은 정책과 상태 전이는 JVM 테스트로 내리고, 실제 기기 동작이 필요한 부분만 계측 테스트로 남겨야 합니다. `AndroidJUnitRunner`는 JUnit 4 기반 계측 테스트에서 Compose, Espresso, UI Automator를 함께 실행할 수 있습니다. 

테스트 더블은 다음 우선순위를 권장합니다.

```text
Fake > Stub > Mock
```

Android 공식 테스트 가이드도 간단하고 동작 가능한 Fake 구현을 우선하도록 권장합니다. 

---

# 하루 공부 루틴

평일 3시간, 주말 4~5시간을 가정합니다.

```text
공식 문서·기존 코드 읽기          30분
TDD Red → Green → Refactor     90분
화면·에뮬레이터·실기기 검증         40분
adb·로그·Profiler 훈련             30분
배운 내용과 실패 원인 기록          10분
```

매일 다음 파일을 남기세요.

```text
notes/day-XX.md

- 오늘 배운 Android 개념
- 작성한 테스트
- 발생한 실패
- Spring과 달랐던 점
- 현재 코드의 안티패턴
- 내일 다시 구현할 기능
```

---

# Week 1 — Android 생명주기, Compose, 화면 아키텍처

1주 차 목표는 **Compose 문법을 많이 아는 것**이 아니라 다음 흐름에 익숙해지는 것입니다.

```text
사용자 입력
   ↓
Action
   ↓
ViewModel / Reducer
   ↓
UiState
   ↓
Compose 렌더링
```

Android는 configuration change와 시스템에 의한 process death를 고려해야 합니다. `ViewModel`, `rememberSaveable`, 영속 저장소는 각각 보존 범위가 다르며, `onDestroy()`가 항상 호출된다고 가정해서도 안 됩니다. 

## Day 1 — Android 프로젝트와 테스트 기준점

### 학습

```text
Android Studio
Gradle Kotlin DSL
app module
AndroidManifest.xml
APK / AAB
debug / release
src/main
src/test
src/androidTest
adb
logcat
```

Spring 프로젝트와 다르게 Android에서는 Gradle task와 build variant가 앱 패키징, 리소스, Manifest, 테스트 소스셋에 직접 영향을 줍니다.

### TDD 과제

첫 번째 `CallStateReducer`를 순수 Kotlin으로 만듭니다.

```text
Idle
Dialing
Ringing
Active
Holding
Disconnected
```

테스트:

```text
Idle + StartOutgoing → Dialing
Ringing + Answer → Active
Active + Hold → Holding
Holding + Resume → Active
어떤 상태 + Disconnect → Disconnected
Disconnected 이후 늦게 온 Active 이벤트 무시
```

### 완료 조건

```bash
./gradlew testDebugUnitTest
./gradlew lintDebug
./gradlew assembleDebug
```

세 명령을 실행하고 각각 무엇을 검증하는지 설명할 수 있어야 합니다.

---

## Day 2 — Activity, 화면 재생성, Process Death

### 학습

```text
Activity lifecycle
Task와 back stack
configuration change
화면 회전
다크 모드 전환
process death
ViewModel
SavedStateHandle
remember
rememberSaveable
```

### TDD 과제

`CallHistoryFilterViewModel`을 만듭니다.

```text
전체
수신
발신
부재중
```

테스트:

```text
필터 변경 시 목록 변경
동일 필터 재선택은 상태 변화 없음
SavedStateHandle로 선택 필터 복원
검색어와 필터 조합
Repository 재연결 후 상태 복원
```

### 실기기 검증

```text
화면 회전
다크 모드 변경
백그라운드 이동
Activity 재생성
프로세스 종료 후 재진입
```

### 완료 조건

다음 상태를 구분할 수 있어야 합니다.

```text
Composable 내부에만 필요한 상태
화면 수준에서 유지할 상태
프로세스 재생성 후 복원할 상태
앱 재실행 후에도 유지할 영속 상태
```

---

## Day 3 — Compose의 상태와 Recomposition

### 학습

```text
Composable
Composition
Recomposition
remember
derivedStateOf
Modifier 순서
State hoisting
Stateless / Stateful Composable
Preview
Slot API
```

### TDD 과제

`NetworkStatusCard`를 만듭니다.

```text
Loading
Available
Degraded
Unavailable
PermissionRequired
```

Compose 테스트:

```text
Available이면 네트워크 이름 표시
Degraded이면 경고 문구 표시
Unavailable이면 재시도 버튼 표시
재시도 클릭 시 onRetry 호출
PermissionRequired이면 설정 이동 버튼 표시
```

Compose UI Test는 semantics tree에서 노드를 찾고, 사용자 동작과 UI 속성을 검증합니다. 

### 완료 조건

`NetworkStatusCard`가 ViewModel, Repository, Android `Context`를 전혀 알지 않아야 합니다.

---

## Day 4 — UDF와 화면 수준 ViewModel

### 학습

```text
Unidirectional Data Flow
UiState
UiAction
ViewModel
StateFlow
Repository
Single Source of Truth
Route / Screen 분리
```

### TDD 과제

`DashboardViewModel`을 만듭니다.

```kotlin
data class DashboardUiState(
    val isLoading: Boolean,
    val subscriptions: List<SubscriptionUiModel>,
    val selectedSubscriptionId: Int?,
    val error: DashboardError?,
)
```

테스트:

```text
초기 진입 → Loading
로드 성공 → Content
로드 실패 → Error
Retry → Loading → Content
기존 데이터가 있는 상태에서 갱신 실패 → 기존 데이터 + 경고
```

### 완료 조건

다음 형태로 구성합니다.

```text
DashboardRoute
└── DashboardScreen
    ├── SubscriptionSelector
    ├── NetworkCard
    └── RecentCallList
```

`DashboardScreen`에는 ViewModel을 직접 전달하지 않습니다.

---

## Day 5 — Coroutine과 Flow 테스트

### 학습

```text
viewModelScope
Flow
StateFlow
SharedFlow의 용도
combine
mapLatest
flatMapLatest
distinctUntilChanged
debounce
cancellation
Dispatcher
runTest
TestDispatcher
가상 시간
```

`runTest`와 `TestDispatcher`를 사용하면 실제 시간을 기다리지 않고 지연, 재시도, 취소를 테스트할 수 있습니다. 테스트에서 사용되는 Dispatcher들은 동일한 테스트 스케줄러를 공유하도록 만드는 것이 중요합니다. 

### TDD 과제

`ContactSearchViewModel`을 만듭니다.

테스트:

```text
검색어 입력 후 300ms 전에는 검색하지 않음
300ms가 지나면 검색
검색어가 바뀌면 이전 검색 취소
동일 검색어는 중복 호출하지 않음
화면 종료 시 진행 중 검색 취소
검색 실패 후 Retry
```

### 안티패턴

```kotlin
delay(300)
Thread.sleep(500)
```

을 테스트 안에 넣고 실제로 기다리는 방식입니다.

### 완료 조건

모든 시간 관련 테스트가 1초 미만에 끝나야 합니다.

---

## Day 6 — Material 3와 작은 디자인 시스템

### 학습

```text
MaterialTheme
ColorScheme
Typography
Shape
Spacing
Dark theme
Dynamic color
Scaffold
TopAppBar
NavigationBar
Button
Card
Dialog
Snackbar
```

Compose의 Material 3 구현은 색상, Typography, Shape를 테마의 주요 하위 시스템으로 제공합니다. 

### TDD 과제

통화 제어 컴포넌트를 만듭니다.

```text
MuteButton
SpeakerButton
KeypadButton
HoldButton
EndCallButton
```

각 컴포넌트 상태:

```text
enabled
disabled
selected
loading
error
```

테스트:

```text
Mute 상태면 선택됨 semantics 제공
통화 연결 전 Hold 비활성화
오디오 변경 중 Speaker 버튼 로딩
EndCall은 접근 가능한 label 제공
```

### 완료 조건

화면마다 색상과 padding을 직접 하드코딩하지 않고, 작은 design token을 통해 관리합니다.

---

## Day 7 — View, Fragment, XML과 Compose 상호운용

통신사 앱은 오래된 View 기반 코드가 많을 가능성이 높으므로 반드시 익혀야 합니다.

### 학습

```text
Activity
Fragment
Fragment view lifecycle
XML layout
ViewBinding
RecyclerView
Adapter
DiffUtil
ComposeView
AndroidView
AndroidViewBinding
Espresso
```

기존 View 앱 안에는 `ComposeView`를 넣을 수 있고, 반대로 Compose 안에서 `AndroidView` 또는 `AndroidViewBinding`으로 기존 View를 사용할 수 있습니다. Fragment 안의 `ComposeView`는 Fragment view lifecycle에 맞는 composition disposal 전략이 중요합니다. 

### TDD 과제

Day 3의 `NetworkStatusCard`를 다음 두 방식으로 사용합니다.

```text
1. Compose 화면에서 직접 사용
2. XML Fragment의 ComposeView 안에서 사용
```

그리고 XML 버튼 하나를 Espresso로 테스트합니다. Espresso는 View 기반 UI가 idle 상태가 될 때까지 동기화한 뒤 동작과 검증을 수행합니다. 

### 완료 조건

다음을 설명할 수 있어야 합니다.

```text
Fragment lifecycle과 Fragment view lifecycle의 차이
왜 ViewBinding을 onDestroyView에서 해제하는가
ComposeView composition이 언제 정리되는가
Compose와 View 상태를 중복 보관하면 왜 문제가 되는가
```

---

# Week 2 — 실제 사용자 클라이언트 화면 개발

2주 차에는 일반 앱 개발자가 매일 만나는 기능을 집중적으로 구현합니다.

```text
Navigation
목록
입력 폼
API
로컬 저장
접근성
다국어
태블릿·폴더블
```

---

## Day 8 — Navigation과 Back Stack

### 학습

```text
Navigation 3
Back stack
Destination
Navigation key
Deep link
화면 인자
Back 처리
상태 복원
기존 Fragment Navigation Component
```

2026년 현재 신규 Compose 앱에는 Navigation 3가 권장되며, back stack을 상태 목록으로 직접 모델링하고 적응형 레이아웃에서 여러 destination을 동시에 표시할 수 있습니다. 다만 회사 코드에서는 기존 `NavController`, Navigation Compose, Fragment Navigation을 만날 가능성이 높으므로 모두 읽을 수 있어야 합니다. 

### TDD 과제

```text
CallHistory
   ↓
CallDetail(callId)
   ↓
Diagnosis(callId)
```

테스트:

```text
목록 항목 선택 → 상세 destination 추가
뒤로 가기 → 목록 복귀
잘못된 callId → 오류 화면
Deep link로 상세 직접 진입
프로세스 재생성 후 back stack 복원
```

### 완료 조건

Composable 내부에서 `NavController`를 여러 하위 컴포넌트에 직접 전달하지 않고, `onCallSelected(id)` 같은 callback을 사용합니다.

---

## Day 9 — LazyColumn, RecyclerView, Paging

### 학습

```text
LazyColumn
LazyRow
LazyGrid
stable key
contentType
item animation
scroll state
Paging 개념
RecyclerView와 DiffUtil 비교
Loading / Empty / Error / Content
```

큰 목록은 모든 아이템을 한 번에 배치하는 `Column`보다 `LazyColumn`을 사용해야 하며, 안정적인 key와 적절한 `contentType`은 아이템 상태와 composition 재사용에 중요합니다. 성능 평가는 debug build가 아니라 최적화된 release 환경에서 해야 합니다. 

### TDD 과제

`CallHistoryReducer`를 만듭니다.

테스트:

```text
최초 페이지 로드
다음 페이지 로드
중복 callId 제거
다음 페이지 실패
Retry 후 성공
마지막 페이지 이후 추가 요청 방지
새 데이터 추가 시 기존 스크롤 상태 유지
```

### UI 테스트

```text
빈 목록 메시지
초기 로딩
목록 표시
다음 페이지 로딩
오류 행의 재시도
아이템 선택
```

---

## Day 10 — 입력 폼, Focus, IME

### 학습

```text
TextField
FocusRequester
KeyboardOptions
KeyboardActions
IME action
입력 검증
입력 포맷
에러 메시지
상태 hoisting
사용자 입력과 서버 모델 분리
```

### TDD 과제

`DialInputState`를 만듭니다.

```text
숫자 입력
공백·구분자 처리
최대 길이
빈 값
지원하지 않는 문자
붙여넣기
삭제
국가 코드 선택
```

중요한 점은 UI 표시값과 실제 서버 또는 Telecom에 전달할 값을 분리하는 것입니다.

```text
displayValue: "010-1234-5678"
rawValue:     "01012345678"
```

실제 번호 규칙은 회사 정책이나 사용하는 번호 라이브러리에 맞춰야 하며, 학습용 규칙을 실제 통신 규칙으로 간주하면 안 됩니다.

### 완료 조건

입력 검증을 Composable의 `onValueChange` 안에 모두 넣지 않고 별도 테스트 가능한 타입으로 분리합니다.

---

## Day 11 — 네트워크와 Repository

### 학습

```text
HTTP Client
DTO
Domain Model
UI Model
Repository
Error mapping
Timeout
Cancellation
Retry
Cache
Fake API
```

회사에서는 Retrofit·OkHttp, Ktor, 사내 HTTP Client 중 하나를 사용할 수 있습니다. 특정 라이브러리보다 다음 경계가 중요합니다.

```text
HTTP 오류
   ↓
DataError
   ↓
Domain 결과
   ↓
UiState
```

### TDD 과제

`CallHistoryRepository`를 만듭니다.

테스트:

```text
200 정상 응답
잘못된 JSON
401 인증 오류
429 요청 제한
500 서버 오류
Timeout
네트워크 취소
캐시가 있을 때 서버 실패
```

### 안티패턴

```text
ViewModel이 Retrofit Response를 직접 처리
Composable에서 API 호출
단위 테스트가 실제 staging 서버 호출
HTTP 상태 코드를 UI가 직접 판단
```

### 완료 조건

로컬 테스트가 인터넷 연결 없이 항상 같은 결과를 내야 합니다.

---

## Day 12 — Room, DataStore, 오프라인 상태

### 학습

```text
Room Entity
DAO
Database
Migration
Transaction
Flow query
DataStore
Single Source of Truth
offline-first 기본 개념
```

Room 자체를 검증할 때는 실제 SQLite 동작을 사용하는 테스트를 작성하고, Repository 로직만 테스트할 때는 DAO Fake를 사용할 수 있습니다. Room migration은 앱 업데이트 시 사용자 데이터 손실과 크래시를 유발할 수 있으므로 별도로 테스트해야 합니다. 

### TDD 과제

통화 내역 캐시를 만듭니다.

```text
서버 결과 저장
Room Flow 관찰
오프라인에서 캐시 표시
같은 callId 갱신
삭제된 데이터 처리
DB version 1 → version 2 migration
```

### DataStore 과제

```text
선택 Subscription ID
테마 설정
진단 자동 업로드 설정
```

### 완료 조건

UI는 서버와 DB 중 어디서 데이터가 왔는지 몰라도 됩니다.

---

## Day 13 — 접근성, 다국어, 큰 글자

### 학습

```text
Semantics
contentDescription
role
stateDescription
TalkBack
Switch Access
Touch target
Font scale
Color contrast
string resources
plural
RTL
날짜·숫자 지역화
```

접근성은 자동 테스트만으로 끝낼 수 없습니다. Compose 테스트로 semantics와 일부 접근성 문제를 자동 검증하고, TalkBack과 Switch Access를 직접 켜서 수동 검증해야 합니다. 현재 Compose 접근성 테스트는 label, 색상 대비, 작은 터치 영역, 탐색 순서 등의 문제를 일부 자동 탐지할 수 있습니다. 

### TDD 과제

통화 중 화면을 대상으로 검사합니다.

```text
Mute 버튼의 선택 상태 읽기
통화 종료 버튼의 접근성 이름
통화 시간 읽기
오디오 경로 선택 상태
비활성화된 Hold 버튼 상태
```

### 수동 검증

```text
TalkBack
글자 크기 200%
Display size 확대
한국어
영어
RTL 언어
다크 모드
```

### 완료 조건

아이콘만 있는 모든 버튼이 의미 있는 접근성 정보를 가져야 합니다.

---

## Day 14 — 태블릿, 폴더블, Multi-window

### 학습

```text
Window size class
Compact
Medium
Expanded
Multi-window
화면 회전
Foldable
List-detail layout
상태 보존
```

화면 구성을 `isTablet` 같은 기기 종류로 판단하지 말고, 현재 앱에 실제로 할당된 window 크기를 기준으로 판단해야 합니다. Window size class는 휴대폰, 태블릿, 폴더블, 멀티윈도우를 하나의 적응형 레이아웃 모델로 처리하는 데 사용됩니다. 

### TDD 과제

통화 내역을 다음처럼 구성합니다.

```text
Compact
└── 목록 또는 상세 중 하나

Expanded
├── 왼쪽: 통화 목록
└── 오른쪽: 통화 상세
```

테스트:

```text
Compact에서 항목 선택 → 상세 화면
Expanded에서 항목 선택 → 오른쪽 pane 갱신
창 크기 변경 후 선택 상태 유지
상세가 없는 Expanded 상태 처리
```

### 완료 조건

휴대폰 세로, 휴대폰 가로, 태블릿, 분할 화면에서 레이아웃이 깨지지 않아야 합니다.

---

# Week 3 — Android 시스템, Telecom, Telephony

3주 차부터 시스템 API를 본격적으로 연결합니다.

핵심 구조는 항상 같습니다.

```text
Android callback
      ↓
Platform Adapter
      ↓
앱의 Domain Event
      ↓
Reducer / ViewModel
      ↓
UiState
      ↓
화면
```

---

## Day 15 — Runtime Permission과 System Role

### 학습

```text
Manifest permission
Runtime permission
Permission rationale
권한 거부
설정에서 권한 변경
Feature detection
RoleManager
ROLE_DIALER
```

Android 권한은 기능을 실제로 사용할 때마다 다시 확인해야 하며, 권한이 거부된 경우에도 앱의 나머지 기능은 가능한 범위에서 계속 동작하도록 graceful degradation을 설계해야 합니다. 

### 권한 상태 모델

```kotlin
sealed interface PermissionUiState {
    data object Checking : PermissionUiState
    data object Granted : PermissionUiState
    data object NeedsRationale : PermissionUiState
    data object Denied : PermissionUiState
    data object NotSupported : PermissionUiState
}
```

`DeniedPermanently`를 완벽하게 판별할 수 있는 절대적인 시스템 상태처럼 모델링하지 말고, 앱이 관찰 가능한 정보와 사용자 행동을 기준으로 UI를 구성하세요.

### TDD 과제

```text
권한 있음 → 기능 화면 진입
권한 없음 → 요청 안내
rationale 필요 → 설명 화면
거부 → 제한된 기능 제공
기기 기능 없음 → 권한 요청 자체를 숨김
사용 중 권한 취소 → 기능 종료 및 상태 갱신
```

### 추가 실습

UI Automator로 시스템 권한 팝업을 조작합니다. UI Automator는 앱 프로세스 밖에서 시스템 UI와 다른 앱의 화면까지 테스트할 수 있습니다. 

---

## Day 16 — Service, Foreground Service, WorkManager

### 학습

```text
Service
Started service
Bound service
Foreground service
Notification
BroadcastReceiver
WorkManager
Process 종료
Background 제한
```

Foreground Service는 사용자가 인지할 수 있는 지속 작업에만 사용해야 하고, 상태 표시 Notification을 제공해야 합니다. 연기 가능한 영속 작업은 WorkManager가 더 적합합니다. 백그라운드에서 Foreground Service를 시작하는 동작에는 Android 버전에 따른 제한도 있습니다. 

### TDD 과제

`DiagnosticSessionController`를 만듭니다.

```text
세션 시작
세션 중지
중복 시작
세션 실행 시간
Notification action으로 종료
프로세스 재생성 후 상태 복원
```

`ReportUploadWorker` 테스트:

```text
성공 → Result.success
일시적 네트워크 실패 → Result.retry
인증 실패 → Result.failure
동일 리포트 중복 업로드 방지
```

### 완료 조건

다음을 구분할 수 있어야 합니다.

```text
화면이 보이는 동안만 필요한 작업
사용자가 인지하는 지속 작업
나중에 실행되어도 되는 영속 작업
정확한 시점이 필요한 작업
```

---

## Day 17 — ConnectivityManager와 네트워크 화면

### 학습

```text
ConnectivityManager
Network
NetworkCapabilities
LinkProperties
NetworkCallback
Wi-Fi
Cellular
Metered
Validated
Captive portal
Default network 전환
```

연결 상태는 polling하지 않고 `NetworkCallback`으로 관찰하는 것이 좋습니다. 또한 동일한 네트워크에 다시 연결되더라도 새로운 `Network` 객체가 생성될 수 있으므로 객체 수명과 callback 순서를 고려해야 합니다. 

### Adapter

```kotlin
interface ConnectivityEventSource {
    fun events(): Flow<ConnectivityEvent>
}
```

### TDD 과제

```text
네트워크 없음
Wi-Fi 연결
Cellular 연결
Wi-Fi → Cellular 전환
인터넷 기능은 있으나 검증되지 않음
Metered 네트워크
onLost 이후 늦은 capabilities 이벤트
동일 이벤트 중복
```

### 화면

```text
연결 유형
Validated 여부
Metered 여부
현재 진단 상태
최근 변경 시각
```

### 완료 조건

ViewModel이 `Network`, `NetworkCapabilities` 타입을 직접 노출하지 않아야 합니다.

---

## Day 18 — Subscription과 TelephonyCallback

### 학습

```text
TelephonyManager
SubscriptionManager
SubscriptionInfo
subscriptionId
SIM slot
멀티 SIM
createForSubscriptionId
TelephonyCallback
ServiceState
SignalStrength
TelephonyDisplayInfo
권한
API 버전 분기
```

`TelephonyCallback`은 서비스 상태, 신호 강도, 통화 상태, 데이터 연결 등 여러 Telephony 상태 변화를 관찰할 수 있으며, 일부 정보는 권한으로 보호됩니다. 

### 가장 중요한 구분

```text
SIM slot index ≠ subscriptionId
```

Subscription은 변경되거나 사라질 수 있으므로 상수처럼 보관하면 안 됩니다.

### TDD 과제

`SubscriptionSession`을 만듭니다.

```text
Subscription 선택
선택된 Subscription의 callback 등록
Subscription 변경 시 기존 callback 해제
같은 Subscription 재선택 시 중복 등록 방지
Subscription 제거 시 Unavailable
두 SIM의 이벤트가 섞이지 않음
오래된 Subscription 이벤트 무시
권한 취소 시 callback 정리
```

### 화면

```text
SIM 이름
Subscription ID
서비스 상태
네트워크 표시 타입
신호 단계
로밍 여부
최근 변경 시각
```

실제 필드 접근 가능 여부는 앱의 권한과 시스템 앱 여부에 따라 달라집니다.

---

## Day 19 — Telecom, InCallService, ConnectionService

### 학습

```text
TelecomManager
Telecom
Call
Call.Callback
InCallService
Connection
ConnectionService
PhoneAccount
RoleManager.ROLE_DIALER
```

Telecom은 SIM 기반 통화와 VoIP 통화를 조정하는 중앙 switchboard입니다. `ConnectionService`는 통화를 제공하는 쪽이고, `InCallService`는 Telecom이 관리하는 통화를 표시하고 제어하는 사용자 인터페이스 쪽입니다. 기본 전화 앱이 되려면 `ROLE_DIALER`를 요청하고 발신 UI, 수신 UI, 통화 중 UI를 포함한 `InCallService` 요구사항을 충족해야 합니다. 

### TDD 과제

Day 1의 통화 상태 머신을 다시 구현합니다.

이번에는 실제에 가까운 이벤트를 추가합니다.

```text
CallAdded
StateChanged
DetailsChanged
ParentChanged
ChildrenChanged
CallRemoved
EndpointChanged
DisconnectCauseChanged
```

테스트:

```text
수신 통화 추가 → Incoming
사용자 응답 → Active
통화 보류 → Holding
두 번째 통화 수신
통화 전환
Conference 생성
Disconnect 후 늦은 Active 무시
CallRemoved 후 callback 이벤트 무시
```

### 구현 전략

```text
1단계: Fake Telecom 이벤트
2단계: Call.Callback Adapter
3단계: InCallService skeleton
```

처음부터 실제 기본 전화 앱 전체를 만들려고 하지 마세요.

---

## Day 20 — 실제 통화 중 화면 설계

### 화면 구성

```text
상대방 정보
통화 상태
통화 시간
Mute
Keypad
Speaker / Audio route
Hold
Add call
Swap
Merge conference
End call
오류 및 재연결 상태
```

### UI State

```kotlin
data class InCallUiState(
    val callerName: String,
    val phase: CallPhase,
    val elapsedTime: Duration,
    val isMuted: Boolean,
    val isOnHold: Boolean,
    val availableActions: Set<CallActionType>,
    val audioRoute: AudioRoute,
    val error: CallError?,
)
```

### TDD 과제

```text
Ringing에서는 Answer / Reject 표시
Active에서는 Mute / Hold / Keypad 표시
Holding에서는 Resume 표시
Disconnected에서는 제어 버튼 비활성화
통화 종료 직후 timer 중지
두 통화가 있으면 Swap 표시
합칠 수 있을 때만 Merge 표시
기능을 지원하지 않는 통화에서 Video 버튼 숨김
```

### Compose UI 테스트

```text
상태별 버튼 노출
비활성 상태
접근성 label
버튼 클릭 callback
오류 메시지
가로·세로 모드
큰 글자
```

### 완료 조건

UI에서 `Call` 객체의 메서드를 직접 호출하지 않고 `CallAction`을 ViewModel 또는 Controller에 전달합니다.

---

## Day 21 — 오디오 경로와 Bluetooth

### 학습

```text
Earpiece
Speaker
Wired headset
Bluetooth
Mute
CallEndpoint
CallAudioState
AudioManager
AudioDeviceInfo
통화 오디오 경로 변경
기기 연결·해제
```

최근 Telecom API에서는 `CallEndpoint`와 `requestCallEndpointChange()`를 사용해 통화 오디오 경로를 다룰 수 있습니다. 이전 API를 사용하는 코드에서는 `CallAudioState`와 기존 route API를 볼 수 있습니다. Telecom이 아닌 자체 관리 VoIP 오디오에서는 `AudioManager.setCommunicationDevice()` 계열을 사용할 수 있습니다. 어떤 API가 맞는지는 앱이 Telecom 관리 통화인지, 자체 VoIP 통화인지에 따라 달라집니다. 

### TDD 과제

`AudioRoutePolicy`를 만듭니다.

```text
기본 통화 → Earpiece
Speaker 선택 → Speaker
Bluetooth 연결 → 선택 가능 목록에 추가
현재 Bluetooth 해제 → Earpiece fallback
Wired headset 연결
사용자 선택 요청 중 endpoint 사라짐
route 변경 요청 실패
통화 종료 후 route event 무시
```

### 상태

```text
Current
Available
Requested
Changing
Failed
```

요청이 성공했다고 즉시 화면 상태를 확정하지 말고, 실제 endpoint 변경 callback을 받은 후 확정하는 구조를 연습하세요.

### 실기기 검증

```text
스피커
유선 이어폰
Bluetooth
Bluetooth 연결 해제
화면 잠금
앱 background
```

---

# Week 4 — 시스템 심화, 레거시 수정, 성능, 통합 프로젝트

---

## Day 22 — Binder, AIDL, IMS, RIL 읽기

### 학습

```text
Process
Binder
AIDL
Proxy
Binder thread
synchronous call
oneway call
process death
DeathRecipient
System service
IMS
RIL
Radio HAL
Modem
```

Binder는 다른 프로세스의 메서드를 로컬 메서드처럼 호출할 수 있게 하는 Android의 핵심 IPC입니다. 호출은 proxy, Binder driver, 상대 프로세스의 Binder thread를 거쳐 실행됩니다. 새로운 HAL 구현에서는 HIDL보다 AIDL이 권장됩니다. 

통신 경로를 다음처럼 그려보세요.

```text
사용자 화면
   ↓
InCallService / Telecom
   ↓
Telephony Framework
   ↓
IMS / Telephony ConnectionService
   ↓
RIL
   ↓
Radio HAL
   ↓
Vendor / Modem
```

`ImsService`는 플랫폼과 이동통신사 또는 vendor IMS 구현 사이의 System API이며 일반 다운로드 앱이 임의로 구현하는 서비스가 아닙니다. RIL은 Telephony Framework와 vendor radio 구현 사이에서 요청·응답·비동기 indication을 다룹니다. 

### 실습

별도 프로세스에 Fake Radio Service를 만듭니다.

```xml
<service
    android:name=".FakeRadioService"
    android:process=":radio" />
```

테스트:

```text
서비스 연결
명령 전달
callback 수신
원격 프로세스 종료
연결 끊김 상태
재연결
중복 callback
```

### 완료 조건

다음을 설명할 수 있어야 합니다.

```text
왜 Binder 호출을 main thread에서 오래 기다리면 위험한가
왜 원격 프로세스는 언제든 종료될 수 있는가
왜 IPC 모델을 Domain에 그대로 노출하면 안 되는가
```

---

## Day 23 — Capstone 1: 권한 → 대시보드 Vertical Slice

먼저 acceptance test를 씁니다.

```text
권한이 있으면 대시보드 표시
권한이 없으면 안내 화면 표시
지원하지 않는 단말이면 제한된 화면 표시
Subscription을 선택하면 해당 상태 표시
Retry 시 다시 로드
```

구현 순서:

```text
PermissionUiState
    ↓
PermissionViewModel
    ↓
PermissionScreen
    ↓
DashboardViewModel
    ↓
DashboardScreen
    ↓
FakeTelephonyEventSource
```

### 완료 조건

다음 사용자 흐름이 동작해야 합니다.

```text
앱 실행
→ 권한 안내
→ 대시보드
→ Subscription 선택
→ 네트워크 상태 표시
```

---

## Day 24 — Capstone 2: 통화 내역과 오프라인

Acceptance test:

```text
앱 실행 시 Room 캐시 우선 표시
서버 갱신 성공 시 목록 업데이트
서버 실패 시 기존 목록 유지
항목 선택 시 상세 표시
오프라인에서 상세 열기 가능
리포트 업로드는 WorkManager에 예약
```

구현:

```text
CallHistoryRepository
Room DAO
Fake RemoteDataSource
CallHistoryViewModel
CallHistoryScreen
CallDetailScreen
ReportUploadWorker
```

### 완료 조건

```text
Compact: 목록 → 상세
Expanded: 목록 + 상세
오프라인: 캐시 표시
서버 오류: 재시도
```

---

## Day 25 — Capstone 3: 통화 UI와 Telecom 이벤트

Acceptance test:

```text
수신 이벤트 → 수신 화면
Answer → 통화 중 화면
Mute → 선택 상태 표시
Audio route 변경 → 화면 업데이트
Hold → Holding 표시
Disconnect → 종료 화면
```

구현:

```text
FakeCallEventSource
CallReducer
CallSessionController
InCallViewModel
IncomingCallScreen
InCallScreen
AudioRouteSheet
```

### 실패 시나리오 추가

```text
Answer 직전 Disconnect
Active가 두 번 도착
Disconnect 이후 Hold callback
Bluetooth 선택 중 연결 해제
두 번째 통화가 동시에 추가
화면 재생성 중 Call 상태 변경
```

### 완료 조건

정상 흐름뿐 아니라 늦은 이벤트, 중복 이벤트, 역순 이벤트가 테스트되어야 합니다.

---

## Day 26 — 레거시 코드에 Characterization Test 추가

일부러 다음과 같은 클래스를 만듭니다.

```text
CallActivity
├── TelephonyManager
├── TelecomManager
├── Repository
├── Room
├── Timer
├── MutableStateFlow
├── Notification
├── 모든 UI 상태
└── 모든 비즈니스 로직
```

바로 전체 리팩터링하지 마세요.

### 작업 순서

```text
1. 현재 동작을 characterization test로 고정
2. 수정할 동작 하나를 선택
3. system dependency 하나에 seam 생성
4. 실패 테스트 추가
5. 최소 변경
6. 기존 테스트 확인
7. 작은 리팩터링
```

### TDD 과제

버그를 하나 넣습니다.

```text
통화 종료 후 timer가 계속 증가
```

처리:

```text
현재 동작 재현
→ 실패 테스트
→ timer 경계 추출
→ FakeClock 주입
→ 최소 수정
→ 회귀 테스트
```

### 완료 조건

“구조가 나쁘다”는 이유만으로 대규모 재작성을 하지 않고, 테스트를 추가하면서 점진적으로 경계를 만들 수 있어야 합니다.

---

## Day 27 — Process Death와 Resource Cleanup

### 학습

```text
화면 회전
Activity recreation
Process recreation
Background / Foreground
callback 등록·해제
Flow collector 중복
Service 재연결
상태 복원
리소스 정리
```

### 테스트

```text
ActivityScenario.recreate 후 상태 유지
화면 재진입 시 collector 중복 없음
Subscription 변경 시 이전 callback 해제
통화 종료 시 timer 취소
화면 종료 시 UI observation 취소
프로세스 재생성 후 Repository에서 상태 복원
Service 재연결
```

### 수동 검증

```text
Developer options의 Don't keep activities
adb를 이용한 프로세스 종료
화면 회전 반복
앱 background / foreground 반복
권한 설정 변경
```

### 완료 조건

다음 자원이 정상적으로 정리되는지 로그로 확인합니다.

```text
TelephonyCallback
NetworkCallback
Call.Callback
Coroutine Job
BroadcastReceiver
Audio listener
Service connection
```

---

## Day 28 — 성능, Jank, 메모리, ANR

### 학습

```text
Android Studio Profiler
Memory heap
Allocation
CPU trace
System trace
Perfetto
Recomposition
Jank
ANR
Macrobenchmark
Baseline Profile
```

성능은 debug build만 보고 판단하면 안 됩니다. Android Studio는 release 기반 profileable 앱을 통한 저오버헤드 프로파일링을 지원하며, Macrobenchmark는 앱 시작과 스크롤 같은 실제 사용자 흐름의 성능을 측정하는 데 사용됩니다. 시스템 트레이스는 앱, `system_server`, Binder, 하드웨어 활동을 시간순으로 함께 분석할 수 있습니다. 

### 측정 대상

```text
Cold start
Dashboard 첫 렌더링
통화 내역 1,000개 스크롤
통화 화면 진입
오디오 경로 BottomSheet 열기
진단 타임라인 갱신
```

### 일부러 만들 성능 문제

```text
LazyColumn에 stable key 없음
Composable 안에서 큰 목록 정렬
매 recomposition마다 날짜 formatter 생성
main thread에서 DB 읽기
main thread에서 동기 Binder 호출
불필요한 전체 목록 복사
```

ANR은 main thread가 입력이나 화면 갱신을 적시에 처리하지 못할 때 발생하며, 느린 I/O, 긴 계산, lock 경합, 느린 동기 Binder 호출 등이 대표적인 조사 대상입니다. 

### 완료 조건

문제를 감으로 수정하지 않고 다음 증거 중 하나를 남깁니다.

```text
CPU trace
System trace
Heap dump
Allocation 기록
Macrobenchmark 결과
Recomposition 정보
```

---

## Day 29 — 테스트 전략과 CI

### 테스트 분류

```text
PR마다
├── lint
├── 순수 Kotlin 테스트
├── ViewModel 테스트
├── Repository 테스트
└── debug build

main 브랜치
├── PR 테스트 전체
├── Compose UI smoke
├── Espresso smoke
└── 대표 에뮬레이터 계측 테스트

Nightly
├── 전체 계측 테스트
├── 여러 API 환경
├── UI Automator
├── process recreation
└── 성능 benchmark

Release 전
├── 실제 단말
├── Bluetooth
├── 멀티 SIM
├── 전화 역할
├── 접근성
└── adaptive layout
```

### 대표 Smoke Flow

```text
앱 실행
→ 권한 상태 확인
→ 대시보드
→ Subscription 선택
→ 통화 내역
→ 통화 상세
→ 가상 수신 통화
→ Answer
→ Mute
→ 오디오 경로 변경
→ End
```

### Hilt

Hilt를 사용한다면 로컬 단위 테스트에서는 Hilt 컨테이너를 띄우지 않고 생성자로 Fake를 직접 전달합니다. 계측 테스트에서는 `@TestInstallIn` 등을 사용해 실제 binding을 Fake로 교체할 수 있습니다. 

### 완료 조건

CI 실패 시 다음 결과물을 보존합니다.

```text
JUnit report
계측 테스트 결과
스크린샷
logcat
실패 기기 정보
benchmark 결과
```

---

## Day 30 — 모의 장애 대응과 PR

다음 버그 중 하나를 선택합니다.

```text
통화가 종료됐는데 화면은 Active
Bluetooth 연결 해제 후 Speaker로 잘못 전환
Subscription 변경 후 이전 SIM 상태가 표시됨
화면 회전 후 callback이 두 번 등록됨
통화 내역 pagination 중복 발생
권한 취소 후 앱 크래시
큰 글자에서 종료 버튼이 화면 밖으로 밀림
```

### 처리 순서

```text
1. 재현 절차 작성
2. 로그와 상태 타임라인 수집
3. 실패 테스트 작성
4. 원인 가설 작성
5. 최소 수정
6. 단위 테스트
7. UI 테스트
8. 실제 기기 검증
9. 성능·접근성 회귀 확인
```

### 모의 PR 내용

```text
문제
재현 조건
근본 원인
변경 내용
추가한 테스트
수동 검증
호환성 영향
남은 위험
롤백 방법
```

### 최종 재구현

마지막으로 코드를 보지 않고 3시간 안에 다음을 다시 만듭니다.

```text
CallReducer
FakeCallEventSource
InCallViewModel
InCallScreen
Compose UI Test 3개
ViewModel Test 5개
```

---

# 한 달 동안 반복할 TDD 과제

각 기능을 한 번만 구현하지 말고 세 번 반복하세요.

```text
1회차: 순수 Kotlin
2회차: ViewModel + Compose 연결
3회차: 나쁜 레거시 코드에 테스트를 추가하며 추출
```

| 과제 | 1회차 | 2회차 | 3회차 |
|---|---|---|---|
| 화면 상태 | Loading/Content/Error | Retry/Refresh | stale data |
| 입력 검증 | 기본 번호 입력 | 국가 코드·포맷 | 붙여넣기·복원 |
| 검색 | 즉시 검색 | debounce | 취소·역순 응답 |
| Pagination | 다음 페이지 | 중복 제거 | 실패·재시도 |
| Permission | 허용·거부 | rationale | 사용 중 취소 |
| Callback 수명 | 등록·해제 | 중복 등록 | 소유자 교체 |
| Subscription | 단일 SIM | 멀티 SIM | 제거·재활성화 |
| Call 상태 | 정상 통화 | Hold·두 통화 | 역순·중복 이벤트 |
| Audio route | Speaker | Bluetooth | endpoint 소실 |
| Navigation | 목록·상세 | deep link | 상태 복원 |
| Process 복원 | 회전 | Activity recreate | process death |
| Upload | 성공·실패 | retry | idempotency |
| Adaptive UI | compact | expanded | 크기 변경 |
| Legacy 변경 | 현재 동작 고정 | seam 추출 | 점진 리팩터링 |

---

# 화면 개발에서 반드시 피해야 할 안티패턴

| 안티패턴 | 문제 | 대안 |
|---|---|---|
| Composable에서 API 호출 | 재구성과 side effect가 섞임 | ViewModel/Repository에 위임 |
| Composable에서 시스템 callback 등록 | 수명과 해제가 불명확 | Adapter + lifecycle 경계 |
| ViewModel이 Activity를 참조 | 테스트와 수명 관리 어려움 | callback 또는 별도 Adapter |
| ViewModel이 `Context`에 강하게 의존 | Android 의존성이 전파됨 | 필요한 기능을 인터페이스로 주입 |
| 거대한 `UiState`를 무분별하게 공유 | 모든 화면이 함께 갱신 | 화면 단위 상태 분리 |
| MutableList를 UiState에 노출 | 변경 추적이 어려움 | immutable collection |
| 모든 상태를 ViewModel에 저장 | 단순 UI 상태까지 과도하게 승격 | 필요한 가장 가까운 위치에 유지 |
| 중요한 상태를 `remember`에만 저장 | 화면 재생성 시 유실 | ViewModel, SavedState, 저장소 구분 |
| `LaunchedEffect`마다 무조건 API 요청 | 재진입·key 변경 시 중복 | 명확한 이벤트와 idempotency |
| `GlobalScope` | 취소와 소유권 없음 | lifecycle-aware scope |
| `Dispatchers.IO` 하드코딩 | 테스트 제어 어려움 | Dispatcher 또는 실행 정책 주입 |
| `Thread.sleep()` 테스트 | 느리고 flaky | `runTest`와 가상 시간 |
| Mock 호출 횟수만 검증 | 구현 변경에 취약 | 상태와 사용자 결과 검증 |
| 모든 테스트를 UI 테스트로 작성 | 느리고 실패 원인 불명확 | 상태 머신·ViewModel 테스트 중심 |
| 단위 테스트에서 실제 서버 사용 | 외부 상태에 따라 실패 | Fake 또는 로컬 stub |
| `subscriptionId`를 고정 | SIM 변경에 취약 | 동적 관찰 |
| SIM slot과 Subscription ID 혼동 | 잘못된 SIM 상태 표시 | 명시적 ID 모델 |
| callback 등록 후 해제 누락 | 메모리·중복 이벤트 | 등록과 해제를 같은 객체가 소유 |
| 연결 상태 polling | 느리고 배터리 소모 | `NetworkCallback` |
| Foreground Service 남용 | 정책·배터리 문제 | WorkManager 등 적합한 도구 |
| hidden API reflection | 버전 변화·정책에 취약 | 공개 API 또는 승인된 System API |
| 처음부터 과도한 multi-module | 학습보다 구조 작업 증가 | 패키지 경계 후 필요할 때 분리 |
| 레거시 전체 재작성 | 숨은 동작과 회귀 위험 | characterization test 후 점진 변경 |

---

# 입사 전에 확인하면 학습 효율이 크게 달라지는 정보

```text
Compose / XML View 비율
Activity / Fragment 구조
Navigation 3 / Navigation Compose / Fragment Navigation
MVI / MVVM / 자체 아키텍처
Coroutines / RxJava
Hilt / Dagger / 수동 DI
Room / 다른 DB
Retrofit / 사내 HTTP Client
일반 앱 / 기본 전화 앱 / priv-app / system app
Telecom / Telephony / IMS 중 담당 범위
멀티 SIM 지원 여부
최소·대상 Android 버전
Gradle / Soong
JUnit / Robolectric / Instrumentation / atest
테스트 단말과 SIM
대표 장애 사례
통화 상태 정의서
오디오 경로 정책
```

특히 다음 세 가지는 중요합니다.

```text
1. 앱이 실제 기본 전화 앱인가?
2. 시스템 또는 privileged 권한을 갖는가?
3. 통화 엔진을 앱이 소유하는가, Telecom이 관리하는가?
```

이 답에 따라 오디오, 권한, `InCallService`, `ConnectionService`, IMS 학습 우선순위가 크게 달라집니다.

---

# 시간이 부족할 때 우선순위

## P0 — 반드시

```text
Activity / Process lifecycle
Compose state와 recomposition
ViewModel + StateFlow
Coroutine cancellation과 테스트
Route / Screen 분리
Compose UI Test
Fragment / XML / Espresso 읽기
Navigation과 back stack
Repository + Fake
권한
Connectivity callback
Subscription / TelephonyCallback
Telecom 상태 모델
통화 중 UI
오디오 경로
adb / logcat
characterization test
```

## P1 — 중요

```text
Room
DataStore
WorkManager
Foreground Service
접근성
태블릿·폴더블
Hilt
Binder / AIDL
Profiler / Perfetto
Macrobenchmark
```

## 한 달 동안 후순위

```text
복잡한 Compose animation
Custom Layout 직접 구현
고급 Canvas
고급 그래픽
과도한 multi-module
Clean Architecture 형식 논쟁
모뎀·codec 직접 구현
AOSP 전체 빌드
모든 Android API 훑기
```

---

# 한 달 후 성공 기준

다음 항목을 대부분 수행할 수 있으면 준비가 잘 된 상태입니다.

```text
Compose 화면을 상태 기반으로 구현한다
기존 Fragment/XML 화면을 읽고 수정한다
View와 Compose를 한 화면에서 함께 사용할 수 있다
ViewModel과 Stateless UI를 분리한다
Flow와 Coroutine을 가상 시간으로 테스트한다
화면 회전과 process recreation을 처리한다
Navigation back stack을 설명한다
목록·폼·오류·빈 화면을 제품 수준으로 구현한다
접근성과 큰 글자를 테스트한다
휴대폰·태블릿 레이아웃을 분리한다
Android callback을 Flow 이벤트로 감싼다
Subscription 전환 시 callback을 안전하게 교체한다
Telecom과 Telephony 차이를 설명한다
InCallService와 ConnectionService 차이를 설명한다
통화 상태 머신을 TDD로 구현한다
오디오 endpoint 변경 실패를 처리한다
Binder와 원격 프로세스 종료를 설명한다
레거시 코드에 characterization test를 추가한다
Profiler와 Perfetto로 문제의 근거를 찾는다
작은 변경을 테스트와 함께 PR로 정리한다
```

가장 중요한 반복 단위는 다음입니다.

```text
화면 상태 정의
→ 실패 테스트
→ ViewModel 상태 전이
→ Stateless UI
→ Compose UI Test
→ Android Adapter 연결
→ 실제 기기 검증
```

이 흐름을 `대시보드`, `통화 내역`, `권한`, `Subscription`, `통화 중 화면`, `오디오 경로`에 반복 적용하면, 입사 후 처음 보는 API나 레거시 화면도 동일한 방식으로 분해해서 접근할 수 있습니다.