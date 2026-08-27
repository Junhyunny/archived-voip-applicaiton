
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

# 추천 프로젝트 구조

처음부터 거대한 Clean Architecture를 만들기보다 **Feature-first + 명확한 시스템 경계**를 권한다.

```text
TelecomCompanion/
├── App/
│   ├── TelecomCompanionApp.swift
│   ├── AppRouter.swift
│   └── DependencyContainer.swift
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

# Week 1 — SwiftUI 화면과 테스트 가능한 상태 관리

## Day 1 — 프로젝트와 테스트 기반

학습:

```text
Swift Package / Xcode target
Swift Testing
XCTest
Dependency Injection
Feature-first 구조
Composition Root
```

구현:

```text
앱 기본 구조
TabView
Home / Call History / Diagnostics / Settings 빈 화면
Test target
CI에서 unit test 실행
```

완료 조건:

```text
앱 실행 가능
모든 dependency를 App 시작 지점에서 구성
Feature 테스트에서 실제 네트워크를 사용하지 않음
```

---

## Day 2 — SwiftUI Layout과 View identity

학습:

```text
VStack / HStack / ZStack
ScrollView
List
Grid
safeAreaInset
View identity
ForEach의 안정적인 ID
```

구현:

```text
홈 대시보드
요금제 카드
데이터 사용량 카드
현재 네트워크 카드
공지 배너
```

TDD:

```text
데이터가 모두 있으면 카드가 표시될 상태 생성
사용량 데이터가 없으면 unavailable 상태
사용량 100% 이상이면 경고 상태
오래된 데이터면 stale 표시
```

여기서는 View 자체보다 `HomeViewState` 생성 규칙을 테스트한다.

---

## Day 3 — Observation과 화면 상태

학습:

```text
@State
@Binding
@Observable
@Bindable
@Environment
화면이 상태를 소유하는 경우
부모에게 상태를 전달받는 경우
```

구현:

```text
Home 화면 API 로딩
Loading
Content
Empty
Error
Retry
```

SwiftUI는 모델 데이터의 변경에 따라 의존하는 화면 부분을 다시 계산하므로, 어떤 상태를 어느 View가 읽는지가 중요하다. 모든 앱 상태를 하나의 거대한 전역 객체에 넣지 말고 Feature 단위 source of truth를 둔다. 

---

## Day 4 — Login Form과 입력 검증

학습:

```text
TextField
SecureField
Form
FocusState
Keyboard submit
입력 오류 표시
버튼 활성화 조건
```

구현:

```text
이메일
비밀번호
로그인 버튼
서버 오류 배너
Loading indicator
```

TDD:

```text
빈 이메일
잘못된 이메일 형식
빈 비밀번호
로그인 성공
잘못된 인증 정보
서버 오류
두 번 연속 버튼 선택
로그인 중 화면 종료
```

`FocusState`로 유효하지 않은 입력 필드에 포커스를 이동하는 연습도 한다. 

---

## Day 5 — Navigation과 Deep Link

학습:

```text
NavigationStack
navigationDestination
TabView
Sheet
Full-screen cover
Alert
Deep link
Navigation state restoration 개념
```

구현:

```text
홈 → 사용량 상세
통화 목록 → 통화 상세
알림 선택 → 특정 통화 상세
딥링크 → 장애 신고 화면
```

Route를 문자열로 관리하지 않는다.

```swift
enum AppRoute: Hashable {
    case callDetail(Call.ID)
    case usageDetail
    case diagnostics
    case supportReport(category: ReportCategory?)
}
```

SwiftUI는 `NavigationStack`과 `TabView`를 기본 내비게이션 구조로 제공하며, 데이터 기반 destination을 통해 딥링크와 상태 복원 가능한 구조를 만들 수 있다. 

TDD:

```text
로그인 전 보호 화면 진입 → 로그인으로 이동
로그인 후 원래 목적지 복원
존재하지 않는 통화 ID → 오류 화면
동일 route 중복 push 방지
```

---

## Day 6 — Design System과 접근성

Design System은 거대한 별도 프레임워크가 아니라 다음부터 시작한다.

```text
Spacing
Typography
Color semantics
Button styles
Text field styles
Card
Error banner
Loading indicator
Empty state
```

색상 이름은 시각적 색이 아니라 의미로 짓는다.

```text
좋음:
textPrimary
surfaceElevated
statusWarning
actionPrimary

