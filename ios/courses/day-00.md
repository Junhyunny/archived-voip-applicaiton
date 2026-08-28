# Day 00 — 전체 과정 안내와 진도표

이 파일은 30일 과정의 진행 상황과 각 Day의 중점 학습을 한눈에 확인하는 대시보드다. Day를 마치면 이 표와 해당 Day 파일의 완료 체크박스를 함께 표시한다.

- [ ] Day 00 준비 완료: 전체 과정과 완료 기준을 읽고 첫 학습 세션을 정했다.

## 과정 진도와 중점 학습

### Week 1 — Local State에서 MVVM·DI·Router까지

- [ ] [Day 01 — 프로젝트와 테스트 기반](day-01.md)
  **중점:** Xcode 프로젝트·테스트 기반, Feature-first 구조, View local state와 필요할 때만 확장하는 Composition Root
- [ ] [Day 02 — SwiftUI Layout과 View identity](day-02.md)
  **중점:** SwiftUI 기본 레이아웃, View identity, `ForEach`의 안정적인 ID, 화면 상태를 표현하는 ViewState
- [ ] [Day 03 — Observation과 화면 상태](day-03.md)
  **중점:** Observation과 single source of truth, View local state와 `@Observable` Feature Model/MVVM의 소유권 경계
- [ ] [Day 04 — Login MVVM과 Dependency Injection](day-04.md)
  **중점:** Login MVVM, Form 검증, AuthClient·Clock·Logger의 명시적 DI, 중복 입력과 취소 가능한 요청
- [ ] [Day 05 — Navigation State와 Router](day-05.md)
  **중점:** Navigation도 state라는 관점, 타입 안전한 Router, 딥링크, 인증 전후 목적지 복원과 중복 Route 방지
- [ ] [Day 06 — Design System과 접근성](day-06.md)
  **중점:** 의미 기반 디자인 토큰과 최소 Design System, Dynamic Type·VoiceOver·Dark Mode 등 접근성
- [ ] [Day 07 — 첫 번째 재구현과 책임 리팩터링](day-07.md)
  **중점:** Login/Home/Router 재구현 뒤 View·Feature·Composition Root 책임과 아직 필요 없는 추상화 구분

### Week 2 — Adapter·Repository·Strategy와 일반 Feature

- [ ] [Day 08 — URLSession Adapter와 Error Mapping](day-08.md)
  **중점:** URLSession을 HTTPClient로 바꾸는 Adapter, DTO/Domain 분리, 계층별 Error mapping과 Fake
- [ ] [Day 09 — CallHistory Repository와 Pagination](day-09.md)
  **중점:** Remote+Cache CallHistoryRepository, LoadPolicy, 목록·상세·페이지네이션과 요청 중복·취소
- [ ] [Day 10 — Strategy와 검색·필터·Debounce](day-10.md)
  **중점:** Retry/debounce Strategy, 검색·필터 조합, 이전 Task 취소와 late response 무시, 주입 가능한 Clock
- [ ] [Day 11 — Explicit State와 다단계 장애 신고 Form](day-11.md)
  **중점:** 명시적 State로 모델링한 다단계 Form, 단계별 검증·draft 복원·중복 제출과 실패 복구 UX
- [ ] [Day 12 — Repository, Persistence와 Offline UX](day-12.md)
  **중점:** Repository의 Memory/Local/Remote 조합, stale fallback, 중복 fetch 공유와 Offline UX
- [ ] [Day 13 — UIKit Adapter와 Facade](day-13.md)
  **중점:** UIKit Adapter와 Facade의 역할, Representable/Coordinator를 통한 callback→Feature Action 변환
- [ ] [Day 14 — MVVM vs Action/Reducer 탐색과 UI 테스트](day-14.md)
  **중점:** 동일 검색 Feature의 MVVM vs 직접 Action/Reducer 비교와 Stub dependency 기반 핵심 XCUITest

### Week 3 — State Machine·Reducer·TCA와 시스템 이벤트

- [ ] [Day 15 — Observer와 NetworkMonitoring Adapter](day-15.md)
  **중점:** Observer와 AsyncStream, NWPathMonitor를 Domain에서 격리하는 Adapter, 구독 Task 생명주기
