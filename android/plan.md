# 패스투프로덕션 안드로이드 30일 학습 계획

이 계획의 목표는 토이 앱을 빠르게 만드는 것이 아니다. 화면 회전, 시스템에 의한 process death, 네트워크 단절, 백그라운드 전환, 멀티 SIM, Telecom callback, 중복·역순·지연 이벤트를 견디는 상태 관리 구조를 직접 설계하고 테스트하는 것이다.

한 달 뒤에는 패턴 이름을 암기하는 수준이 아니라 다음 질문에 근거를 들어 답할 수 있어야 한다.

```text
이 상태는 누가 소유해야 하는가?
얼마나 오래 살아야 하는가?
어디가 source of truth인가?
중복되거나 순서가 뒤바뀐 이벤트를 어떻게 처리하는가?
프로세스가 사라진 뒤 무엇으로 복구하는가?
Android API를 Fake로 교체할 수 있는가?
어떤 테스트가 이 설계를 증명하는가?
```

## 한 달 동안 동시에 훈련할 네 축

```text
1. Android UI 개발
   Compose + View/Fragment + Navigation + Adaptive UI

2. 상태 관리
   UDF + MVVM + StateFlow + State Holder
   + 필요한 곳에만 Reducer/MVI/State Machine

3. 설계와 디자인 패턴
   Repository / Adapter / State / Strategy / Observer
   Facade / Decorator / Factory(DI) / Mapper / Coordinator

4. Android와 Telecom
   Permission / Service / Connectivity / Telephony
   Telecom / Audio / Binder / Process lifecycle
```

## 기준 아키텍처

새 앱 전체를 MVI나 형식적인 Clean Architecture로 덮지 않는다. 기본 화면에는 MVVM과 UDF를 사용하고, 이벤트 순서가 복잡한 영역에만 Reducer나 State Machine을 도입한다. Domain 레이어도 복잡한 정책이 있거나 여러 ViewModel에서 재사용될 때만 둔다.

```text
                     사용자 동작
                         │
                         ▼
┌─────────────────────────────────────────────┐
│ UI                                          │
│ Compose / Fragment                          │
│                                             │
│ Stateless Screen                            │
│           ▲                                 │
│           │ UiState                         │
│           │                                 │
│ ViewModel / Screen State Holder             │
└───────────────────┬─────────────────────────┘
                    │
              suspend / Flow
                    │
           ┌────────▼────────┐
           │ Domain          │  필요할 때만
           │ UseCase         │
           │ Policy          │
           │ Reducer         │
           └────────┬────────┘
                    │
            ┌───────▼────────┐
            │ Repository     │
            │ SSOT           │
            └───────┬────────┘
                    │
       ┌────────────┼──────────────┐
       ▼            ▼              ▼
     Room        Remote API    Platform Adapter
                                 │
                         ┌───────┼────────┐
                         ▼       ▼        ▼
                    Telephony  Telecom   Audio
```

Android 공식 권장안도 UI와 Data 레이어 분리, UDF, Repository, 화면 수준 ViewModel, coroutine과 Flow를 중심으로 설명하고 Domain 레이어는 선택 사항으로 둔다. 상세 근거는 문서 끝의 공식 자료에서 확인한다.

## 프로덕션 상태 소유권 표

상태 저장 위치는 단순히 누가 사용하느냐가 아니라 필요한 수명과 복구 조건으로 결정한다.

| 상태 | 예 | 기본 소유자·저장소 | 확인할 실패 조건 |
|---|---|---|---|
| 단순 UI 요소 | Dialog 열림, 탭 선택 | `remember` | recomposition |
| 복원할 UI 요소 | 입력값, 펼침, 스크롤 | `rememberSaveable` | Activity 재생성, 시스템 process death |
| 화면 비즈니스 상태 | 통화 내역, 검색 결과 | `ViewModel + StateFlow` | configuration change, 화면 이탈 |
| 복원에 필요한 최소 입력 | `callId`, filter, query | `SavedStateHandle` | 시스템 process death |
| 여러 화면의 앱 데이터 | 선택 Subscription, 사용자 세션 | Repository 또는 app-scoped state | 화면 교체, 프로세스 재동기화 |
| 진행 중 통화 | Call session | `CallSessionController`/Repository | 화면 제거, callback 재연결 |
| 영속 데이터 | 통화 내역, 진단 결과 | Room | 앱 재시작, 오프라인 |
| 사용자 설정 | 테마, 기본 옵션 | DataStore | 앱 재시작 |
| 지속해야 하는 작업 | 리포트 업로드 | WorkManager + DB | 앱 종료, 재부팅, 중복 enqueue |
| 화면 이동 | back stack | Navigation layer | deep link, 복원, adaptive layout |
| Android callback | Telephony/Connectivity callback | Platform Adapter → Flow | 등록 해제, 중복, 늦은 callback |

`rememberSaveable`과 `SavedStateHandle`은 Bundle 기반이므로 큰 객체나 전체 화면 데이터를 넣지 않는다. 복원에 필요한 ID·검색어·필터 같은 작은 상태만 저장하고, 큰 데이터는 Repository와 영속 저장소에서 다시 만든다.

`CallSessionController`도 Android 프로세스 안에 있는 객체라 process death 자체를 생존하지는 못한다. 재생성될 때 Telecom 같은 시스템 source of truth와 다시 동기화해 현재 통화 세션을 복구해야 한다.

## 기본 상태 흐름과 선택 기준

일반적인 CRUD, 목록, 설정, 검색 화면은 다음 흐름으로 충분하다.

```text
UI Action
   ↓
ViewModel
   ↓
Repository / 선택적 UseCase
   ↓ Result / Flow
ViewModel
   ↓ UiState
UI
```

화면에서는 `StateFlow`를 `collectAsStateWithLifecycle()`로 수집한다. 재사용 가능한 Composable에는 ViewModel을 전달하지 않고 상태와 callback을 전달한다.

통화 중 화면처럼 외부 이벤트가 많고 순서가 상태를 바꾸는 영역은 다음 흐름을 사용한다.

```text
현재 State + Event
        │
        ▼
      Reducer
        │
        ▼
새 State + 필요한 Effect 설명
```

Reducer는 가능하면 Android, `Context`, Telecom 객체, coroutine, DB에 의존하지 않는 순수 Kotlin 함수로 만든다. 모든 화면을 이 구조로 만들지는 않는다.

