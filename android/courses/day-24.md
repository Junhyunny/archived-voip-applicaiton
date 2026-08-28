# Day 24 — Concurrency와 Race Condition

- [ ] 완료

### 사용자 스토리

> 통화 사용자로서 종료·오디오·Subscription 이벤트가 동시에 발생해도 최종 상태가 항상 Disconnected로 수렴하기를 원한다.

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
