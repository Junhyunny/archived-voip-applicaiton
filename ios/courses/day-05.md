# Course Day 05 — Navigation State와 Router

[이전 Day](day-04.md) · [전체 진도](day-00.md) · [다음 Day](day-06.md)

- [ ] Day 05 완료

## 중점 학습

- Navigation도 state라는 관점, 타입 안전한 Router, 딥링크, 인증 전후 목적지 복원과 중복 Route 방지

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 5 — Navigation State와 Router

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
Coordinator / Router 패턴
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

Navigation도 state다. View가 destination View를 임의로 조립하는 데 그치지 않고 `Router.path`를 source of truth로 두어 push, deep link, 인증 후 목적지 복원을 같은 규칙으로 처리한다.

TDD:

```text
로그인 전 보호 화면 진입 → 로그인으로 이동
로그인 후 원래 목적지 복원
존재하지 않는 통화 ID → 오류 화면
동일 route 중복 push 방지
```

---