## 프로덕션 UiState 모델링

상호 배타적인 상태는 `sealed interface`로 표현한다.

```kotlin
sealed interface LoadState {
    data object Loading : LoadState
    data class Content(val calls: List<CallUiModel>) : LoadState
    data class Failed(val reason: ErrorReason) : LoadState
}
```

동시에 존재할 수 있는 상태는 한 데이터 모델의 독립 필드로 표현한다.

```kotlin
data class CallHistoryUiState(
    val calls: List<CallUiModel>,
    val refreshing: Boolean,
    val filter: Filter,
    val warning: Warning?,
)
```

목록을 보여주는 동시에 refresh 중이고 오프라인 경고가 있는 상태를 `Loading/Content/Error` 하나로 억지로 압축하지 않는다. 반대로 상호 배타적인 통화 단계는 여러 Boolean으로 만들어 불가능한 조합을 허용하지 않는다.

## UI event 판단 규칙

ViewModel이 UI보다 오래 살아남을 수 있으므로 `Channel`이나 `SharedFlow<UiEvent>`로 exactly-once 전달을 보장한다고 가정하지 않는다.

```text
ViewModel에서 생긴 비즈니스 결과
→ 즉시 UiState로 축약

사용자의 단순한 Help 클릭과 화면 이동
→ UI behavior로 UI가 처리 가능

이동 전 비즈니스 검증이 필요함
→ ViewModel이 검증 결과를 상태로 노출
```

메시지를 상태로 표현했다면 UI가 소비한 사실도 명시적인 사용자 입력으로 ViewModel에 알려 상태를 정리한다.

## 반드시 익힐 패턴과 사용 경계

| 패턴 | 대표 사용처 | 도입하지 않을 때 |
|---|---|---|
| MVVM + UDF | 화면 상태 생산과 이벤트 전달 | 단순 UI 요소 상태만 있을 때 |
| State | 통화, 권한, 연결의 상호 배타적 상태 | 독립 상태를 억지로 하나로 묶을 때 |
| Reducer/MVI 스타일 | 중복·역순 이벤트가 많은 상태 전이 | 단순 CRUD 화면 |
| Repository | 데이터 접근과 변경의 경계 | UI가 데이터 소스를 직접 호출하도록 둘 때 없음 |
| SSOT | Room, 세션 상태, 설정의 단일 소유자 | 복수 소유자가 같은 데이터를 변경할 때 |
| Adapter | Telecom, Telephony, Audio, Connectivity | 프레임워크 객체를 ViewModel에 직접 주입할 때 없음 |
| Observer | Flow, StateFlow, callbackFlow | callback 등록·해제 책임이 불명확할 때 |
| Strategy | Retry, Audio route, 품질 평가 정책 | 조건문 하나뿐이고 교체 가능성이 없을 때 |
| Facade | 여러 Android System API를 앱 API로 단순화 | 단순 API 하나를 이름만 바꿔 감쌀 때 |
| Decorator | Logging, Metrics, Retry | 핵심 로직과 운영 부가 기능을 섞을 때 없음 |
| Factory/DI | production과 Fake 구현 교체 | 생성 규칙이 없는 값 객체 |
| Mapper | DTO, Entity, Framework, UI 모델 경계 | 의미와 형태가 실제로 같은 단순 모델 |
| Coordinator/Controller | 화면보다 오래 사는 call session·workflow | 화면 수명과 동일한 단순 작업 |
| Plain State Holder | 복잡한 재사용 UI 로직 | 화면 비즈니스 상태 |
| Composition | 작은 UI 컴포넌트와 Slot API | 상속 계층이 명확한 이점 없이 커질 때 |

Factory, Builder, Prototype, Flyweight, Visitor, Memento 같은 GoF 패턴을 별도 예제로 깊게 공부하는 일은 이번 달 우선순위가 아니다. 패턴 이름보다 상태 소유권과 실패 조건을 설명하는 능력을 우선한다.

## 프로젝트: Telecom Client Lab

한 달 동안 여러 토이 앱을 만들지 않고 다음 흐름을 하나의 앱에서 확장한다.

```text
권한·역할 안내
→ 대시보드
→ Subscription 선택
→ 통화 내역
→ 통화 상세
→ 가상 수신·발신
→ 통화 중 화면
→ Bluetooth/오디오 경로 전환
→ 종료
→ 진단 저장과 리포트 업로드
```

초반에는 `FakeCallEventSource`, `FakeTelephonyEventSource`, Fake Repository로 상태 전이를 만든다. 실제 Android API는 같은 계약 뒤에 3주 차부터 연결한다.

처음부터 많은 Gradle 모듈을 만들지 않는다. 단일 `app` 모듈 안에서 다음 패키지 경계를 사용하고, 4주 차에 실제 이점이 확인된 경계만 모듈 후보로 평가한다.

```text
app
├── feature
│   ├── dashboard
│   ├── history
│   ├── call
│   ├── diagnosis
│   └── settings
├── data
│   ├── repository
│   ├── remote
│   └── local
├── platform
│   ├── connectivity
│   ├── telephony
│   ├── telecom
│   └── audio
├── domain
│   ├── call
│   └── policy
└── core
    ├── model
    ├── ui
    └── testing
```

## 매일 적용할 XP와 TDD 규칙

각 Day는 하나의 관찰 가능한 사용자 스토리로 시작한다.

```text
인수 조건 작성
→ 가장 저렴한 실패 테스트
→ Red 실패 이유 확인
→ 최소 구현으로 Green
→ 테스트가 통과하는 상태에서 Refactor
→ 집중 테스트와 넓은 검사
→ 화면·기기 검증
→ 상태 소유권과 실패 원인 기록
```

테스트 수준은 다음 순서로 고른다.

```text
순수 Kotlin JVM 테스트
→ ViewModel/Repository Flow 테스트
→ Compose 또는 Espresso 컴포넌트 테스트
→ Navigation·통합 테스트
→ 에뮬레이터·실기기 시스템 API 테스트
```

Fake를 우선하고, 구현 세부 호출 횟수보다 최종 상태와 사용자 결과를 검증한다. `Thread.sleep()` 대신 `runTest`와 가상 시간을 사용한다.

