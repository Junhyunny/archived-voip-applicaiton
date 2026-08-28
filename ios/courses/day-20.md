# Course Day 20 — TCA 기본과 품질 Dashboard

[이전 Day](day-19.md) · [전체 진도](day-00.md) · [다음 Day](day-21.md)

- [ ] Day 20 완료

## 중점 학습

- 직접 Reducer 뒤 TCA State/Action/Reducer/Store/Dependency를 적용하고 품질 Strategy를 격리

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 20 — TCA 기본과 품질 Dashboard

직접 만든 `State`, `Action`, Reducer, Effect의 문제를 먼저 기록한 뒤 TCA를 추가한다.

```text
@Reducer
@ObservableState
State
Action
Effect
Dependency
Store
```

Week 2의 `CallHistoryFeature` 또는 작은 `QualityFeature`를 TCA로 다시 구현한다. Production 앱 전체를 이전하지 않고, 동일한 인수 예제와 dependency를 사용해 공정하게 비교한다.

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

View는 `Store`에서 필요한 state를 읽고 Action을 보내며, 품질 분류 규칙 자체는 TCA에 종속되지 않는 Domain Strategy로 유지한다.

---