- [ ] [Day 16 — Call State Machine](day-16.md)
  **중점:** Domain Call State Machine, 유효하지 않거나 순서가 바뀌고 늦고 중복된 Event의 전이 정책
- [ ] [Day 17 — ActiveCall Reducer와 Audio Facade](day-17.md)
  **중점:** ActiveCall의 State/Action/Reducer/Effect와 AVAudioSession Adapter·Audio Facade 연결
- [ ] [Day 18 — Async Effect, Cancellation과 CallKit 경계](day-18.md)
  **중점:** Async Effect 실행·Task cancellation, CallKit/PushKit 이벤트 변환과 비정상 event 순서
- [ ] [Day 19 — Child Feature Composition과 Lifecycle](day-19.md)
  **중점:** ActiveCall parent/child Feature composition, lifecycle·권한 callback을 Reducer Action으로 처리
- [ ] [Day 20 — TCA 기본과 품질 Dashboard](day-20.md)
  **중점:** 직접 Reducer 뒤 TCA State/Action/Reducer/Store/Dependency를 적용하고 품질 Strategy를 격리
- [ ] [Day 21 — TCA Testing·Scoping과 통합 Failure Drill](day-21.md)
  **중점:** TCA TestStore·child scoping, MVVM/직접 Reducer/TCA 비교와 다중 시스템 Failure Drill

### Week 4 — Production-ready Architecture와 운영 품질

- [ ] [Day 22 — Shared State와 Localization](day-22.md)
  **중점:** local/feature/shared/persistent/server state 소유권 구분과 String Catalog 기반 Localization
- [ ] [Day 23 — Error Architecture와 접근성 실기기 점검](day-23.md)
  **중점:** Infrastructure→Domain→Presentation Error architecture와 VoiceOver·Dynamic Type 실기기 검증
- [ ] [Day 24 — Task Ownership, Cancellation과 Instruments](day-24.md)
  **중점:** Task ownership/cancellation 계약을 테스트하고 Instruments로 CPU·메모리·누수를 측정
- [ ] [Day 25 — Decorator, Diagnostics와 사용자 피드백](day-25.md)
  **중점:** Logging/Retry/Metrics Decorator와 production diagnostics, 상태를 설명하는 사용자 feedback
- [ ] [Day 26 — Architecture Refactoring 시험](day-26.md)
  **중점:** Characterization test 뒤 Adapter·Repository·Policy·State Machine·Navigation을 점진 추출
- [ ] [Day 27 — 테스트 Architecture와 CI](day-27.md)
  **중점:** 단위/통합/UI 테스트 경계와 PR·main·nightly CI, 실패 artifact와 TestFlight 내부 배포
- [ ] [Day 28 — Environment Factory와 실기기 테스트](day-28.md)
  **중점:** 환경별 Dependency Factory와 기기·네트워크·오디오·권한·생명주기 실기기 테스트
- [ ] [Day 29 — 대형 Feature 변경과 Architecture 판단](day-29.md)
  **중점:** 대형 Feature composition에서 parent/shared state를 판단하며 실무 요구 변경과 PR을 완주
- [ ] [Day 30 — 장애 수정과 Architecture Decision Record](day-30.md)
  **중점:** 장애 재현·회귀 검증 뒤 Architecture 선택 근거와 다음 전환 신호를 ADR로 작성

## 전체 과정 공통 안내

> 아래 내용은 `plan.md`의 Day별 과정 앞에 있는 공통 안내를 빠짐없이 옮긴 것이다.


# 한 달 동안 만들 통합 프로젝트

여러 개의 작은 토이 프로젝트보다, 하나의 앱을 점진적으로 확장하는 게 좋다. 임시로 `Telecom Companion`이라고 하자.