## 하루 운영 방식

하루 분량은 평일 2~3시간을 기준으로 한다. API를 많이 읽는 것보다 관찰 가능한 행동 하나를 Green으로 끝내는 것을 우선한다.

| 구간 | 권장 시간 | 산출물 |
|---|---:|---|
| 방향 잡기 | 15분 | 사용자 스토리, 상태 owner·lifetime·SSOT 결정 |
| Red | 25분 | 아직 없는 행동 때문에 실패하는 가장 저렴한 테스트 하나 |
| Green | 45~60분 | 그 테스트만 통과시키는 최소 구현 |
| Refactor | 25분 | Android 경계, 이름, 중복을 정리한 통과 상태 |
| Production check | 25~40분 | 그날 관련 있는 회전·취소·중복·역순·오프라인 검사 |
| 회고 | 10분 | 검증 명령, 바로잡은 오해, 남긴 제약, 다음 스토리 |

시간이 부족하면 새 추상화나 다음 시나리오를 시작하지 않는다. 현재 Red를 Green으로 만들고, 추가 실패 조건은 다음 스토리로 명시한다. 실제 SIM, Telecom role, Bluetooth 장비가 없어도 Fake 계약 테스트까지 완료한 뒤 기기 검증을 `미검증`으로 기록할 수 있지만, 이를 자동 테스트 통과와 같은 의미로 취급하지 않는다.

## 주차별 품질 게이트

다음 주로 넘어가기 전에 코드 양이 아니라 증거를 확인한다.

| Gate | 반드시 보여줄 증거 |
|---|---|
| Week 1 | 순수 Reducer 테스트, ViewModel 상태 테스트, 상태 소유권·복원 표, Fragment observer 중복 방지 |
| Week 2 | 목록→상세 흐름, offline cache, retry 취소, production/Fake DI 교체, 접근성·adaptive 검사 |
| Week 3 | callback 등록·해제 계약, stale subscription 무시, call reconciliation, audio fallback, background 작업 복구 |
| Week 4 | race/chaos 테스트, privacy-safe timeline, 전체 capstone, 장애 재현 테스트와 모의 PR |

Gate를 통과하지 못했다면 다음 주 API를 미리 추가하지 않고 실패한 증거를 가장 작은 보충 스토리로 만든다.

---

# Week 1 — UI Architecture와 State Management

목표는 상태를 무조건 ViewModel에 넣지 않고 수명, 소유권, 복원 요구사항에 따라 배치하는 것이다.

| Day | 핵심 | 패턴 | 결과물 |
|---|---|---|---|
| 1 | Layered Architecture | Layered, SSOT | Call 상태 머신 |
| 2 | ViewModel, StateFlow, UDF | MVVM, Observer | Dashboard |
| 3 | 상태 모델링 | State | LoadState |
| 4 | 복잡한 상태 전이 | Reducer/MVI 스타일 | CallReducer |
| 5 | Compose state hoisting | State Holder | DialPad |
| 6 | Process death | State Ownership | 검색·필터 복원 |
| 7 | Fragment/View 레거시 | Adapter, Characterization | 레거시 화면 분리 |

## Day 1 — Layered Architecture와 테스트 기준점

### 중점 학습

- UI, Data, 선택적 Domain 레이어의 책임과 의존 방향
- UDF와 SSOT가 상태 변경을 한곳으로 모으는 이유
- JVM 테스트, 계측 테스트, Gradle 검증의 차이

### 구현

순수 Kotlin `CallStateMachine`을 만든다. Android 타입을 사용하지 않는다.

```text
Idle → Dialing → Active → Holding → Disconnected
```

### TDD 시나리오

```text
Idle + StartOutgoing → Dialing
Dialing + Connected → Active
Active + Hold → Holding
Holding + Resume → Active
어떤 상태 + Disconnect → Disconnected
Disconnected + 늦은 Connected → Disconnected
```

### 완료 조건

- Data나 Platform 구현이 UI 타입에 의존하지 않는다.
- 상태 전이 테스트가 Android 없이 실행된다.
- `testDebugUnitTest`, `lintDebug`, `assembleDebug`가 각각 무엇을 검증하는지 설명한다.

## Day 2 — MVVM + UDF 대시보드

### 중점 학습

- ViewModel을 UI controller가 아니라 screen state producer로 이해하기
- `StateFlow`와 `collectAsStateWithLifecycle()`
- Stateless Screen과 Route 분리

### 구현

```text
DashboardScreen
      ↑ UiState
DashboardViewModel
      ↓
FakeDashboardRepository
```

### TDD 시나리오

```text
초기 → Loading
Repository 성공 → Content
Repository 실패 → Error
Retry → Loading → Content
화면 수집 중지 → 불필요한 작업 중지 또는 정책대로 유지
```

### 완료 조건

- Screen은 상태와 callback만 받는다.
- ViewModel은 Android `Activity`, `Context`, View를 참조하지 않는다.
- 회전 후 ViewModel 상태가 유지되는 이유를 설명한다.

## Day 3 — State Pattern과 상태 불변식

### 중점 학습

- 상호 배타적인 상태와 동시에 존재 가능한 상태의 차이
- Boolean 조합이 만드는 불가능한 상태
- 타입으로 invariant 보호하기

### 구현

먼저 `isLoading`, `hasError`, `hasContent` Boolean 모델로 모순 상태를 재현한 뒤 `sealed interface LoadState`로 바꾼다. 이후 목록 표시 + refresh + offline warning처럼 함께 존재하는 상태는 data class 필드로 분리한다.

### TDD 시나리오

```text
Loading과 Content가 동시에 표현되지 않음
Failed는 오류 이유를 반드시 가짐
Content는 empty 목록도 명시적으로 표현함
기존 목록 + refreshing + warning은 함께 표현됨
```

### 완료 조건

- 상태 타입만 읽어도 가능한 상태 조합을 설명할 수 있다.
- sealed state와 data class를 선택한 근거를 말할 수 있다.

## Day 4 — MVI의 도구화와 CallReducer

### 중점 학습

- MVI를 앱 전체 규칙이 아니라 복잡한 상태 전이 도구로 사용하기
- 순수 Reducer와 외부 Effect 경계
- 중복·역순·지연 이벤트의 결정적 처리

### 구현

```text
현재 CallState + CallEvent → CallReducer → 새 CallState
```

