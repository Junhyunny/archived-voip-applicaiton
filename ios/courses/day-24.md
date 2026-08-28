# Course Day 24 — Task Ownership, Cancellation과 Instruments

[이전 Day](day-23.md) · [전체 진도](day-00.md) · [다음 Day](day-25.md)

- [ ] Day 24 완료

## 중점 학습

- Task ownership/cancellation 계약을 테스트하고 Instruments로 CPU·메모리·누수를 측정

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 24 — Task Ownership, Cancellation과 Instruments

일부러 성능 문제를 만든다.

```text
1,000개의 통화 기록
큰 이미지 목록
불필요한 전체 화면 업데이트
body 안의 무거운 계산
동일 API 반복 호출
화면 이동 후 남아 있는 Task
```

성능 측정 전에 다음 cancellation 계약을 테스트한다.

```text
화면 종료 → feature-scoped Task cancel
검색어 변경 → 이전 검색 cancel
통화 종료 → transport/audio/network Task cancel
로그아웃 → user-scoped Task cancel
cancel 이후 late callback → state 변경 없음
```

각 Task의 생성자, ID, 종료 조건을 기록한다. 단순히 `deinit`에 기대지 않고 SwiftUI의 화면 생명주기와 실제 Feature 생명주기가 다른 경우를 구분한다.

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