```text
Telecom Companion
├── 온보딩 및 권한 안내
├── 로그인
├── 홈 대시보드
│   ├── 요금제 정보
│   ├── 데이터 사용량
│   └── 현재 네트워크 상태
├── 통화 기록
│   ├── 목록
│   ├── 검색 및 필터
│   └── 상세 화면
├── 통화 품질
│   ├── 현재 품질
│   ├── 최근 품질 변화
│   └── 네트워크 진단
├── 통화 화면
│   ├── 발신/수신
│   ├── 연결 중
│   ├── 통화 중
│   ├── 보류
│   └── 종료
├── 장애 신고
│   ├── 다단계 Form
│   ├── 입력 검증
│   ├── 임시 저장
│   └── 전송
└── 설정
    ├── 알림
    ├── 마이크 권한
    ├── 진단 정보 수집 동의
    └── 앱 정보
```

이 앱 하나에서 일반적인 iOS 실무 요소를 대부분 연습할 수 있다.

```text
SwiftUI 화면
UIKit 연동
네트워크
비동기 처리
목록과 상세
Form
검색
오프라인
권한
내비게이션
딥링크
접근성
다국어
통화 상태 머신
AVAudioSession
CallKit
TDD
XCUITest
CI/TestFlight
```

---

# 이번 달의 두 번째 학습 축 — 아키텍처 판단력

SwiftUI에는 Apple이 지정한 공식 MVVM, Clean Architecture, VIPER 정답이 없다. SwiftUI는 특정 아키텍처를 강제하기보다, 각 데이터의 적절한 소유자를 정하고 View 계층에서 single source of truth를 유지할 수단을 제공한다.

따라서 특정 이름을 외우는 대신, 같은 앱이 요구사항과 비동기 이벤트가 늘면서 어떻게 발전하는지를 직접 경험한다.

```text
단순 SwiftUI
    ↓
Local State
    ↓
Feature Model / MVVM
    ↓
Dependency Injection
    ↓
Repository / Adapter
    ↓
Navigation State
    ↓
State Machine
    ↓
Reducer / MVI
    ↓
TCA 비교
    ↓
대형 Feature composition
    ↓
production-ready architecture 판단
```

가장 중요한 규칙은 다음과 같다.

> **화면 복잡도와 비동기 이벤트 복잡도에 맞춰 아키텍처의 강도를 높인다. 복잡성은 실제 요구사항이 생겼을 때 지불한다.**

모든 화면에 ViewModel을 만들지 않고, 모든 Feature를 TCA로 만들지도 않는다. 이 과정의 최종 앱도 Feature마다 서로 다른 강도의 구조를 의도적으로 사용한다.

| Feature | 의도적으로 선택할 구조 | 선택 이유 |
|---|---|---|
| Settings | View local state + 작은 Model | 일시적 UI 상태가 대부분 |
| Login | `@Observable` Feature Model / MVVM + DI | 비동기 요청과 검증은 있지만 이벤트 흐름은 단순 |
| CallHistory | MVVM + Repository, 이후 Reducer/TCA로 재구현 | 동일 기능 비교에 적합 |
| Diagnostics | Feature Model + `AsyncSequence` | 연속 시스템 이벤트를 구독 |
| Support | Explicit State + Router | 다단계 흐름과 draft 복원 |
| ActiveCall | State Machine + Reducer + Effect | 이벤트 순서, 중복, 취소가 중요 |
| App Navigation | 타입 안전한 Router / state-driven navigation | 딥링크와 상태 복원 필요 |

---

# 최종적으로 이해할 아키텍처 지도

```text
┌───────────────────────────────────────┐
│              SwiftUI View             │
│       @State / @Binding / Observation │
└──────────────────┬────────────────────┘
                   │ Action
                   ▼
┌───────────────────────────────────────┐
│              Feature Layer            │
│ FeatureModel / Reducer / StateMachine │
│          State / Action / Effect       │
└───────────────┬──────────┬────────────┘
                │          │
                ▼          ▼
        ┌─────────────┐  ┌──────────────┐
        │ UseCase /   │  │ Navigation   │
        │ Policy      │  │ Router       │
        └──────┬──────┘  └──────────────┘
               │
               ▼
┌───────────────────────────────────────┐
│               Domain                  │
│ Entity / Value / StateMachine / Policy│
└──────────────────┬────────────────────┘
                   │ Protocol
                   ▼
┌───────────────────────────────────────┐
│        Infrastructure / Adapter        │
│ URLSession / NWPath / Audio / CallKit │
│ PushKit / Persistence / Analytics      │
└───────────────────────────────────────┘
```