### TDD 시나리오

정상 흐름뿐 아니라 최소 20개의 표 기반 테스트를 작성한다.

```text
timeout
duplicate
out-of-order
late callback
disconnect race
hold/resume race
Disconnected 이후 모든 활성 이벤트 무시
```

### 완료 조건

- 같은 State와 Event는 항상 같은 결과를 만든다.
- Reducer에 Android, coroutine, DB 의존성이 없다.
- 단순 설정 화면에 Reducer를 쓰지 않을 이유를 설명한다.

## Day 5 — Compose State Holder와 DialPad

### 중점 학습

- `remember`, `rememberSaveable`, plain state holder, ViewModel의 수명
- state hoisting과 가장 가까운 소유자
- 입력, focus, IME, cursor를 UI 로직으로 다루기

### 구현

`DialPadState`에 전화번호, cursor, 키패드 표시 여부, 입력 포맷을 둔다. 전화번호 검증이 비즈니스 규칙으로 커지면 Strategy로 분리할 seam만 남긴다.

### TDD·UI 시나리오

```text
숫자 입력과 삭제
붙여넣기
잘못된 문자 무시
cursor 이동
회전 후 입력 복원
Composable 제거 후 불필요한 상태 정리
```

### 완료 조건

- ViewModel로 올리지 않은 이유를 상태 수명으로 설명한다.
- UI 테스트가 렌더링과 callback을 검증한다.

## Day 6 — Process Death와 State Ownership

### 중점 학습

- recomposition, configuration change, system process death의 차이
- `rememberSaveable`, ViewModel, `SavedStateHandle`, Room의 복원 범위
- 복원 키와 다시 계산할 데이터 분리

### 구현

검색어, filter, scroll, 선택 `callId`, 검색 결과, 통화 내역의 소유자를 각각 결정한다.

### TDD·복원 시나리오

```text
회전 후 검색어와 filter 유지
process recreation 후 callId 복원
검색 결과는 복원 키로 Repository에서 다시 생산
큰 목록을 SavedStateHandle에 저장하지 않음
사용자가 앱을 명시적으로 종료한 경우의 기대 동작 구분
```

### 완료 조건

- 각 상태의 source of truth와 복구 순서를 표로 남긴다.
- `StateRestorationTester` 또는 가능한 복원 테스트와 수동 process death 검증을 수행한다.

## Day 7 — Fragment/View 레거시와 Characterization Test

### 중점 학습

- Activity, Fragment, View lifecycle
- XML View와 ComposeView 상호운용
- 동작을 고정한 뒤 seam을 추출하는 레거시 변경

### 구현

API, DB, TelephonyManager, Navigation, Timer, formatting이 섞인 `CallFragment` 예제를 만든다. 먼저 Characterization Test를 추가하고 ViewModel, Repository, Platform Adapter를 한 경계씩 추출한다.

### TDD 시나리오

```text
기존 로딩·오류·재시도 동작 보존
Fragment view 재생성 후 observer 중복 없음
ComposeView composition 정리
기존 View와 Compose에 동일 상태를 중복 저장하지 않음
```

### 완료 조건

- 재작성 없이 작은 단계로 구조를 개선한다.
- 추출 전후 Characterization Test가 동일하게 통과한다.

---

# Week 2 — 실제 사용자 앱 패턴

목표는 Navigation, 디자인 시스템, 입력, 목록, 오류, 오프라인과 DI를 하나의 사용자 흐름으로 연결하는 것이다.

| Day | 핵심 | 패턴 | 결과물 |
|---|---|---|---|
| 8 | Navigation State | State/Back stack | 목록 → 상세 |
| 9 | UI Composition | Composition | 디자인 시스템 |
| 10 | Form 정책 | State Holder/Strategy | Dial 화면 |
| 11 | List/Paging | Repository | 통화 내역 |
| 12 | Error/Retry | Strategy/Decorator | 재시도 계층 |
| 13 | Offline-first | Repository/SSOT | Room cache |
| 14 | DI | Factory/DI | Hilt 전환 |

## Day 8 — Navigation State와 Back Stack

### 중점 학습

- Navigation 3에서 앱이 소유하는 back stack
- type-safe key, deep link, process restoration
- compact·expanded layout에서 동일한 탐색 상태 사용

### 구현

```text
Home → CallHistory → CallDetail(id) → Diagnosis(id)
```

### TDD 시나리오

```text
push와 pop
잘못된 id
deep link 직접 진입
process recreation 후 back stack 복원
expanded layout에서 목록과 상세 동시 표시
뒤로 가기 후 예상 상태
```

### 완료 조건

- 하위 Composable에 navigation controller를 퍼뜨리지 않고 callback을 전달한다.
- Navigation state와 화면 business state의 소유자를 구분한다.

## Day 9 — UI Composition, Design System과 접근성

### 중점 학습

- 상속보다 작은 UI 조합과 Slot API
- Material 3 token과 stable UI model
- semantics, 큰 글자, touch target, 색상 외 정보

### 구현

```text
TelecomTheme
AppButton
CallControlButton
NetworkStatusCard
SubscriptionChip
ErrorBanner
LoadingContent
```

### TDD·수동 시나리오

```text
enabled/disabled/loading
오류 semantics
TalkBack 읽기 순서
200% 글자 크기
compact/expanded Preview
다국어 문자열 길이
```

### 완료 조건

- UI 컴포넌트가 ViewModel이나 Repository를 직접 참조하지 않는다.
- 접근성 검사를 완료 조건에 포함한다.

## Day 10 — Form State와 Strategy

### 중점 학습

- 전화번호 입력 상태와 비즈니스 검증 분리
- Formatter와 Validator Strategy
- focus, IME, 붙여넣기, 복원

### 구현

```kotlin
interface PhoneNumberFormatter
interface PhoneNumberValidator
```

### TDD 시나리오

```text
숫자와 공백
붙여넣기
길이 제한
국가 코드
잘못된 문자
formatter 교체
회전·process recreation 후 최소 입력 복원
```

### 완료 조건

- UI 상태와 교체 가능한 정책의 경계가 분명하다.
- 오류가 문자열이 아니라 UI에서 변환 가능한 이유로 모델링된다.

## Day 11 — 목록, Paging과 Repository

### 중점 학습