피해야 함:
gray700
prettyBlue
darkCardColor
```

Apple HIG의 Foundations, Patterns, Components를 기준으로 시스템 컴포넌트를 먼저 사용하고, 제품 요구가 명확한 부분만 커스텀한다. 

접근성 확인:

```text
VoiceOver label
VoiceOver reading order
Dynamic Type
버튼의 충분한 터치 영역
색상만으로 상태를 전달하지 않기
Reduce Motion
Dark Mode
```

SwiftUI 기본 컨트롤은 기본 접근성 정보를 제공하지만, 커스텀 카드나 차트, UIKit wrapper는 직접 label과 value를 보완해야 한다. 

---

## Day 7 — 첫 번째 재구현

코드를 보지 않고 다시 만든다.

```text
Login
Home dashboard
AppRoute
Loadable 상태
```

이번에는 일부 요구를 변경한다.

```text
로그인에 OTP 단계 추가
Home에 offline 상태 추가
통화 상세 딥링크 추가
```

TDD 반복의 목적은 완성 코드를 외우는 것이 아니라, 요구사항을 상태와 테스트로 변환하는 습관을 만드는 것이다.

---

# Week 2 — 일반 사용자용 앱 기능

## Day 8 — URLSession과 화면 상태 연결

구현:

```text
CallHistoryClient
DTO
Domain Model
Error mapping
Fake client
```

TDD:

```text
200 정상 응답
빈 목록
401
429
500
잘못된 JSON
timeout
cancellation
```

화면에서 `URLError`나 HTTP status를 직접 분기하지 않는다.

```swift
enum CallHistoryError {
    case unauthorized
    case temporarilyUnavailable
    case offline
    case invalidResponse
}
```

사용자 메시지는 기술 오류와 분리한다.

```text
기술 오류:
URLError.notConnectedToInternet