화살표는 의존성 방향이다. Domain은 `NWPath`, `CXCall`, `AVAudioSession`, HTTP DTO 같은 구체적인 플랫폼 타입을 알지 않는다. 단, 단순한 Feature에 사용하지 않는 UseCase나 Mapper 계층을 미리 만들지는 않는다.

---

# 반복해서 적용할 디자인 패턴

GoF 패턴을 전부 암기하지 않는다. Telecom Companion의 실제 요구를 해결할 때 다음 패턴을 반복해서 사용하고, 패턴 이름보다 도입 전후의 비용과 효과를 설명할 수 있게 한다.

| 패턴 | 이 앱에서의 연습 위치 | 우선순위 |
|---|---|---:|
| Dependency Injection | API, Clock, UUID, Logger, System API | ★★★★★ |
| Adapter | URLSession, NWPathMonitor, AVAudioSession, CallKit | ★★★★★ |
| State | 로그인, 장애 신고, 통화 상태 | ★★★★★ |
| Observer | Observation, Notification, `AsyncStream` | ★★★★★ |
| Strategy | Retry, 통화 품질 분류, Audio route 정책 | ★★★★★ |
| Repository | 통화 기록의 Remote + Cache + Persistence | ★★★★ |
| Coordinator / Router | Navigation, Deep Link | ★★★★ |
| Facade | Audio 관련 여러 Apple API 묶기 | ★★★★ |
| Factory | Development / Staging / Production dependency 조립 | ★★★ |
| Command | 사용자 Action과 시스템 Event | ★★★ |
| Decorator | Logging, Retry, Metrics, Cache | ★★★ |
| Composite | Parent / Child Feature composition | ★★★ |
| Singleton | 기존 코드에서 발견하고 숨은 의존성을 식별 | ★★ |

반드시 직접 구현할 핵심은 **DI + Adapter + State + Strategy + Repository**다. Decorator, Facade, Factory는 실제로 횡단 관심사나 환경 구성이 필요해지는 시점에만 추가한다.

---

# 상태 관리 강도 선택 기준

## Level 0 — View Local State

```swift
struct LoginView: View {
    @State private var email = ""
    @State private var isPasswordVisible = false
}
```

TextField 입력, focus, animation, sheet, 현재 선택처럼 View와 자식만 사용하는 일시적 상태에 적합하다. 공유 가능성이 있다는 이유만으로 App 전역 상태에 올리지 않는다.

## Level 1 — Feature Model / MVVM

```swift
@MainActor
@Observable
final class LoginModel {
    var email = ""
    var password = ""
    private(set) var state: State = .idle

    private let authClient: AuthClient
}
```

비동기 작업, 검증, Repository 호출이 있는 일반적인 Login, Profile, Home, CRUD 기능에 적합하다. Feature Model은 해당 Feature만 담당하며, Navigation·Analytics·Persistence·System API를 무제한으로 흡수하는 Massive ViewModel이 되지 않게 한다.

## Level 2 — Explicit State

서로 배타적인 상태가 늘면 Boolean 조합을 enum으로 바꾼다.

```swift
enum State {
    case idle
    case loading
    case loaded([Call])
    case empty
    case failed(DisplayError)
}
```

불가능한 상태를 표현하지 못하게 만들고 상태별 Preview와 전이 테스트를 작성한다.

## Level 3 — Action 기반 Feature

기능의 상태 변경 입구를 하나로 모은다.

```swift
enum Action {
    case appeared
    case retryTapped
    case searchChanged(String)
    case callSelected(Call.ID)
    case responseReceived(Result<[Call], CallHistoryError>)
}

func send(_ action: Action)
```

Action은 사용자 입력뿐 아니라 dependency 응답과 시스템 이벤트도 표현한다. View가 Feature state를 임의로 수정하지 않게 하고, 이벤트 기록을 읽으면 무슨 일이 있었는지 알 수 있게 한다.

## Level 4 — Reducer / MVI

```text
State + Action
      ↓
   Reducer
      ↓
New State + Effect
```

