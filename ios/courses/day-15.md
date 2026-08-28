# Course Day 15 — Observer와 NetworkMonitoring Adapter

[이전 Day](day-14.md) · [전체 진도](day-00.md) · [다음 Day](day-16.md)

- [ ] Day 15 완료

## 중점 학습

- Observer와 AsyncStream, NWPathMonitor를 Domain에서 격리하는 Adapter, 구독 Task 생명주기

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

# Week 3 — State Machine·Reducer·TCA와 시스템 이벤트

## Day 15 — Observer와 NetworkMonitoring Adapter

학습:

```text
NWPathMonitor
Wi-Fi / Cellular
expensive
constrained
offline
AsyncStream
Observer 패턴
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

`NWPathMonitor`의 callback 생명주기를 `AsyncStream<Connectivity>`로 감싸고, Diagnostics Feature가 이를 구독한다. 구독 Task의 소유자와 종료 시점을 테스트 이름으로 드러낸다.

---