사용자 메시지:
네트워크에 연결할 수 없습니다.
연결 상태를 확인하고 다시 시도해 주세요.
```

---

## Day 9 — 목록·상세·Pagination

구현:

```text
통화 기록 목록
날짜별 Section
Pull to refresh
무한 스크롤
통화 상세
```

TDD:

```text
첫 페이지 로딩
다음 페이지 로딩
마지막 페이지 이후 요청하지 않음
refresh 중 기존 pagination 취소
동일 데이터 중복 제거
pagination 오류 후 retry
화면 종료 시 요청 취소
```

UI 확인:

```text
0건
1건
1,000건
매우 긴 사용자 이름
번호가 없는 통화
삭제된 사용자
```

---

## Day 10 — 검색·필터·Debounce

구현:

```text
전화번호 또는 이름 검색
수신/발신/부재중 필터
기간 필터
최근 검색어
```

TDD:

```text
빈 검색어는 전체 목록
300ms 동안 입력이 없을 때 검색
새 입력이 오면 이전 검색 취소
이전 요청이 늦게 도착해도 최신 결과 유지
필터와 검색어 동시 적용
```

실제 300ms를 기다리는 테스트는 만들지 않는다. Clock 또는 Debouncer를 주입해 즉시 진행 가능한 테스트를 만든다.

---

## Day 11 — 다단계 장애 신고 Form

구현:

```text
1단계: 문제 유형
2단계: 발생 시점과 위치
3단계: 증상 설명
4단계: 진단 정보 첨부 동의
5단계: 제출 확인
```

TDD:

```text
필수 입력 검증
이전 단계 이동 시 입력 보존
앱 종료 후 draft 복원
중복 제출 방지
제출 실패 후 입력 보존
제출 성공 후 draft 삭제
```

UX 연습:

```text
오류를 Alert 하나로만 표시하지 않기
문제가 있는 입력 가까이에 설명 표시
오류 발생 시 해당 필드로 포커스
작성 중 나가기 전에 확인
제출 중 버튼 비활성화
```

---

## Day 12 — Persistence와 Offline UX

구현:

```text
마지막 통화 품질 결과 저장
통화 기록 cache
장애 신고 draft
설정 저장
```

TDD:

```text
cache가 있으면 우선 표시
백그라운드에서 최신 데이터 갱신
cache가 오래됐으면 stale 표시
offline에서 마지막 데이터 표시
저장 데이터 손상 시 안전하게 초기화
```

화면은 다음을 구분해야 한다.

```text
데이터가 없음
아직 데이터를 불러오지 않음
오프라인이지만 이전 데이터가 있음
오프라인이고 이전 데이터도 없음
```

---

## Day 13 — UIKit 읽기와 SwiftUI 연동

학습:

```text
UIView
UIViewController
viewDidLoad
viewWillAppear
UITableView / UICollectionView 개념
Auto Layout
Delegate
Target-action
Coordinator
```

실습:

```text
UIKit으로 만든 간단한 품질 차트 View
SwiftUI에서 UIViewRepresentable로 사용
UIKit delegate 이벤트를 Coordinator로 전달
화면 제거 시 observer와 delegate 정리
```

`UIViewRepresentable`과 `UIViewControllerRepresentable`은 UIKit 객체를 SwiftUI에 넣는 공식 경계다. UIKit에서 발생한 delegate나 target-action 이벤트는 Coordinator를 통해 SwiftUI 쪽으로 전달할 수 있다. 

TDD:

```text
새 데이터 입력 시 adapter 업데이트
동일 데이터면 불필요한 업데이트 방지
UIKit callback이 Feature action으로 변환
화면 제거 후 callback 무시
```

---

## Day 14 — UI 테스트 주간 정리

XCUITest 3개를 만든다.

```text
로그인 성공 → 홈 표시
통화 검색 → 상세 진입
장애 신고 작성 → 제출 성공
```

테스트 전용 launch argument를 사용한다.

```text
-ui-testing
-stub-scenario login-success
-stub-scenario call-history-empty
-stub-scenario support-submit-failure
```

UI 테스트가 실제 서버에 의존하지 않도록 앱 시작 시 Stub dependency를 주입한다.

---

# Week 3 — 통신 기능과 Call UX 결합

## Day 15 — 네트워크 상태 UI

학습:

```text
NWPathMonitor
Wi-Fi / Cellular
expensive
constrained
offline
AsyncStream
```

구현:

```text
현재 네트워크 상태 카드
네트워크 전환 배너
진단 화면
```

TDD:

```text
Wi-Fi → Cellular
Cellular → Offline
중복 path event
앱 background 이후 event
화면 종료 시 monitoring 중단
```

Domain에는 `NWPath`를 직접 노출하지 않는다.

```swift
enum Connectivity: Equatable, Sendable {
    case offline
    case wifi(isConstrained: Bool)
    case cellular(isConstrained: Bool)
    case other
}
```

---

## Day 16 — 통화 상태 머신과 통화 화면

먼저 화면을 만들지 말고 상태 전이를 테스트한다.

```swift
enum CallPhase: Equatable {
    case idle
    case incoming
    case dialing
    case connecting
    case active
    case held
    case reconnecting
    case ending
    case ended
    case failed(CallFailure)
}
```

이벤트:

```text
incomingReceived
answerRequested
transportConnected
audioActivated
holdRequested
networkLost
networkRecovered
remoteEnded
timeout
```

구현할 UI:

```text
Incoming Call
Outgoing Call
Connecting
Active Call
Held
Reconnecting
Call Ended
Call Failed
```

TDD:

```text
incoming → answer → connecting
connecting → audio activated → active
active → network lost → reconnecting
reconnecting → recovered → active
remote end 중복 이벤트
종료 후 늦게 도착한 audio activated
```

---

## Day 17 — AVAudioSession과 오디오 Route UX

학습:

```text
microphone permission
audio category/mode
speaker
receiver
Bluetooth
wired headset
route change
interruption
```

구현:

```text
오디오 출력 선택 Sheet
현재 route 표시
마이크 권한 거부 안내
interruption 상태 배너
```

TDD:

```text
통화 시작 시 audio configuration 요청
이어폰 제거 시 fallback route 정책
Bluetooth 연결
권한 거부
interruption began
interruption ended + shouldResume
통화 종료 후 route event 무시
```

시스템 API 자체가 아닌 **정책과 adapter 변환**을 테스트한다.

```text
AVAudioSession notification
        ↓
AudioSessionAdapter
        ↓
AudioEvent
        ↓
CallSessionModel
        ↓
Call UI State
```

---

## Day 18 — CallKit과 PushKit 경계

구현 범위:

```text
CallKit adapter
수신 통화 보고
발신 통화 요청
Answer/End/Hold action 변환
Push payload parsing
```

UI에서는 CallKit 객체를 직접 사용하지 않는다.

```text
CXAnswerCallAction
    ↓
CallKitAdapter
    ↓