상태 변화와 실행할 Effect를 명시적으로 분리한다. 이벤트 순서, 중복 callback, late callback, cancellation이 중요한 ActiveCall, Upload, Sync 같은 Feature에 적합하다.

직접 만든 작은 Reducer로 먼저 다음 문제를 경험한다.

```text
상태 변화 위치 통제
Effect가 다시 Action을 보내는 흐름
Task 식별과 cancellation
Parent / Child Feature 조합
```

## Level 5 — TCA 비교와 Feature Composition

직접 Reducer를 구현한 뒤 동일한 `CallHistoryFeature`를 TCA로 한 번 더 만든다.

```text
Version A
SwiftUI + @Observable + MVVM + Repository + DI

Version B
TCA State + Action + Reducer + Effect + Dependency + Store
```

TCA는 `State`, `Action`, `Reducer`, `Store`, dependency와 effect를 일관된 도구로 제공하고, child store scoping과 `TestStore` 기반 테스트를 지원한다. 이 과정에서는 라이브러리 매크로를 외우는 대신 다음을 비교한다.

```text
코드와 개념 비용
상태 전이 가시성
async cancellation
navigation
child feature composition
dependency override
테스트 실패 메시지
팀 전체가 얻는 일관성
```

비교 뒤에도 모든 Feature를 TCA로 이전하지 않는다. 이 프로젝트에서 TCA는 “정답”이 아니라 Reducer architecture를 조직적으로 채택할 때 평가할 선택지다.

---

# Production-ready 판단 질문

Feature를 완료할 때 이름 붙은 계층의 개수보다 다음 질문에 답할 수 있는지를 본다.

```text
변경 가능한 State의 소유자는 누구인가?
어떤 State가 local / feature / shared / persistent / server state인가?
사용자 Action과 system Event는 어디로 들어오는가?
Side effect는 어느 경계에서 실행되는가?
Task는 누가 만들고 언제 cancel하는가?
System API 타입이 Domain까지 새고 있지 않은가?
Remote, cache, persistence 선택은 누가 담당하는가?
Infrastructure Error가 Domain과 사용자 메시지로 어디서 변환되는가?
딥링크를 포함한 Navigation state는 누가 소유하는가?
Logging, Metrics, Retry가 core logic와 분리되어 있는가?
실제 서버나 Apple Framework 없이 상태 전이를 테스트할 수 있는가?
현재 요구보다 많은 추상화를 미리 만들지는 않았는가?
```

---

# 추천 프로젝트 구조

처음부터 거대한 Clean Architecture를 만들기보다 **Feature-first + 명확한 시스템 경계**를 권한다.

```text
TelecomCompanion/
├── App/
│   ├── TelecomCompanionApp.swift
│   ├── AppRouter.swift
│   ├── AppSession.swift
│   └── CompositionRoot.swift
│
├── Core/
│   ├── Networking/
│   ├── Persistence/
│   ├── DesignSystem/
│   ├── Logging/
│   └── TestingSupport/
│
├── SystemAdapters/
│   ├── NetworkPathAdapter/
│   ├── AudioSessionAdapter/
│   ├── CallKitAdapter/
│   └── NotificationAdapter/
│
├── Domain/
│   ├── CallStateMachine.swift
│   ├── QualityPolicy.swift
│   └── RetryPolicy.swift
│
├── Data/
│   ├── CallHistoryRepository.swift
│   ├── Cache/
│   └── DTO/
│
├── Features/
│   ├── Onboarding/
│   ├── Login/
│   ├── Home/
│   ├── CallHistory/
│   ├── CallQuality/
│   ├── Diagnostics/
│   ├── Support/
│   ├── ActiveCall/
│   └── Settings/
│
└── Tests/
```

이 구조는 첫날 만들 빈 폴더 목록이 아니라 한 달 동안 실제 필요가 생길 때 도달할 수 있는 결과다. 예를 들어 Login이 단순한 동안에는 별도 UseCase가 필요 없고, `LoginModel → AuthClient`만으로 충분할 수 있다.

하나의 Feature 내부는 이 정도면 충분하다.

```text
Features/Login/
├── LoginView.swift
├── LoginModel.swift
├── LoginState.swift
├── LoginClient.swift
└── LoginModelTests.swift
```

