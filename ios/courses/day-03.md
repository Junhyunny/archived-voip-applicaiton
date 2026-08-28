# Course Day 03 — Observation과 화면 상태

[이전 Day](day-02.md) · [전체 진도](day-00.md) · [다음 Day](day-04.md)

- [ ] Day 03 완료

## 중점 학습

- Observation과 single source of truth, View local state와 `@Observable` Feature Model/MVVM의 소유권 경계

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

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
View local state와 Feature state의 경계
@Observable Feature Model / MVVM
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

이날 `HomeModel`을 도입하되, sheet 표시나 카드의 일시적인 선택 상태처럼 View에 남아야 할 값까지 옮기지 않는다.

---