- `CallHistoryRepository`와 데이터 소스 추상화
- LazyColumn item key와 Paging 상태
- refresh와 pagination의 동시성

### TDD 시나리오

```text
첫 페이지와 다음 페이지
중복 데이터 제거
페이지 실패와 retry
마지막 페이지
refresh와 paging 동시 발생
늦게 도착한 이전 query 결과 무시
```

### 완료 조건

- ViewModel은 Room, HTTP 응답 형식, Paging 데이터 소스 세부를 모른다.
- 빈 상태, stale content, pagination 오류를 서로 구분한다.

## Day 12 — Retry Strategy와 Decorator

### 중점 학습

- 오류 종류와 retry 정책 분리
- exponential backoff와 cancellation
- Logging·Metrics 같은 부가 기능을 Decorator로 감싸기

### 구현

```text
NetworkRetryPolicy
NoRetryPolicy
ExponentialBackoffPolicy

Repository
→ RetryingRepository
→ LoggingRepository
```

### TDD 시나리오

```text
401 → retry 안 함
timeout → 정책에 따라 retry
500 → 제한 횟수만 retry
cancelled → retry 안 함
성공 → 즉시 종료
가상 시간으로 backoff 확인
중복 요청의 idempotency
```

### 완료 조건

- ViewModel에 오류 타입별 조건문이 퍼지지 않는다.
- 취소를 실패로 오인해 재시도하지 않는다.

## Day 13 — Offline-first와 Room SSOT

### 중점 학습

- 로컬 데이터 소스를 canonical source of truth로 사용하기
- 네트워크 결과를 Room에 반영하고 UI는 Room Flow 관찰하기
- DataStore에 적합한 설정과 Room 데이터 구분

### 구현

```text
Server → Repository → Room → Flow → UI
```

### TDD 시나리오

```text
offline 시작과 cached data
refresh 성공
refresh 실패 + stale data warning
server와 DB conflict
중복 원격 응답
앱 재시작 후 데이터와 설정 복원
```

### 완료 조건

- UI가 서버 Response를 직접 관찰하지 않는다.
- conflict, stale, freshness 정책을 문서화한다.

## Day 14 — 수동 DI에서 Hilt로

### 중점 학습

- constructor injection이 테스트 가능성을 만드는 이유
- scope가 객체의 lifetime과 일치해야 하는 이유
- production과 Fake binding 교체

### 구현

먼저 수동으로 Repository와 EventSource를 주입하고 테스트한다. 그 다음 같은 계약을 Hilt binding으로 옮긴다.

### TDD 시나리오

```text
FakeCallRepository 교체
FakeTelephonyEventSource 교체
scope가 다른 객체의 소유권 검증
Hilt를 제거해도 핵심 클래스 테스트 가능
```

### 완료 조건

- Hilt annotation보다 constructor dependency의 의미를 먼저 설명한다.
- app, Activity, ViewModel scope의 수명 차이를 말할 수 있다.

---

# Week 3 — Telecom과 플랫폼 패턴

목표는 Fake로 검증한 계약 뒤에 공개 Android API를 연결하고, callback의 등록·해제·중복·지연을 통제하는 것이다.

| Day | 핵심 | 패턴 | 결과물 |
|---|---|---|---|
| 15 | Permission | State | 권한 상태 머신 |
| 16 | Connectivity | Adapter/Observer | 연결 Flow |
| 17 | Subscription/Telephony | Adapter/Repository | 멀티 SIM 상태 |
| 18 | Telecom | State/Reducer/Coordinator | 통화 세션 |
| 19 | Audio | Strategy/State | 오디오 정책 |
| 20 | Background | Coordinator | 진단·업로드 |
| 21 | Binder/AIDL | Facade/Adapter | Radio facade |

## Day 15 — Permission State Machine

### 중점 학습

- Manifest permission, runtime permission, System Role 구분
- 권한을 Boolean이 아닌 상태 전이로 모델링
- 지원하지 않는 단말과 제한 기능의 대체 UX

### 구현

```text
Unknown → Checking → Granted
                   → Denied
                   → NeedsRationale
                   → Unavailable
```

### TDD 시나리오

```text
Granted → 기능 활성
Denied → 제한 UI
NeedsRationale → 설명 후 재요청
사용 중 권한 제거
다시 허용
API 자체 미지원
중복 권한 결과 callback
```

### 완료 조건

- 권한 요청 UI와 권한 상태 정책을 분리한다.
- 백그라운드에서 권한이 제거된 뒤 복귀하는 흐름을 검증한다.

## Day 16 — Connectivity Adapter와 Observer

### 중점 학습

- `ConnectivityManager` callback을 앱 모델의 Flow로 변환
- callbackFlow의 등록, `awaitClose`, 중복 제거
- 연결됨과 실제 인터넷 사용 가능 여부 구분

### 구현

```text
ConnectivityManager
→ AndroidConnectivityMonitor
→ Flow<Connectivity>
```

### TDD 시나리오

```text
Wi-Fi, Cellular, Offline
Wi-Fi → Cellular
중복 callback
등록 직후 초기 상태
수집 취소 후 unregister
늦은 callback 무시
```

### 완료 조건

- 등록과 해제를 같은 Adapter가 소유한다.
- 화면 재생성으로 callback이 중복 등록되지 않는다.

## Day 17 — Subscription과 Telephony

### 중점 학습

- SIM slot과 subscriptionId 구분
- 선택 Subscription 변경 시 TelephonyCallback 교체
- 권한·SIM 제거·오래된 callback 처리

### 구현

```text
SubscriptionManager / TelephonyManager / TelephonyCallback
→ TelephonyAdapter
→ TelephonyRepository
→ StateFlow<TelephonyState>
```

### TDD 시나리오

```text
SIM 1 선택
SIM 2 전환
SIM 제거·재활성화
callback 재등록
SIM 1의 늦은 callback 무시
권한 제거
중복 signal event
```

### 완료 조건

- 활성 subscriptionId를 하드코딩하지 않는다.
- 교체 전후 callback owner와 generation/token 정책을 설명한다.

## Day 18 — Telecom State Machine과 CallSessionController

### 중점 학습

- Telecom, InCallService, ConnectionService의 책임 차이
- 실제 통화 lifetime과 화면 lifetime 분리
- Adapter, Reducer, Observer, Coordinator 결합

