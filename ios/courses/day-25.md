# Course Day 25 — Decorator, Diagnostics와 사용자 피드백

[이전 Day](day-24.md) · [전체 진도](day-00.md) · [다음 Day](day-26.md)

- [ ] Day 25 완료

## 중점 학습

- Logging/Retry/Metrics Decorator와 production diagnostics, 상태를 설명하는 사용자 feedback

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 25 — Decorator, Diagnostics와 사용자 피드백

core logic를 바꾸지 않고 횡단 관심사를 조합한다.

```text
MetricsHTTPClient
        ↓
RetryingHTTPClient
        ↓
LoggingHTTPClient
        ↓
URLSessionHTTPClient
```

Decorator의 순서가 관찰 결과와 retry 횟수에 어떤 영향을 주는지 테스트한다. `Logger`, `OSSignposter`, MetricKit, crash reporting, analytics, feature flag 중 로컬에서 검증 가능한 최소 경계를 만들고, 외부 유료 서비스는 활성화하지 않는다.

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
