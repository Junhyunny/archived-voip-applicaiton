# Day 12 — Retry Strategy와 Decorator

- [ ] 완료

### 사용자 스토리

> 사용자로서 일시적인 네트워크 오류는 안전하게 재시도되지만 인증 오류나 취소는 반복되지 않기를 원한다.

### 중점 학습

- 오류 종류와 retry 정책 분리
- exponential backoff와 cancellation
- Logging·Metrics 같은 부가 기능을 Decorator로 감싸기

### 구현

```text
NetworkRetryPolicy
NoRetryPolicy
ExponentialBackoffPolicy

Repository
→ RetryingRepository
→ LoggingRepository
```

### TDD 시나리오

```text
401 → retry 안 함
timeout → 정책에 따라 retry
500 → 제한 횟수만 retry
cancelled → retry 안 함
성공 → 즉시 종료
가상 시간으로 backoff 확인
중복 요청의 idempotency
```

### 완료 조건

- ViewModel에 오류 타입별 조건문이 퍼지지 않는다.
- 취소를 실패로 오인해 재시도하지 않는다.