### 구현

```text
Telecom
→ CallEventSource
→ CallSessionController
→ CallReducer
→ StateFlow<CallSession>
   ├─ Notification
   └─ InCallViewModel → Compose
```

### TDD 시나리오

```text
incoming → answer → active → disconnect
hold/resume
두 통화 swap
중복 callback
역순 callback
화면 제거 중 통화 지속
process 재생성 후 Telecom과 재동기화
```

### 완료 조건

- ViewModel이 실제 통화 session을 소유하지 않는다.
- 시스템 상태와 앱 reducer 상태가 어긋날 때 reconciliation 규칙이 있다.

## Day 19 — Audio Route Strategy

### 중점 학습

- Bluetooth, Speaker, Wired, Earpiece endpoint 모델
- 사용자의 선택과 fallback 정책 분리
- 요청 성공과 실제 callback 상태 구분

### 구현

`AudioRoutePolicy`와 Android Audio Adapter를 분리한다.

### TDD 시나리오

```text
Bluetooth 사라짐 → Wired
Wired 없음 → Earpiece
Speaker 강제 선택
route request 실패
선택 중 endpoint 소실
늦은 callback
Disconnected 이후 route event 무시
```

### 완료 조건

- Strategy는 Android 객체 없이 테스트된다.
- 실제 기기에서 Bluetooth 연결·해제와 실패 경로를 검증한다.

## Day 20 — Background 작업과 Coordinator

### 중점 학습

- ViewModel scope, app scope, Foreground Service, WorkManager의 수명
- 진행 중 통화 진단과 완료 후 업로드의 소유자 분리
- WorkManager와 DB 중 작업 상태의 source of truth 결정

### 구현

```text
CallSessionController
→ DiagnosisRepository
→ Room
→ ReportUploadWorker
```

### TDD 시나리오

```text
화면 이탈 중 진단 지속
통화 종료 후 진단 저장
오프라인이면 업로드 대기
네트워크 복구 후 재시도
동일 리포트 중복 enqueue 방지
앱 재시작 후 작업 상태 관찰
```

### 완료 조건

- ViewModel을 지속 작업의 SSOT로 사용하지 않는다.
- Foreground Service와 WorkManager 선택 기준을 설명한다.

## Day 21 — Binder/AIDL와 Facade

### 중점 학습

- Binder thread, 동기 호출, `RemoteException`, process death
- AIDL service를 앱 도메인 API 뒤에 숨기는 Facade
- Telecom에서 Telephony, IMS, RIL, Radio HAL로 이어지는 계층 읽기

### 구현

별도 `:radio` process의 `FakeRadioService`와 `RadioServiceFacade`를 만든다.

### TDD·통합 시나리오

```text
서비스 연결과 명령 전달
callback 수신
원격 process 종료
DeathRecipient 또는 연결 끊김
재연결
중복 callback
main thread 장기 blocking 방지
```

### 완료 조건

- AIDL 모델을 UI나 Domain에 그대로 노출하지 않는다.
- 일반 다운로드 앱이 IMS/RIL 구현을 소유하지 않는 경계를 설명한다.

---

# Week 4 — 프로덕션 아키텍처와 통합

목표는 정상 흐름보다 race, 복원, 성능, 관측 가능성, 레거시 변경과 장애 대응을 중심으로 전체 vertical slice를 완성하는 것이다.

| Day | 핵심 | 패턴 | 결과물 |
|---|---|---|---|
| 22 | Feature Architecture | 모듈 경계 | 분리 판단 기록 |
| 23 | Domain Layer | UseCase/Mapper | 정책 경계 |
| 24 | Concurrency | Reducer/SSOT | race 테스트 |
| 25 | Restoration | State Ownership | chaos matrix |
| 26 | Performance | State 분리 | recomposition 개선 |
| 27 | Observability | Decorator | 이벤트 timeline |
| 28 | Legacy | Characterization | God ViewModel 분해 |
| 29 | Production Capstone | 전체 통합 | end-to-end 흐름 |
| 30 | Incident/PR | 실무 시뮬레이션 | 장애 수정 PR |

## Day 22 — Feature 기반 모듈화 판단

### 중점 학습

- high cohesion과 low coupling
- 패키지 경계와 Gradle 모듈 경계의 차이
- 모듈화의 빌드·소유권 이점과 복잡성 비용

### 실습

다음 후보 구조를 그리되 실제로 모두 분리하지 않는다.

```text
:app
:feature:dashboard
:feature:call-history
:feature:incall
:data:call
:core:model
:core:ui
:core:testing
```

### 검증 시나리오

```text
순환 의존성 탐지
feature 간 구현 타입 직접 참조 금지
공유 ID로 데이터 재조회
분리 전후 빌드·테스트 비용 비교
```

### 완료 조건

- 실제 독립 변경, 캡슐화, 재사용 이점이 있는 경계만 분리 후보로 선택한다.
- “모듈 수가 많으면 좋은 아키텍처”가 아닌 이유를 설명한다.

## Day 23 — Domain Layer와 Mapper를 만드는 기준

### 중점 학습

- 여러 Repository를 조합하거나 재사용되는 복잡한 정책에 UseCase 사용
- 단순 전달 UseCase를 만들지 않기
- HTTP DTO, Room Entity, Framework Object, UI Model의 의미 경계

### 구현

좋은 후보 하나를 선택한다.

```text
ObserveActiveCallUseCase
SwitchSubscriptionUseCase
DiagnoseCallQualityUseCase
RetryFailedReportUseCase
```

### TDD 시나리오

```text
두 Repository 결과 조합
정책 변경 시 UI와 data source 영향 없음
DTO 필드 추가가 UI 모델을 깨지 않음
Framework 객체가 Domain으로 새지 않음
```

### 완료 조건

- Repository 한 줄 호출만 감싼 UseCase는 제거한다.
- 모델 분리 여부를 의미, 수명, 변경 빈도로 설명한다.

## Day 24 — Concurrency와 Race Condition

### 중점 학습

- duplicate, out-of-order, late response, cancellation
- 단일 상태 변경 지점과 직렬화 전략
- event generation, version, idempotency

### TDD 시나리오