프로젝트 전체를 다음처럼 나누는 구조는 피하는 편이 좋다.

```text
Views/
ViewModels/
Models/
Services/
Utilities/
```

처음에는 편하지만, 기능이 늘어나면 로그인 관련 코드가 여러 디렉터리에 흩어져 변경 범위를 파악하기 어려워진다.

---

# SwiftUI 상태 관리 기준

화면 상태를 여러 개의 Boolean으로 표현하지 않는다.

```swift
// 피해야 할 형태
var isLoading = false
var hasError = false
var isEmpty = false
var showRetry = false
var isContentVisible = false
```

대신 상호 배타적인 상태는 명시적으로 모델링한다.

```swift
enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case failed(DisplayError)
}
```

Feature는 대략 다음 방향으로 만든다.

```swift
@MainActor
@Observable
final class CallHistoryModel {
    enum Action {
        case appeared
        case retryTapped
        case searchChanged(String)
        case callSelected(Call.ID)
    }

    private(set) var calls: Loadable<[Call]> = .idle
    var searchText = ""

    private let client: CallHistoryClient

    init(client: CallHistoryClient) {
        self.client = client
    }

    func send(_ action: Action) async {
        // 상태 전이 및 side effect
    }
}
```

최소 지원 버전이 iOS 17 이상이면 Observation의 `@Observable`, `@State`, `@Bindable`을 연습하고, 더 낮은 버전을 지원하거나 기존 프로젝트가 Combine 기반이면 `ObservableObject`, `@StateObject`, `@ObservedObject`도 함께 읽을 수 있어야 한다. SwiftUI는 각 데이터에 단일 source of truth를 두고, 데이터 소유권에 따라 State나 Binding 등을 선택하도록 설계되어 있다.

---

# UI 개발에서 TDD를 적용하는 방법

SwiftUI의 `VStack` 개수나 modifier 순서를 단위 테스트로 검증하는 것은 좋은 TDD가 아니다.

UI 기능은 세 층으로 나누어 검증한다.

## 1. 상태와 행동: Swift Testing

가장 많은 테스트를 둔다.

```text
입력 검증
버튼 활성화 조건
Loading/Error/Empty 상태
API 성공과 실패
중복 탭
검색 debounce
Task cancellation
화면 이탈 후 늦은 응답
Navigation 의도
Alert/Sheet 표시 조건
권한 거부 처리
```

예를 들어 로그인 화면이라면:

```text
Given 잘못된 이메일
When 로그인 버튼 선택
Then 인증 API를 호출하지 않는다
And 이메일 오류를 표시한다

Given 정상 입력
When 로그인 버튼을 두 번 빠르게 선택
Then 인증 API는 한 번만 호출된다

Given 로그인 요청 중 화면을 닫음
When 서버 응답이 늦게 도착
Then 다음 화면으로 이동하지 않는다
```

## 2. 시각 상태: Preview

각 화면에 최소한 다음 Preview를 만든다.

```text
Loading
Content
Empty
Error
Offline
Dark Mode
큰 Dynamic Type
긴 한국어 또는 영어 문장
작은 화면
```

Xcode Preview는 SwiftUI뿐 아니라 UIKit 화면도 다양한 기기, 방향, 색상 모드와 Dynamic Type 설정으로 확인할 수 있다.

## 3. 사용자 흐름: XCUITest

다음과 같은 핵심 흐름에만 둔다.

```text
로그인 → 홈
통화 기록 검색 → 상세
장애 신고 작성 → 제출
수신 통화 → 응답 → 종료
권한 거부 → 설정 안내
```

Apple은 신규 단위 테스트에는 Swift Testing을 고려하도록 안내하지만, UI 테스트와 성능 테스트는 계속 XCTest를 사용하도록 권장한다.

권장 비율은 대략 다음 정도다.

```text
단위 테스트       70%
통합 테스트       20%
UI 테스트         10%
```

정확한 수치가 규칙은 아니고, 빠르고 안정적인 테스트를 아래에 많이 두겠다는 의미다.

---

# 하루 학습 루틴

하루 3시간 기준이다.