CallEvent.answerRequested
```

TDD:

```text
정상 수신 payload
UUID 누락
중복 incoming push
CallKit transaction 실패
answer가 transport 준비보다 먼저 도착
remote end가 UI 표시보다 먼저 도착
```

---

## Day 19 — Lifecycle과 권한 UX

구현:

```text
Foreground
Background
전화 잠금 상태
마이크 권한
알림 권한
진단 데이터 수집 동의
```

권한 화면에서는 “허용해 주세요”만 표시하지 않는다.

```text
왜 필요한가?
허용하지 않으면 무엇이 제한되는가?
지금 요청할 필요가 있는가?
거부 후 어떤 대체 흐름이 있는가?
설정 앱으로 이동해야 하는가?
```

TDD:

```text
notDetermined → 설명 후 요청
denied → 시스템 요청 반복하지 않음
denied → 설정 이동 안내
restricted → 설정 이동 버튼 미표시
통화 시작 직전 권한 거부
```

---

## Day 20 — 품질 Dashboard와 진단 UX

구현:

```text
현재 품질 등급
RTT
Jitter
Packet loss
최근 추세
문제 가능성 설명
추천 행동
```

좋지 않은 UX:

```text
RTT: 312
Jitter: 84
Packet Loss: 7.5%
```

더 나은 방향:

```text
통화 품질이 불안정합니다.

주요 원인:
패킷 손실이 높습니다.

권장:
Wi-Fi 신호가 강한 장소로 이동하거나
셀룰러 네트워크로 전환해 보세요.
```

기술 수치와 사용자 설명을 분리한다.

```swift
struct QualityPresentation {
    let grade: QualityGrade
    let title: String
    let explanation: String
    let recommendations: [Recommendation]
}
```

`QualityPresentationFactory`를 TDD로 개발한다.

---

## Day 21 — 통합 Failure Drill

다음 순서를 Fake event로 재생한다.

```text
수신 Push
→ CallKit 보고
→ 사용자 Answer
→ 서버 연결 중
→ Wi-Fi에서 Cellular로 변경
→ Bluetooth 연결
→ 오디오 interruption
→ 서버 연결 완료
→ 통화 활성화
→ 상대방 종료
```

그리고 순서를 일부러 바꾼다.

```text
상대방 종료가 Answer보다 먼저 도착
timeout 이후 transport 연결
통화 종료 후 route 변경
화면 종료 후 network callback
end 이벤트 두 번
```

각 버그를 발견하면 다음 순서로 수정한다.

```text
재현
→ 실패 테스트
→ 최소 수정
→ 회귀 테스트
→ UI 상태 확인
```

---

# Week 4 — 제품 품질, 레거시 대응, 배포

## Day 22 — Localization

지원 언어는 우선 한국어와 영어로 한다.

검증:

```text
긴 영어 문장
매우 짧은 한국어 문장
날짜
시간
백분율
전화번호
파일 크기
복수형
```

String Catalog를 이용하면 문자열 추출, 번역, 복수형, 기기별 표현을 한곳에서 관리할 수 있다. 

피해야 할 코드:

```swift
Text("총 " + String(count) + "개의 기록")
```

선호:

```swift
Text("\(count) call records")
```

실제 표현과 복수형은 String Catalog에서 관리한다.

---

## Day 23 — 접근성 실기기 점검

VoiceOver를 켜고 다음 전체 흐름을 직접 사용한다.

```text
로그인
홈 탐색
통화 기록 검색
품질 차트 확인
장애 신고
통화 응답과 종료
```

확인할 것:

```text
읽기 순서가 자연스러운가?
아이콘만 있는 버튼에 label이 있는가?
품질을 색상만으로 구분하지 않는가?
차트가 요약 설명을 제공하는가?
오류가 발생했을 때 VoiceOver가 알 수 있는가?
큰 글씨에서 버튼이나 텍스트가 잘리지 않는가?
```

---

## Day 24 — SwiftUI 성능과 Instruments

일부러 성능 문제를 만든다.

```text
1,000개의 통화 기록
큰 이미지 목록
불필요한 전체 화면 업데이트
body 안의 무거운 계산
동일 API 반복 호출
화면 이동 후 남아 있는 Task
```

측정:

```text
SwiftUI Instrument
Time Profiler
Allocations
Leaks
Memory Graph
Core Animation
```

Lazy container를 무조건 쓰는 게 아니라, 먼저 일반 Stack으로 구현한 뒤 Instruments에서 실제 문제가 확인되면 바꾼다. Apple도 SwiftUI 성능은 Instruments로 측정하고, 성능 검증은 Simulator가 아니라 실기기에서 수행하도록 안내한다. 

---

## Day 25 — 애니메이션과 사용자 피드백

구현:

```text
Loading → Content
Empty → Content
통화 Connecting → Active
Network lost banner
Form validation
성공/실패 feedback
```

애니메이션은 장식보다 상태 변화를 이해시키는 용도로 사용한다.

```text
좋음:
선택 상태 변화
화면 계층 전환
오류 위치 안내
통화 연결 상태 변화