```text
사용자 End 클릭
동시에 Bluetooth callback
동시에 remote disconnect
뒤늦게 Active callback
최종 상태는 Disconnected

SIM 2 선택
SIM 1 stale callback 도착
SIM 1 상태 무시
```

### 완료 조건

- 정상 흐름보다 실패·경쟁 시나리오 테스트가 더 많다.
- Mutex, actor, reducer 직렬화 중 선택한 전략과 cancellation 경계를 설명한다.

## Day 25 — Process Death Chaos Test

### 중점 학습

- 상태별 복원 요구사항을 제품 관점에서 결정
- saved state, 영속 데이터, 지속 작업, 시스템 세션의 차이
- 재시작 시 시스템과 앱 상태 reconciliation

### Chaos 시점

```text
검색 중
목록 로딩 중
Call detail 열린 상태
권한 dialog 직후
Subscription 변경 직후
통화 중 UI 표시 중
리포트 업로드 중
```

### 기대 복구

```text
UI element state → rememberSaveable
screen input → SavedStateHandle
app data → Room/DataStore
ongoing persistent work → WorkManager
active telecom session → 시스템과 CallSessionController 재동기화
```

### 완료 조건

- 각 시점의 복구 여부, source of truth, 사용자 기대를 표로 남긴다.
- 단순 Activity recreate와 실제 process death 검증을 구분한다.

## Day 26 — Compose Performance와 State

### 중점 학습

- 상태 경계와 recomposition 범위
- stable key, immutable model, derived state
- Profiler, Layout Inspector, recomposition 도구로 근거 수집

### 실습

30개 필드의 `HugeUiState`와 잦은 Flow emission으로 jank를 만든 뒤 다음을 적용한다.

```text
변경 빈도가 다른 state 분리
derived state
stable item key
immutable model
불필요한 emission 제거
distinctUntilChanged
```

### 완료 조건

- 변경 전후 recomposition 또는 frame 지표를 기록한다.
- 추측이 아니라 측정 근거로 최적화한다.

## Day 27 — Observability와 Privacy-safe Decorator

### 중점 학습

- Logging, Metrics, Analytics, Tracing을 핵심 로직과 분리
- 상태 전이 timeline 재구성
- 개인정보·전화번호·구독 정보의 안전한 기록

### 구현

```text
CallRepository
→ MetricsCallRepository
→ LoggingCallRepository
```

이벤트에는 필요한 최소한의 session ID, 익명화한 subscription 식별자, previous state, event, next state, elapsed time을 기록한다.

### TDD 시나리오

```text
정상 상태 전이 로그
중복 event 표시
민감 정보 미포함
Decorator 제거 후 핵심 동작 동일
로그 실패가 통화 동작을 깨지 않음
```

### 완료 조건

- 장애 타임라인을 로그에서 재구성할 수 있다.
- 운영 부가 기능이 핵심 인터페이스 계약을 바꾸지 않는다.

## Day 28 — Legacy Architecture 리팩터링

### 중점 학습

- God ViewModel의 현재 동작을 먼저 고정
- Adapter, Repository, Policy, Reducer를 한 번에 하나씩 추출
- 리팩터링 중 회귀와 scope 변경 감지

### 대상

```text
CallViewModel
├── TelephonyManager
├── TelecomManager
├── AudioManager
├── Room
├── HTTP client
├── Timer
├── Navigation
└── Analytics
```

### 작업 순서

```text
1. Characterization Test
2. Adapter 추출
3. Repository 추출
4. Policy 추출
5. Reducer 추출
6. UI state 정리
```

### 완료 조건

- 한 번에 Clean Architecture로 재작성하지 않는다.
- 매 단계 테스트가 통과하고 diff가 한 가지 이유로만 바뀐다.

## Day 29 — Production Capstone

### 중점 학습

- 모든 상태의 수명과 source of truth를 하나의 흐름에서 연결
- 자동 테스트와 기기 검증의 경계
- 접근성, adaptive UI, 오프라인, 복원까지 제품 수준으로 마감

### 최종 흐름

```text
대시보드
→ 통화 내역
→ 수신 화면
→ 통화 중 화면
→ Bluetooth 전환
→ 종료
→ 진단 저장
→ 리포트 업로드
```

### 필수 상태 소유권

```text
Button state → Compose
Screen state → ViewModel
Navigation state → Navigation
Call state → CallSessionController
App data → Repository + Room
Preferences → DataStore
Background work → WorkManager
Process restoration key → SavedStateHandle
```

### 인수 시나리오

```text
오프라인에서도 cached history 표시
통화 화면 제거 후 call session 지속
Bluetooth 해제 fallback
회전과 process recreation
멀티 SIM 전환과 stale callback
중복 업로드 방지
큰 글자와 expanded layout
```

### 완료 조건

- 핵심 흐름의 JVM, UI, 통합, 기기 테스트 증거를 모은다.
- 각 상태 owner와 복구 전략을 아키텍처 그림으로 설명한다.

## Day 30 — 실제 장애 대응 모의 PR

### 중점 학습

- 로그와 상태 timeline으로 race condition을 재현하기
- callback부터 UI까지 아키텍처 경계를 따라 근본 원인 찾기
- 실패 테스트, 기기 검증, 회귀 위험과 rollback을 담은 PR 작성

### 버그

> SIM 1로 통화하던 중 SIM 설정이 변경되고 Bluetooth가 해제되면 통화 화면이 이전 SIM 신호 상태를 표시한다.

### 분석 경계

```text
Telephony callback
→ Subscription Adapter
→ Repository
→ CallSessionController
→ ViewModel
→ UI
```

### 실패 테스트

```gherkin
시나리오: Subscription 전환 후 이전 SIM callback 무시
  조건 SIM 1로 통화 중이다.
  만일 SIM 2를 선택한 뒤 SIM 1의 늦은 callback이 도착하면
  그러면 SIM 1 callback을 무시한다.
  그리고 UI에는 SIM 2 상태를 표시한다.
```

Bluetooth 해제 event와 remote disconnect까지 동시에 발생하는 race 테스트를 추가한다.

### 모의 PR

```text
Problem
Reproduction
Root Cause
State Owner와 Architecture Boundary
Change
Unit Test
Integration Test
Device Test
Process-death Test
Regression Risk
Rollback
```

### 완료 조건

