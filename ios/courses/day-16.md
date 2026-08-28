# Course Day 16 — Call State Machine

[이전 Day](day-15.md) · [전체 진도](day-00.md) · [다음 Day](day-17.md)

- [ ] Day 16 완료

## 중점 학습

- Domain Call State Machine, 유효하지 않거나 순서가 바뀌고 늦고 중복된 Event의 전이 정책

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 16 — Call State Machine

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

상태 머신은 MVVM과 경쟁하는 화면 아키텍처가 아니다. `ActiveCallModel` 또는 다음 날 Reducer가 사용하는 순수한 Domain 규칙으로 두고, 유효하지 않은 전이·중복 event·late event의 정책을 반환하게 한다.

---