피해야 함:
모든 목록 항목에 과도한 등장 애니메이션
네트워크 응답을 기다리게 만드는 연출
Reduce Motion을 무시한 움직임
```

SwiftUI animation은 특정 상태값 변경과 연결해서 적용하는 방식으로 이해하는 게 좋다. 

---

## Day 26 — 레거시 UIKit/SwiftUI 코드 리팩터링

일부러 거대한 클래스를 만든다.

```swift
final class CallViewModel {
    // Navigation
    // URLSession
    // CallKit
    // AVAudioSession
    // UserDefaults
    // 화면 상태
    // Logger
    // Timer
    // 전부 포함
}
```

바로 전면 재작성하지 않는다.

```text
1. 현재 동작을 characterization test로 고정
2. 변경할 동작 하나 선택
3. system dependency에 seam 추가
4. 실패 테스트 작성
5. 최소 변경
6. 작은 책임 하나 추출
```

입사 후 기존 코드를 만났을 때 가장 유용한 연습이다.

---

## Day 27 — CI와 테스트 분리

```text
PR
├── Swift Testing
├── XCTest unit/integration
├── Lint
└── Build

main
├── PR 테스트
├── XCUITest smoke
└── TestFlight 내부 배포

Nightly
├── 전체 UI Test
├── 여러 기기
├── 성능 Test
└── Sanitizer
```

UI 테스트 실패 시 다음을 attachment로 남긴다.

```text
Screenshot
현재 화면 hierarchy
앱 로그
Stub scenario
실패 단계
```

---

## Day 28 — 실기기 테스트

| 영역 | 시나리오 |
|---|---|
| 화면 | 작은 iPhone, 큰 iPhone |
| Appearance | Light, Dark |
| 글자 | 기본, 큰 Dynamic Type |
| 네트워크 | Wi-Fi, Cellular, Offline, 전환 |
| 오디오 | Receiver, Speaker, Wired, Bluetooth |
| 권한 | 허용, 거부, 이전에 거부 |
| Lifecycle | Foreground, Background, 잠금 |
| 통화 | 수신, 발신, 취소, timeout, remote end |
| 언어 | 한국어, 영어 |
| 장애 | 느린 응답, 500, 중복 이벤트 |

---

## Day 29 — 실무형 기능 변경 훈련

가상의 요구사항을 받았다고 가정한다.

> 통화 품질이 Poor로 5초 이상 유지되면 사용자에게 네트워크 전환 안내를 표시한다. 다만 통화가 종료됐거나 이미 한 번 닫은 안내는 다시 표시하지 않는다.

수행:

```text
Acceptance criteria 작성
State machine 영향 확인
실패 테스트 작성
Clock 주입
UI 구현
Preview
XCUITest 한 개
PR 설명 작성
```

PR에는 다음을 포함한다.

```text
문제
사용자 영향
상태 변화
변경 내용
추가한 테스트
수동 검증
남은 위험
```

---

## Day 30 — 장애 수정 훈련과 최종 정리

다음 중 하나를 일부러 발생시킨다.

```text
화면에 다시 들어오면 API가 두 번 호출됨
검색 결과가 이전 키워드 결과로 덮어씌워짐
통화 종료 후 오디오가 계속 활성화됨
네트워크 전환 후 화면이 Connecting에 멈춤
장애 신고 버튼을 두 번 눌러 두 번 제출됨
통화 상세 화면에서 메모리 누수
```

수정 순서:

```text
재현 조건 고정
로그 확인
실패 테스트 작성
원인 가설
최소 수정
회귀 테스트
Instruments 또는 실기기 재검증
```

---

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
3~5개의 핵심 XCUITest
UIKit ↔ SwiftUI 연동 1개
NWPathMonitor adapter
AVAudioSession adapter
Call state machine
CallKit adapter의 기본 구조
한국어/영어 String Catalog
접근성 점검 기록
Instruments 분석 기록
GitHub Actions → TestFlight 배포
모의 PR 2개
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
→ XCUITest 핵심 흐름
→ 실기기와 Instruments 검증
```

이 흐름에 익숙해지면 일반적인 고객용 UI 기능과 통화·네트워크처럼 비동기 이벤트가 복잡한 기능을 같은 설계 원칙으로 다룰 수 있다.