- 재현 → 실패 테스트 → 최소 수정 → 회귀 검증 순서를 지킨다.
- 로그 타임라인과 테스트가 근본 원인을 함께 설명한다.
- 코드를 보지 않고 핵심 CallReducer와 FakeEventSource를 다시 구현해본다.

---

# 매주 반복할 프로덕션 실패 행렬

각 기능을 정상 흐름 한 번으로 끝내지 않고 관련 있는 실패 조건을 누적한다.

| 영역 | 기본 | 다음 단계 | 프로덕션 단계 |
|---|---|---|---|
| 화면 상태 | Loading/Content/Error | refresh + stale | process restoration |
| 입력 | 기본 입력 | 붙여넣기·IME | 복원·다국어 포맷 |
| 검색 | 즉시 검색 | debounce | 취소·역순 응답 |
| Paging | 다음 페이지 | 중복 제거 | refresh race·실패 재시도 |
| Permission | 허용·거부 | rationale | 사용 중 취소·API 미지원 |
| Callback | 등록·해제 | 중복 등록 | owner 교체·late callback |
| Subscription | 단일 SIM | 멀티 SIM | 제거·전환·stale callback |
| Call | 정상 통화 | hold·두 통화 | duplicate·race·reconciliation |
| Audio | Speaker | Bluetooth | endpoint 소실·요청 실패 |
| Navigation | 목록·상세 | deep link | process 복원·adaptive layout |
| Upload | 성공·실패 | backoff | unique work·idempotency |
| Legacy | 현재 동작 고정 | seam 추출 | 점진 리팩터링 |

# 특히 피해야 할 아키텍처

## 모든 것을 ViewModel에 넣기

DB, HTTP, Telecom, Audio, Navigation, formatting, analytics를 한 ViewModel이 직접 소유하지 않는다. 각 상태와 자원의 실제 수명에 맞는 owner를 찾는다.

## 모든 화면을 MVI로 만들기

단순 설정 화면에 Intent, Action, Result, Reducer, Effect, Middleware, Store를 모두 만들지 않는다. 복잡한 상태 전이가 있는 곳에만 사용한다.

## 모든 기능에 UseCase 만들기

재사용되지 않는 Repository 한 줄 호출을 감싼 UseCase는 만들지 않는다. 복잡성이나 재사용성이 실제로 있을 때 추가한다.

## 앱 전체 Global Store 만들기

서로 수명이 다른 login, call, audio, navigation, settings, network 상태를 하나의 AppState에 넣지 않는다. 상태별 owner와 source of truth를 유지한다.

## 모든 one-shot을 `SharedFlow<UiEvent>`로 전달하기

먼저 상태인지, UI behavior인지, 비즈니스 결과인지, 복원되어야 하는지 판단한다. ViewModel에서 발생한 중요한 결과는 가능한 한 UI 상태로 축약한다.

## Android Framework 객체를 UI까지 전달하기

Telecom `Call`, Telephony callback 객체, HTTP DTO, Room Entity를 그대로 UI에 노출하지 않는다. 의미와 변경 경계가 다르면 Adapter와 Mapper를 둔다.

## 처음부터 과도한 multi-module 만들기

패키지 경계로 학습을 시작하고 실제 독립성, 캡슐화, 빌드 이점이 확인될 때 Gradle 모듈로 분리한다.

# 새 기능마다 답할 일곱 질문

```text
1. 이 상태의 source of truth는 어디인가?
2. 이 상태는 화면이 없어져도 살아야 하는가?
3. 프로세스가 죽으면 복원되어야 하는가?
4. 같은 이벤트가 두 번 오면 어떻게 되는가?
5. 이벤트 순서가 바뀌면 어떻게 되는가?
6. Android API를 Fake로 교체할 수 있는가?
7. 이 로직은 Android 없이 JVM 테스트가 가능한가?
```

# 한 달 후 성공 기준

다음 판단을 코드와 테스트로 설명할 수 있어야 한다.

```text
단순 화면 → MVVM + UDF
복잡한 통화 이벤트 → Reducer + State Machine
오프라인 데이터 → Room SSOT + Repository
화면보다 오래 사는 통화 → CallSessionController
단순 UI interaction → remember 또는 rememberSaveable
process death 복원 키 → SavedStateHandle
프레임워크 callback → Adapter + Flow
교체 가능한 오디오·retry 정책 → Strategy
운영 로깅과 지표 → Decorator
복잡하거나 재사용되는 비즈니스 규칙 → 선택적 UseCase
```

최종적으로 `대시보드 → 통화 내역 → 수신 화면 → 통화 중 화면 → Bluetooth 전환 → 종료 → 리포트 저장·업로드` 전체 흐름을 TDD로 완성하고, 화면 회전·process death·오프라인·멀티 SIM·중복 이벤트·접근성·adaptive layout을 검증한다.

# 공식 자료

이 계획의 변동 가능한 권장 사항은 2026년 8월 28일 기준 다음 Android 공식 문서에서 확인했다.

- [Guide to app architecture](https://developer.android.com/topic/architecture): UI/Data 레이어, 선택적 Domain, SSOT, UDF
- [Recommendations for Android architecture](https://developer.android.com/topic/architecture/recommendations): Repository, ViewModel, StateFlow, lifecycle-aware 수집, Navigation 3, UI event 권장안
- [UI layer](https://developer.android.com/topic/architecture/ui-layer): screen-level state holder와 UDF
- [UI events](https://developer.android.com/topic/architecture/ui-layer/events): ViewModel event를 UI state로 축약하는 판단 기준
- [Save UI state in Compose](https://developer.android.com/develop/ui/compose/state-saving): `rememberSaveable`, `SavedStateHandle`, 작은 복원 상태
- [Navigation 3](https://developer.android.com/guide/navigation/navigation-3): 앱이 소유하는 back stack과 adaptive layout
- [Build an offline-first app](https://developer.android.com/topic/architecture/data-layer/offline-first): 로컬 데이터 소스를 canonical SSOT로 사용하는 구조
- [Task scheduling](https://developer.android.com/develop/background-work/background-tasks/persistent): 지속 작업과 WorkManager
- [Dependency injection with Hilt](https://developer.android.com/training/dependency-injection/hilt-android): Android용 DI와 Hilt
- [Guide to Android app modularization](https://developer.android.com/topic/modularization): 모듈화의 이점, 결합도, 과도한 세분화 비용