| 시간 | 활동 |
|---:|---|
| 20분 | 사용자 시나리오와 화면 상태 작성 |
| 40분 | 실패하는 단위 테스트 작성 |
| 70분 | 최소 구현으로 테스트 통과 |
| 30분 | SwiftUI 화면 및 Preview 구현 |
| 20분 | 실패·취소·중복·빈 상태 추가 |
| 20분 | 리팩터링 및 학습 기록 |

화면을 만들기 전에 항상 다음을 적는다.

```text
이 화면에 누가 들어오는가?
사용자의 목표는 무엇인가?
어떤 상태가 존재하는가?
무엇이 실패할 수 있는가?
사용자가 중간에 나가면 어떻게 되는가?
네트워크가 없으면 어떻게 되는가?
VoiceOver나 큰 글씨에서는 어떻게 보이는가?
```

---


## 전체 과정 공통 연습과 완료 기준

> 아래 내용은 `plan.md`의 Day 30 뒤에 있는 공통 과제, 화면 완료 기준, 안티패턴, 최종 산출물 목표다.

# 세 번씩 반복할 UI TDD 과제

| 패턴 | 1회차 | 2회차 | 3회차 |
|---|---|---|---|
| Form validation | 로그인 | 장애 신고 | 설정 변경 |
| Loading 상태 | 홈 | 통화 기록 | 품질 진단 |
| 검색과 취소 | 통화 기록 | 도움말 | 가입자 검색 |
| Pagination | 통화 기록 | 공지 목록 | 품질 이력 |
| Navigation | 목록→상세 | 딥링크 | 로그인 후 목적지 복원 |
| Permission flow | 알림 | 마이크 | 진단 정보 동의 |
| Offline UX | Home cache | 통화 기록 | 신고 draft |
| State machine | 다단계 Form | 통화 상태 | 진단 진행 상태 |
| 중복 처리 | 로그인 | 신고 제출 | Call action |
| Timeout | 검색 debounce | API timeout | 통화 연결 timeout |

반복 방식은 다음과 같다.

```text
1회차:
요구사항과 예제를 보면서 구현

2회차:
2~3일 뒤 코드를 보지 않고 다시 구현

3회차:
의도적으로 나쁜 기존 코드에
characterization test를 추가하며 리팩터링
```

---

# 화면 하나의 완료 기준

모든 화면에 무조건 적용할 필요는 없지만, 주요 화면은 이 기준을 통과시키는 게 좋다.

```text
[ ] Loading 상태가 있다
[ ] Empty 상태가 있다
[ ] Error와 Retry가 있다
[ ] Offline 동작이 정의되어 있다
[ ] 중복 사용자 입력을 처리한다
[ ] 화면 종료 시 Task가 취소된다
[ ] 긴 문자열에서도 깨지지 않는다
[ ] Dark Mode를 확인했다
[ ] Dynamic Type을 확인했다
[ ] VoiceOver를 확인했다
[ ] 핵심 상태별 Preview가 있다
[ ] 상태 전이 단위 테스트가 있다
[ ] 중요 흐름이면 XCUITest가 있다
[ ] 사용자 문자열이 하드코딩되어 있지 않다
```

---

# UI 쪽에서 특히 피해야 할 안티패턴

| 안티패턴 | 문제 | 대안 |
|---|---|---|
| 500줄짜리 `body` | 상태와 레이아웃을 이해하기 어려움 | 의미 있는 Section과 컴포넌트로 분리 |
| 거대한 `AppViewModel` | 모든 화면이 서로 영향을 받음 | Feature별 상태 소유 |
| `onAppear`마다 API 호출 | 화면 재계산·재진입 시 중복 요청 | idempotent한 load action과 Task 소유권 |
| 여러 Boolean으로 화면 상태 표현 | 불가능한 조합 생성 | enum state |
| View에서 URLSession 직접 호출 | 테스트와 취소 관리 어려움 | Feature model + Client |
| Singleton 남용 | dependency가 숨겨짐 | Composition root에서 주입 |
| 모든 View를 공용 컴포넌트화 | 오히려 변경하기 어려움 | 2~3회 반복된 패턴부터 추출 |
| 모든 타입에 Protocol | 추상화 비용만 증가 | 외부 side effect 경계 중심 |
| 모든 요청에 UseCase/Repository/Mapper 계층 | 파일과 전달 코드만 늘어남 | 요구가 생긴 경계부터 점진 추출 |
| 모든 Feature에 TCA 적용 | 단순 화면에도 개념·도구 비용 발생 | 이벤트 복잡도와 팀 규모로 채택 판단 |
| Domain에서 Apple/HTTP 타입 사용 | 시스템 변경과 테스트가 Domain까지 전파 | Adapter에서 앱의 언어로 변환 |
| 모든 상태를 AppState에 저장 | 소유권과 생명주기가 불명확해짐 | local/feature/shared/persistent/server 구분 |
| modifier 순서를 unit test | 구현 세부사항에 테스트 결합 | 상태와 사용자 행동 테스트 |
| 모든 로직을 XCUITest로 검사 | 느리고 flaky함 | 단위 테스트 중심 |
| 화면 성공 상태만 구현 | 실제 장애에서 UX 붕괴 | Loading/Empty/Error/Offline |
| `Task {}` 무분별 생성 | 취소와 lifecycle 불명확 | Task 소유자와 취소 시점 명시 |
| `GeometryReader` 남용 | 예측하기 어려운 레이아웃 | 기본 Layout과 container 우선 |
| UIKit을 무조건 SwiftUI로 재작성 | 숨은 동작과 회귀 위험 | Adapter로 점진 통합 |
| 디자인 시스템을 먼저 거대하게 구축 | 실제 요구 없이 과설계 | 최소 token과 반복 컴포넌트부터 |

---

# 한 달 뒤 산출물 목표

현실적인 목표는 이 정도다.

```text
8개 전후의 실제 화면
4가지 이상의 목록·Form·상세 패턴
각 주요 화면의 Loading/Empty/Error 상태
40~60개의 빠른 단위 테스트
10개 전후의 경계 중심 통합 테스트
3~5개의 핵심 XCUITest
UIKit ↔ SwiftUI 연동 1개
MVVM과 Reducer로 같은 Feature 구현·비교 기록
직접 만든 작은 Reducer와 Effect 실행기
TCA Feature 1개와 TestStore 테스트
NWPathMonitor adapter
AVAudioSession adapter
Call state machine
CallKit adapter의 기본 구조
Remote + Cache CallHistoryRepository
Retry/Quality Strategy
Logging/Retry/Metrics Decorator
한국어/영어 String Catalog
접근성 점검 기록
Instruments 분석 기록
GitHub Actions → TestFlight 배포
모의 PR 2개
Architecture Decision Record 1개
```

핵심은 **“SwiftUI로 예쁜 화면을 빨리 만드는 사람”**에 그치지 않는 것이다.

한 달 동안 반복해서 만들어야 하는 능력은 다음이다.

```text
사용자 요구
→ 화면 상태 정의
→ 실패 테스트
→ 상태 및 정책 구현
→ SwiftUI 렌더링
→ Preview 시각 검증
→ 시스템 API Adapter 연결
→ 복잡도에 맞는 Feature architecture 선택
→ XCUITest 핵심 흐름
→ 실기기와 Instruments 검증
```

한 달 뒤에는 패턴 이름을 나열하는 것보다 다음과 같은 판단을 할 수 있어야 한다.

```text
이 값은 전역이 아니라 View local state다.
이 ViewModel은 커졌지만 먼저 State Machine 하나만 추출하면 된다.
이 API는 Repository보다 단순 Adapter면 충분하다.
CallKit callback이 Domain까지 새고 있으니 앱 event로 변환해야 한다.
이 Feature는 이벤트 순서와 취소가 중요하므로 Reducer가 잘 맞는다.
이 Task의 소유자와 cancel 시점이 불명확하다.
TCA의 일관성이 현재 팀 규모에서 추가 비용보다 큰 가치가 있는가?
```

이 흐름에 익숙해지면 일반적인 고객용 UI 기능과 통화·네트워크처럼 비동기 이벤트가 복잡한 기능을 같은 설계 원칙으로 다룰 수 있다.
